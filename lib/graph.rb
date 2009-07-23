class Graph
  class << self    
    def record_node(source_vertex, link_name, target_vertex)
      Edge.upsert!( :from_vertex => source_vertex, :to_vertex => target_vertex, :link_name => link_name )
    end
        
    def find_vertex(url)
      if url.blank?
        Vertex.null_vertex
      else
        Vertex.upsert_with_url!( url )
      end
    end

  end
end
