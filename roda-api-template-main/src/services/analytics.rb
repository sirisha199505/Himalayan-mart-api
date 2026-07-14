class App::Services::Analytics < App::Services::Base
  # Read-only dashboard/analytics figures computed from live data.
  def summary
    return_success({
      products:   Product.count,
      categories: Category.count,
      gallery:    GalleryItem.count,
      blogs:      BlogPost.count,
      case_studies: CaseStudy.count,
      stories:    Story.count,
      faqs:       Faq.count,
      leads:      Lead.count,
      orders:     Order.count,
      customers:  Customer.count,
      revenue:    (Order.sum(:total) || 0),
      leads_by_status: Lead.group_and_count(:status).all.map { |r| { status: r[:status], count: r[:count] } }
    })
  end
end
