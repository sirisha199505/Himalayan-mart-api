#!/usr/bin/env ruby
# Seeds representative sample data across every store entity so the admin
# console is populated. Idempotent-ish: clears the store tables first.
require 'bundler/setup'
Bundler.require(:default)
require './src/app'
App.load!

M = App::Models

puts "Clearing store tables…"
[M::Product, M::Category, M::GalleryItem, M::Faq, M::BlogPost,
 M::CaseStudy, M::Story, M::Lead, M::SeoEntry, M::Order, M::Customer, M::Setting].each { |m| m.dataset.delete }

IMG = ->(f) { "/images/gallery/#{f}" }

puts "Categories…"
cats = [
  { slug: 'sofas',      name: 'Sofas',      tagline: 'Sink into comfort',    icon: 'Sofa',       count: 48, image: IMG['sofa.jpg'] },
  { slug: 'beds',       name: 'Beds',       tagline: 'Rest in luxury',       icon: 'BedDouble',  count: 32, image: IMG['designer-bed.jpg'] },
  { slug: 'wardrobes',  name: 'Wardrobes',  tagline: 'Storage, elevated',    icon: 'DoorClosed', count: 24, image: IMG['wardrobe.jpg'] },
  { slug: 'dining',     name: 'Dining',     tagline: 'Gather in style',      icon: 'Utensils',   count: 28, image: IMG['dining-set.jpg'] },
  { slug: 'office',     name: 'Office',     tagline: 'Work in comfort',      icon: 'Briefcase',  count: 36, image: IMG['workstation.jpg'] },
  { slug: 'storage',    name: 'Storage',    tagline: 'A place for everything', icon: 'Boxes',    count: 18, image: IMG['storage.jpg'] }
]
cats.each { |c| M::Category.create(c) }

puts "Products…"
products = [
  { name: 'Himalaya 3-Seater Sofa', category: 'sofas', price: 54990, mrp: 72990, rating: 4.8, reviews: 214,
    short_description: 'A grand 3-seater in solid Sheesham and HR foam.', warranty: '5-Year Frame Warranty',
    stock: 12, in_stock: true, best_seller: true, images: [IMG['sofa.jpg']],
    materials: ['Sheesham Hardwood', 'HR Foam', 'Textured Fabric'],
    colors: [{ name: 'Beige', hex: '#d9cbb6' }, { name: 'Charcoal', hex: '#3a3a3a' }],
    dimensions: { width: 210, depth: 92, height: 86 } },
  { name: 'Kashmir Upholstered King Bed', category: 'beds', price: 64990, mrp: 84990, rating: 4.9, reviews: 156,
    short_description: 'A plush upholstered king bed with a tall headboard.', warranty: '5-Year Warranty',
    stock: 6, in_stock: true, best_seller: true, images: [IMG['designer-bed.jpg']],
    materials: ['Engineered Wood', 'Velvet Upholstery'], dimensions: { width: 198, depth: 210, height: 120 } },
  { name: 'Vault Sliding Wardrobe', category: 'wardrobes', price: 78990, rating: 4.7, reviews: 98,
    short_description: '3-door sliding wardrobe with mirror finish.', warranty: '7-Year Warranty',
    stock: 4, in_stock: true, images: [IMG['wardrobe.jpg']], materials: ['Laminated MDF', 'Glass'] },
  { name: 'Aria 4-Seater Dining Set', category: 'dining', price: 42990, mrp: 51990, rating: 4.6, reviews: 132,
    short_description: 'A compact 4-seater dining set in solid wood.', warranty: '3-Year Warranty',
    stock: 9, in_stock: true, images: [IMG['dining-set.jpg']], materials: ['Sheesham Hardwood'] },
  { name: 'Twin Workstation', category: 'office', price: 38990, rating: 4.5, reviews: 74,
    short_description: 'A dual workstation built for productive offices.', warranty: '3-Year Warranty',
    stock: 0, in_stock: false, images: [IMG['workstation.jpg']], materials: ['Engineered Wood', 'Powder-coated Steel'] },
  { name: 'Bespoke Custom Piece', category: 'storage', price: 0, rating: 5.0, reviews: 12,
    short_description: 'Made to order to your exact specification.', warranty: 'Custom Warranty',
    stock: 0, in_stock: false, images: [IMG['storage.jpg']],
    specs: [{ label: 'Lead Time', value: '6-8 weeks' }, { label: 'Made To Order', value: 'Yes' }] }
]
products.each { |p| M::Product.create(p) }

