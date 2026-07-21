Sequel.migration do
  change do
    # Curated storefront collections (homepage "Featured Collections", the
    # /collections pages and the shop's "Shop by Collection" filter) — now
    # manageable from admin instead of a hardcoded data file. Each collection
    # groups one or more product categories via `category_slugs`.
    create_table(:collections) do
      primary_key :id
      String  :slug, unique: true
      String  :name
      String  :subtitle
      String  :description, text: true
      String  :image, text: true
      String  :accent
      String  :items
      column  :category_slugs, :jsonb, default: '[]'
      Integer :sort_order, default: 0
      Boolean :active, default: true
      Integer :created_by
      Integer :updated_by
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
      index :slug
    end
  end
end
