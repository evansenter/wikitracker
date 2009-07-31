class Browser
  
  attr_reader :request, :origin_vertex, :next_vertex, :page
    
  def initialize(current_url, request)
    @current_url = current_url
    
    @request = request
    
    @origin_vertex     = Graph.find_vertex(@request.origin_vertex_url)
    @target_vertex_url = @request.destination_vertex_url.blank? ? Vertex.null_vertex.url : URI.escape(@request.destination_vertex_url) 
    
    @next_vertex = nil
  end
  
  def handle_request(&url_generator)
    load_response
    
    @next_vertex = Graph.find_vertex( @target_vertex_url )
    
    @page = Page.new( @current_url, 
                      @next_vertex.url, 
                      @response.body, 
                      @target_uri.select( :scheme, :host ).join( '://' ), 
                      &url_generator )
                     
    @next_vertex.title = @page.title
    @next_vertex.save!
  end
  
private

  def load_response
    @response = get_response
  
    # follow redirects
    while @response.is_a?( Net::HTTPFound ) || @response.is_a?( Net::HTTPMovedPermanently ) do
      @target_vertex_url = @response.instance_variable_get( :@header )['location'].to_s
      @response = get_response
    end
    
    @response
  end
  
  def get_response
    @target_uri = URI.parse( @target_vertex_url )
    Net::HTTP.start(@target_uri.host, @target_uri.port) do |http|
      http.get(@target_vertex_url)
    end
  end

end