puts "Gallery…"
gallery = [
  { title: 'Warm Living Room Retreat', category: 'Living Room', image: IMG['sofa.jpg'],        span: 'wide',   location: 'Hyderabad' },
  { title: 'Designer Master Bedroom',  category: 'Bedroom',     image: IMG['designer-bed.jpg'], span: 'tall',   location: 'Bengaluru' },
  { title: 'Family Dining Space',      category: 'Dining',      image: IMG['dining-set.jpg'],   span: 'normal', location: 'Chennai' },
  { title: 'Modern Home Office',       category: 'Office',      image: IMG['home-office.jpg'],  span: 'normal', location: 'Pune' },
  { title: 'Hotel Lobby Fit-out',      category: 'Commercial',  image: IMG['hotel.jpg'],        span: 'wide',   location: 'Goa' },
  { title: 'Boardroom Setup',          category: 'Office',      image: IMG['conference.jpg'],   span: 'normal', location: 'Mumbai' },
  { title: 'Cafe Seating',             category: 'Commercial',  image: IMG['cafe.jpg'],         span: 'normal', location: 'Hyderabad' },
  { title: 'Sliding Wardrobe',         category: 'Bedroom',     image: IMG['wardrobe.jpg'],     span: 'tall',   location: 'Delhi' }
]
gallery.each { |g| M::GalleryItem.create(g) }

puts "FAQs…"
[
  { category: 'Products',      question: 'What materials do you use?', answer: 'We build with solid Sheesham, engineered wood, HR foam and premium fabrics.' },
  { category: 'Delivery',      question: 'Do you deliver across India?', answer: 'Yes, we deliver pan-India with white-glove installation in major cities.' },
  { category: 'Installation',  question: 'Is installation included?', answer: 'Installation is complimentary within city limits for most products.' },
  { category: 'Warranty',      question: 'What warranty do you offer?', answer: 'Most products carry a 3-7 year frame warranty.' },
  { category: 'Customization', question: 'Can I customise a piece?', answer: 'Absolutely — most pieces can be made to order in your chosen finish.' },
  { category: 'Returns',       question: 'What is your return policy?', answer: 'Unused items can be returned within 7 days of delivery.' }
].each { |f| M::Faq.create(f) }

puts "Blogs…"
[
  { title: 'How to Choose the Perfect Sofa', category: 'Furniture Buying Guides', author: 'Priya Menon',
    author_role: 'Lead Interior Designer', date: '2026-05-28', cover: IMG['sofa.jpg'],
    excerpt: 'From frame and foam to fabric — everything you need to know.',
    tags: ['sofas', 'living room', 'buying guide'], content: 'Choosing a sofa is one of the biggest furniture decisions…' },
  { title: 'Designing a Productive Home Office', category: 'Workspace Design', author: 'Rahul Verma',
    author_role: 'Design Consultant', date: '2026-05-14', cover: IMG['home-office.jpg'],
    excerpt: 'Set up a workspace that keeps you focused and comfortable.',
    tags: ['office', 'workspace'], content: 'A great home office starts with the right desk…' },
  { title: 'Caring for Solid Wood Furniture', category: 'Furniture Care', author: 'Anjali Rao',
    author_role: 'Craftsperson', date: '2026-04-30', cover: IMG['dining-set.jpg'],
    excerpt: 'Simple habits to keep your wood furniture beautiful for decades.',
    tags: ['care', 'wood'], content: 'Solid wood furniture rewards a little regular care…' }
].each { |b| M::BlogPost.create(b) }

puts "Case studies…"
[
  { title: "A Modern Villa's Living Spaces", client: 'The Reddy Residence', location: 'Jubilee Hills, Hyderabad',
    category: 'Residential', cover: IMG['sofa.jpg'], summary: 'A complete living and dining fit-out.',
    requirement: 'The family wanted a cohesive, warm living space.',
    solution: 'We anchored the double-height space with a large sectional.',
    outcome: 'Delivered and installed in five weeks.',
    challenges: ['Double-height living room', 'Tight timeline'],
    furniture_used: ['Aspen L-Shaped Sectional', 'Aria Dining Set'],
    stats: [{ label: 'Area', value: '4,000 sq ft' }, { label: 'Timeline', value: '5 weeks' }],
    gallery: [IMG['sofa.jpg'], IMG['dining-set.jpg']] },
  { title: 'Boutique Hotel Lobby', client: 'Coastal Stays', location: 'Panjim, Goa',
    category: 'Commercial', cover: IMG['hotel.jpg'], summary: 'Reception and lounge furniture for a boutique hotel.',
    requirement: 'Durable yet stylish furniture for high footfall.',
    solution: 'Contract-grade seating with a warm palette.',
    outcome: 'A welcoming lobby that handles heavy use.',
    challenges: ['High footfall', 'Coastal humidity'],
    furniture_used: ['Reception Desk', 'Lounge Sofas'],
    stats: [{ label: 'Seats', value: '40+' }] }
].each { |c| M::CaseStudy.create(c) }

