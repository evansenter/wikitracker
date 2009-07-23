class Browser
  
  attr_reader :request, :next_vertex, :page
    
  def initialize(current_url, params)
    @current_url = current_url
    @request = NodeConnection.new_from_params(params)
    @request.destination_vertex_url = URI.escape(@request.destination_vertex_url)
    @next_vertex = nil
  end
  
  def handle_request(&url_generator)
    load_response
    
    @next_vertex = Graph.find_vertex( @request.destination_vertex_url )
    
    @page = Page.new( @current_url, 
                      @next_vertex, 
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
      @request.destination_vertex_url = @response.instance_variable_get( :@header )['location'].to_s
      @response = get_response
    end
    
    @response
  end
  
  def get_response
    @target_uri = URI.parse( @request.destination_vertex_url )
    Net::HTTP.start(@target_uri.host, @target_uri.port) do |http|
      http.get(@request.destination_vertex_url)
    end
  end

end