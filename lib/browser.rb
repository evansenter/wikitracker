class Browser
  
  attr_reader :current_url, :next_page
    
  def initialize(current_url, params)
    @current_url = current_url
    @next_page = NodeConnection.new_from_params(params)
    @next_page.destination_vertex_url = URI.escape(@next_page.destination_vertex_url)
  end
  
  def load_page
    @response = get_response
    
    # follow redirects
    while @response.is_a?( Net::HTTPFound ) || @response.is_a?( Net::HTTPMovedPermanently ) do
      @next_page.destination_vertex_url = @response.instance_variable_get( :@header )['location'].to_s
      @response = get_response
    end
  end

  def get_page(&url_generator)
    Page.new( @current_url, 
              @next_page.origin_vertex, 
              @response.body, 
              @target_uri.select( :scheme, :host ).join( '://' ), 
              &url_generator )
  end
  
private
  
  def get_response
    @target_uri = URI.parse( @next_page.destination_vertex_url )
    Net::HTTP.start(@target_uri.host, @target_uri.port) do |http|
      http.get(@next_page.destination_vertex_url)
    end
  end

end

# -- old shit -- 

# def annotate_body(body)
#   returning( Hpricot(body) ) do |document|
#     
#     # intercept links
#     document.search('//a[@href]') do |link|
#       link_href = link.attributes['href']
# 
#       if anchor_match = link_href.match( /^(#.*)/ )
#         # keep in page anchors on page
#         link.set_attribute :href, "#{state.current_url}#{anchor_match[1]}"
#       elsif ! link_to_file?( link_href )
#         begin
#           link_href = "#{base_href}#{link_href}" if URI.parse(link_href.to_s).relative?
#           link.set_attribute(
#             :href, 
#             browser_url( 
#               :t => URI.escape(link_href), 
#               :v => URI.escape(state.current_vertex.url), 
#               :n => link.inner_text.strip )
#           )
#         rescue URI::InvalidURIError
#         end
#       end
#     end
# 
#     # intercept forms    
#     document.search( '//form' ) do |form|
#       form_action = form.attributes['action']
#       inputs = form.search( '//input' )
#       inputs.first.before( "<input type=hidden name='t' value='#{form_action}' />" )
#       inputs.first.before( "<input type=hidden name='v' value='#{URI.escape(state.current_vertex.url)}' />" )
#       inputs.first.before( "<input type=hidden name='n' value='<button>' />" )
#     
#       form.set_attribute( :action, browser_url )
#     end
# 
#     # add base href
#     document.search( '//head' ) do |head|
#       head_elements = head.search('/')
#       head_elements.first.before( "<base href='#{base_href}' />" )
#     end
#   end    
# end

# def resolve_request
#   target_url_path = URI.escape(@browser_state.target_url)
#   target_uri = URI.parse( target_url_path )
#   resp = Net::HTTP.start(target_uri.host, target_uri.port) do |http|
#     p "looking up #{target_url_path}"
#     http.get(target_url_path)
#   end
#   
#   # follow redirects
#   while resp.is_a?( Net::HTTPFound ) || resp.is_a?( Net::HTTPMovedPermanently ) do
#     target_url_path = resp.instance_variable_get( :@header )['location'].to_s
#     p "redirecting to '#{target_url_path}'"
#     target_uri = URI.parse( target_url_path )
#     
#     resp = Net::HTTP.start(target_uri.host, target_uri.port) do |http|
#       http.get(target_url_path)
#     end
#   end
#   
#   @base_href = target_uri.select( :scheme, :host ).join( '://' )
#   
#   resp
# end
