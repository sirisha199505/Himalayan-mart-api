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

  def self.fields
    { save: [:name, :phone, :product, :status, :date, :city] }
  end
end
