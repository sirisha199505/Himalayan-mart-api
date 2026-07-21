Sequel.migration do
  change do
    # Capture the full storefront enquiry (Enquire Now / Book Consultation /
    # Request Quote / Contact form) as a lead so staff can follow up.
    alter_table(:leads) do
      add_column :email,   String
      add_column :message, String, text: true
    end
  end
end
