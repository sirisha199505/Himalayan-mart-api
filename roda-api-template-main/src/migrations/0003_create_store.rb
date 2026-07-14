Sequel.migration do
  change do
    # ---- Products ----
    create_table(:products) do
      primary_key :id
      String  :slug, unique: true
      String  :name, null: false
      String  :category
      Integer :price, default: 0
      Integer :mrp
      BigDecimal :rating, size: [3, 1], default: 0
      Integer :reviews, default: 0
      String  :short_description, text: true
      String  :description, text: true
      String  :warranty
      String  :seating
      Integer :weight
      Integer :stock, default: 0
      TrueClass :in_stock, default: true
      TrueClass :best_seller, default: false
      TrueClass :is_new, default: false
      column :images, :jsonb, default: '[]'
      column :materials, :jsonb, default: '[]'
      column :colors, :jsonb, default: '[]'
      column :dimensions, :jsonb, default: '{}'
      column :badges, :jsonb, default: '[]'
      column :specs, :jsonb, default: '[]'
      Boolean :active, default: true
      Integer :created_by
      Integer :updated_by
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
      index :slug
      index :category
    end

    # ---- Categories ----
    create_table(:categories) do
      primary_key :id
      String  :slug, unique: true
      String  :name, null: false
      String  :tagline
      String  :description, text: true
      String  :image
      String  :icon
      Integer :count, default: 0
      TrueClass :featured, default: false
      Boolean :active, default: true
      Integer :created_by
      Integer :updated_by
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
      index :slug
    end

    # ---- Gallery items ----
    create_table(:gallery_items) do
      primary_key :id
      String  :title
      String  :category
      String  :image
      String  :span, default: 'normal'
      String  :location
      column :images, :jsonb, default: '[]'
      Boolean :active, default: true
      Integer :created_by
      Integer :updated_by
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end

    # ---- FAQs ----
    create_table(:faqs) do
      primary_key :id
      String  :category
      String  :question, text: true
      String  :answer, text: true
      Boolean :active, default: true
      Integer :created_by
      Integer :updated_by
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end

    # ---- Blog posts ----
    create_table(:blog_posts) do
      primary_key :id
      String  :slug, unique: true
      String  :title
      String  :excerpt, text: true
      String  :category
      String  :cover
      String  :author
      String  :author_role
      String  :date
      column :tags, :jsonb, default: '[]'
      String  :content, text: true
      column :images, :jsonb, default: '[]'
      Boolean :active, default: true
      Integer :created_by
      Integer :updated_by
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
      index :slug
    end

    # ---- Case studies ----
    create_table(:case_studies) do
      primary_key :id
      String  :slug, unique: true
      String  :title
      String  :client
      String  :location
      String  :category
      String  :cover
      String  :summary, text: true
      String  :requirement, text: true
      String  :solution, text: true
      String  :outcome, text: true
      column :challenges, :jsonb, default: '[]'
      column :furniture_used, :jsonb, default: '[]'
      column :gallery, :jsonb, default: '[]'
      column :stats, :jsonb, default: '[]'
      column :images, :jsonb, default: '[]'
      Boolean :active, default: true
      Integer :created_by
      Integer :updated_by
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
      index :slug
    end

    # ---- Stories ----
    create_table(:stories) do
      primary_key :id
      String  :slug, unique: true
      String  :title
      String  :kicker
      String  :excerpt, text: true
      String  :cover
      String  :body, text: true
      column :images, :jsonb, default: '[]'
      Boolean :active, default: true
      Integer :created_by
      Integer :updated_by
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
      index :slug
    end

    # ---- Leads ----
    create_table(:leads) do
      primary_key :id
      String  :name
      String  :phone
      String  :product
      String  :status, default: 'New'
      String  :date
      String  :city
      Boolean :active, default: true
      Integer :created_by
      Integer :updated_by
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end

    # ---- SEO entries ----
    create_table(:seo_entries) do
      primary_key :id
      String  :page
      String  :title
      String  :description, text: true
      String  :keywords, text: true
      Boolean :active, default: true
      Integer :created_by
      Integer :updated_by
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end

    # ---- Orders ----
    create_table(:orders) do
      primary_key :id
      String  :code
      String  :customer
      Integer :items, default: 1
      Integer :total, default: 0
      String  :status, default: 'Processing'
      String  :date
      Boolean :active, default: true
      Integer :created_by
      Integer :updated_by
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end

    # ---- Customers ----
    create_table(:customers) do
      primary_key :id
      String  :name
      String  :email
      String  :city
      Integer :orders, default: 0
      Integer :spent, default: 0
      String  :since
      Boolean :active, default: true
      Integer :created_by
      Integer :updated_by
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end

    # ---- Settings (single row) ----
    create_table(:settings) do
      primary_key :id
      String  :store_name
      String  :tagline
      String  :phone
      String  :email
      String  :whatsapp
      String  :instagram
      String  :facebook
      String  :youtube
      String  :city
      String  :state
      String  :hours
      column :extras, :jsonb, default: '{}'
      Integer :created_by
      Integer :updated_by
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