puts "Stories…"
[
  { title: 'Our Journey', kicker: 'Where it began', cover: IMG['imported.jpg'],
    excerpt: 'From a single workshop to a premium furniture house.',
    body: 'Himalayan Furniture Mart began with a simple belief…' },
  { title: 'Our Craftsmanship', kicker: 'How we build', cover: IMG['dining-set.jpg'],
    excerpt: 'Every joint, every finish, made to last.',
    body: 'Craftsmanship is at the heart of everything we make…' },
  { title: 'Behind the Workshop', kicker: 'Meet the makers', cover: IMG['workstation.jpg'],
    excerpt: 'The people who bring our furniture to life.',
    body: 'Our workshop is home to a team of skilled artisans…' }
].each { |s| M::Story.create(s) }

puts "Leads…"
[
  { name: 'Ananya Reddy',  phone: '+91 98xxxx2210', product: 'Himalaya 3-Seater Sofa', status: 'New',       date: '2026-06-20', city: 'Hyderabad' },
  { name: 'Rajesh Kumar',  phone: '+91 99xxxx1180', product: 'Twin Workstation',        status: 'Contacted', date: '2026-06-19', city: 'Bengaluru' },
  { name: 'Priya Menon',   phone: '+91 90xxxx7745', product: 'Vault Sliding Wardrobe',   status: 'Quoted',    date: '2026-06-18', city: 'Chennai' },
  { name: 'Vikram Singh',  phone: '+91 97xxxx3321', product: 'Kashmir King Bed',         status: 'Won',       date: '2026-06-16', city: 'Pune' },
  { name: 'Sneha Iyer',    phone: '+91 96xxxx9982', product: 'Aria 4-Seater Dining',     status: 'New',       date: '2026-06-15', city: 'Mumbai' }
].each { |l| M::Lead.create(l) }

puts "Orders…"
[
  { code: '#HFM-3041', customer: 'Ananya Reddy',        items: 3,  total: 124970,  status: 'Delivered',        date: '2026-06-18' },
  { code: '#HFM-3040', customer: 'Nimbus Technologies', items: 64, total: 1840000, status: 'In Production',     date: '2026-06-17' },
  { code: '#HFM-3039', customer: 'Vikram Singh',        items: 1,  total: 64990,   status: 'Out for Delivery',  date: '2026-06-16' },
  { code: '#HFM-3038', customer: 'Sneha Iyer',          items: 2,  total: 56980,   status: 'Processing',        date: '2026-06-15' },
  { code: '#HFM-3037', customer: 'Arjun Nair',          items: 5,  total: 98750,   status: 'Delivered',         date: '2026-06-12' }
].each { |o| M::Order.create(o) }

puts "Customers…"
[
  { name: 'Ananya Reddy',           email: 'ananya@example.com', city: 'Hyderabad', orders: 3,  spent: 184960,  since: '2024' },
  { name: 'Nimbus Technologies',    email: 'ops@nimbus.example', city: 'Bengaluru', orders: 2,  spent: 2640000, since: '2025' },
  { name: 'Priya Menon (Designer)', email: 'priya@example.com',  city: 'Chennai',   orders: 11, spent: 980000,  since: '2023' },
  { name: 'Vikram Singh',           email: 'vikram@example.com', city: 'Pune',      orders: 1,  spent: 64990,   since: '2026' },
  { name: 'Sneha Iyer',             email: 'sneha@example.com',  city: 'Mumbai',    orders: 2,  spent: 56980,   since: '2026' }
].each { |c| M::Customer.create(c) }

puts "SEO…"
[
  { page: 'Home',    title: 'Himalayan Furniture Mart — Crafted For Beautiful Living', description: 'Premium furniture designed to transform every corner of your home.', keywords: 'premium furniture, luxury furniture India' },
  { page: 'Shop',    title: 'Shop All Furniture', description: 'Browse premium furniture — sofas, beds, dining, office and more.', keywords: 'buy furniture online, sofas, beds' },
  { page: 'Gallery', title: 'Gallery', description: 'Real homes and projects furnished by Himalayan Furniture Mart.', keywords: 'furniture gallery, interior projects' }
].each { |s| M::SeoEntry.create(s) }

puts "Settings…"
M::Setting.create(
  store_name: 'Himalayan Furniture Mart',
  tagline: 'Crafted For Beautiful Living',
  phone: '+91 90000 00000',
  email: 'hello@himalayanfurnituremart.in',
  whatsapp: '+919000000000',
  instagram: 'https://instagram.com/himalayanfurnituremart',
  facebook: 'https://facebook.com/himalayanfurnituremart',
  youtube: 'https://youtube.com/@himalayanfurnituremart',
  city: 'Hyderabad',
  state: 'Telangana',
  hours: 'Mon-Sat, 10am - 8pm'
)

puts "Users…"
admin = M::User.find(email: 'manager@himalayanfurnituremart.in') || M::User.new(email: 'manager@himalayanfurnituremart.in')
admin.full_name = 'Store Manager'
admin.password  = 'manager123'
admin.role      = 2
admin.active    = true
admin.save

puts "Done. Counts:"
%w[Product Category GalleryItem Faq BlogPost CaseStudy Story Lead Order Customer SeoEntry Setting User].each do |k|
  puts "  #{k}: #{M.const_get(k).count}"
end
