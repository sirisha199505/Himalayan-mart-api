class App::Services::Analytics < App::Services::Base
  # Read-only dashboard/analytics figures computed from live data.
  def summary
    # Cancelled orders never count toward revenue; delivered orders are realised
    # revenue, everything else (processing/in-production/out-for-delivery) is
    # pipeline. `revenue` is the net booked figure (all non-cancelled orders).
    cancelled = Order.where(status: 'Cancelled')
    delivered = Order.where(status: 'Delivered')
    booked    = Order.exclude(status: 'Cancelled')

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
      revenue:            (booked.sum(:total) || 0),
      revenue_delivered:  (delivered.sum(:total) || 0),
      revenue_cancelled:  (cancelled.sum(:total) || 0),
      orders_delivered:   delivered.count,
      orders_cancelled:   cancelled.count,
      leads_by_status: Lead.group_and_count(:status).all.map { |r| { status: r[:status], count: r[:count] } }
    })
  end
end
