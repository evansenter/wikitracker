class NodeConnection
  ORIGIN_VERTEX_URL_KEY = 'v'.freeze
  DESTINATION_VERTEX_URL_KEY = 't'.freeze
  LINK_NAME_KEY  = 'n'.freeze
  
  DEFAULT_URL = 'http://www.wikipedia.org'.freeze
  
  attr_accessor :origin_vertex
  attr_accessor :link_name
  attr_accessor :destination_vertex_url

  def initialize(origin_vertex, destination_vertex_url, link_name)
    @origin_vertex = origin_vertex
    @destination_vertex_url = destination_vertex_url
    @link_name = link_name
  end
  
  def to_url(&url_generator)
    url_generator.call( 
      DESTINATION_VERTEX_URL_KEY => URI.escape(@destination_vertex_url), 
      ORIGIN_VERTEX_URL_KEY => URI.escape(@origin_vertex.url), 
      LINK_NAME_KEY => @link_name )
  end
  
  class << self
    
    def new_from_params(params)
      origin_vertex = find_origin_vertex_by_url( params.delete( ORIGIN_VERTEX_URL_KEY ) )

      destination_vertex_url = params.delete( DESTINATION_VERTEX_URL_KEY ) || DEFAULT_URL
      link_name = params.delete( LINK_NAME_KEY ) || DEFAULT_URL

      destination_vertex_url += '?' + params.map { |k,v| "#{k}=#{v}" }.join( '&' ) unless params.empty?

      NodeConnection.new(origin_vertex, destination_vertex_url, link_name)
    end
    
  private
  
    def find_origin_vertex_by_url(vertex_url)
      if vertex_url
        Vertex.find_by_url( vertex_url )   
      else
        Vertex.create!( :url => DEFAULT_URL, :title => 'Wikipedia')
      end
    end
  end
end