class App::Services::Products < App::Services::Base
  def model; Product; end

  def list
    ds = model.order(Sequel.desc(:created_at))
    if qs[:search].present?
      term = "%#{qs[:search]}%"
      ds = ds.where(Sequel.ilike(:name, term))
    end
    if qs[:category].present?
      ds = ds.where(category: qs[:category])
    end
    return_success(ds.all.map(&:to_pos))
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
