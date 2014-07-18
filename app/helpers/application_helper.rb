module ApplicationHelper
  
  def convert_options_to_data_attributes (options, html_options)
    url = url_for(options)
    html_options ||= {}
    if request.path == url or (html_options[:exact] != true and request.path.start_with?(url))
      html_options["class"] = "active"
    end
    super(options, html_options)
  end
  
  def icon (key, text = nil)
    text
  end
  
end
