module ApplicationHelper
  
  def convert_options_to_data_attributes (options, html_options)
    url = url_for(options)
    if request.path.start_with?(url)
      html_options ||= {}
      html_options["class"] = "active"
    end
    super(options, html_options)
  end
  
end
