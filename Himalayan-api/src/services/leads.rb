class App::Services::Leads < App::Services::Base
  def model; Lead; end

  def list
    ds = model.order(Sequel.desc(:created_at))
    if qs[:search].present?
      term = "%#{qs[:search]}%"
      ds = ds.where(Sequel.ilike(:name, term)).or(Sequel.ilike(:phone, term))
    end
    return_success(ds.all.map(&:to_pos))
  end

  # Public storefront enquiry (Enquire Now / Book Consultation / Contact form).
  # No auth. Status is forced to 'New' and the date defaults to today so a
  # visitor can't set arbitrary internal fields.
  def public_create
    check_presence!(:name)
    obj = model.new(data_for(:save))
    obj.status = 'New'
    obj.active = true
    obj.date ||= Time.now.strftime('%Y-%m-%d')
    save(obj)
  end

  def self.fields
    { save: [:name, :phone, :email, :message, :product, :status, :date, :city] }
  end
end
