class App::Services::Orders < App::Services::Base
  def model; Order; end

  def self.fields
    { save: [:code, :customer, :items, :total, :status, :date] }
  end
end
