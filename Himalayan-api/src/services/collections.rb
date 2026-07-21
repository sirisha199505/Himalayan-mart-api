class App::Services::Collections < App::Services::Base
  def model; Collection; end

  # Ordered by an explicit sort_order (then newest) for both admin + storefront.
  def list
    return_success(model.order(:sort_order, Sequel.desc(:created_at)).all.map(&:to_pos))
  end

  def public_ds
    model.where(active: true).order(:sort_order, Sequel.desc(:created_at))
  end

  def self.fields
    { save: [:slug, :name, :subtitle, :description, :image, :accent,
             :items, :category_slugs, :sort_order] }
  end
end
