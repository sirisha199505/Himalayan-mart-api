
class App::Routes < Roda
  include App::Router::AllPlugins
  plugin :not_found do
    { status: 'error', data: 'Not Found' }
  end

  def do_crud(klass, r, only='CRUDL', opts = {})
    r.post { klass[r, opts].create } if only.include?('C')
    r.get(Integer) {|id| klass[r, opts.merge(id: id)].get} if only.include?('R')
    r.get { klass[r, opts].list } if only.include?('L')
    r.put(Integer) {|id| klass[r, opts.merge(id: id)].update } if only.include?('U')
    r.delete(Integer) {|id| klass[r, opts.merge(id: id)].delete } if only.include?('D')
  end

  route do |r|
    r.public

    r.root do
      File.read(File.join(App.root, 'public', 'index.html'))
    end

    r.on 'admin' do
      r.get do
        File.read(File.join(App.root, 'public', 'index.html'))
      end
    end

    r.on 'api' do
      r.response['Content-Type'] = 'application/json'

      # Public endpoints (no auth required)
      r.post('login') { Session[r].login }
      r.post('forgot-password') { Users[r].forgot_password }
      r.post('validate-password-token') { Users[r].validate_password_token }
      r.post('reset-password') { Users[r].reset_password }

      r.get 'version' do
        { status: 'success', version: 1 }
      end

      # Public store settings for the storefront (whitelisted, no auth)
      r.get('store-info') { Settings[r].public_info }

      # Public guest checkout + Razorpay payment (no auth — storefront shoppers)
      r.on 'checkout' do
        r.post('create-order') { Checkout[r].create_order }
        r.post('verify')       { Checkout[r].verify }
        r.post('cod')          { Checkout[r].place_cod }
        r.get('order')         { Checkout[r].show }
      end

      # Public storefront reads (no auth). GET-only, active-only.
      r.on 'public' do
        r.on('products') do
          r.get('slug', String) { |s| Products[r].public_get_by_slug(s) }
          r.get { Products[r].public_list }
        end
        r.on('categories') do
          r.get('slug', String) { |s| Categories[r].public_get_by_slug(s) }
          r.get { Categories[r].public_list }
        end
      end

      # Authentication required for all routes below
      auth_required!

      # User profile routes (any authenticated staff member)
      r.on 'me' do
        r.get('info') { Users[r].info }
        r.put('update-password') { Users[r].update_password }
      end

      # Staff routes — Super Admin OR Admin
      staff_required!

      begin
        r.on('products')      { do_crud(Products, r) }
        r.on('categories')    { do_crud(Categories, r) }
        r.on('gallery')       { do_crud(GalleryItems, r) }
        r.on('faqs')          { do_crud(Faqs, r) }
        r.on('blogs')         { do_crud(Blogs, r) }
        r.on('case-studies')  { do_crud(CaseStudies, r) }
        r.on('stories')       { do_crud(Stories, r) }
        r.on('seo')           { do_crud(Seos, r) }
        r.on('leads')         { do_crud(Leads, r) }
        r.on('orders')        { do_crud(Orders, r) }
        r.on('customers')     { do_crud(Customers, r) }
        r.get('analytics')    { Analytics[r].summary }

        # Super Admin only
        r.on 'users' do
          super_admin_required!
          do_crud(Users, r)
        end

        r.on 'settings' do
          super_admin_required!
          r.get { Settings[r].current }
          r.put { Settings[r].save_current }
        end
      rescue => e
        App.logger.error("API Error: #{e.message}")
        App.logger.error(e.backtrace)
        r.response.status = 400
        { status: 'error', message: "An error occurred: #{e.message}" }
      end
    end

    # Fallback route
    r.get do
      File.read(File.join(App.root, 'public', 'index.html'))
    end
  end

  before do
    @time = Time.now
    App::Helpers::Before.run!(request)
  end

  after do |res|
    rtype = request.request_method
    App.logger.info("→ [#{Time.now - @time} seconds] - [#{rtype}]#{request.path}")
  end

  def auth_required!
    unless App.cu.valid?
      request.halt(401, {'Content-Type' => 'application/json'},{ status: 'Unauthorized!' }.to_json)
    end
  end

  # Any admin console user (Super Admin or Admin)
  def staff_required!
    unless App.cu.user_obj&.staff?
      request.halt(403, {'Content-Type' => 'application/json'},{ status: 'Forbidden!' }.to_json)
    end
  end

  # Super Admin only (user management, settings)
  def super_admin_required!
    unless App.cu.user_obj&.super_admin?
      request.halt(403, {'Content-Type' => 'application/json'},{ status: 'Forbidden! Super Admin access required.' }.to_json)
    end
  end
end

App.require_blob('services/base.rb')
App.require_blob('services/*.rb')

App::Routes.send(:include, App::Services)
