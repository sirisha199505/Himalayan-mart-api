Sequel.migration do
  change do
    # Store locations / branches shown on the Contact page — manageable from admin
    # instead of being hardcoded in the UI.
    create_table(:locations) do
      primary_key :id
      String  :name
      String  :address, text: true
      String  :phone
      String  :email
      String  :map_url, text: true
      String  :hours
      TrueClass :is_flagship, default: false
      Boolean :active, default: true
      Integer :created_by
      Integer :updated_by
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
