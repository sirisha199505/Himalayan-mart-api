class App::Services::Products < App::Services::Base
  def model; Product; end

  def list
    return_success(filtered(model.order(Sequel.desc(:created_at))).all.map(&:to_pos))
  end

  # Public storefront dataset: active only + the same search/category filters.
  def public_ds
    filtered(model.where(active: true).order(Sequel.desc(:created_at)))
  end

  private

  def filtered(ds)
    ds = ds.where(Sequel.ilike(:name, "%#{qs[:search]}%")) if qs[:search].present?
    ds = ds.where(category: qs[:category]) if qs[:category].present?
    ds
  end

  def self.fields
    { save: [
      :slug, :name, :category, :price, :mrp, :rating, :reviews,
      :short_description, :description, :warranty, :seating, :weight,
      :stock, :in_stock, :best_seller, :is_new,
      :images, :materials, :colors, :dimensions, :badges, :specs
    ] }
  end
end
