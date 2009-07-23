class Graph
  class << self    
    def record_node(source_vertex, link_name, target_vertex_title, target_vertex_url)
      target_vertex = Vertex.find_by_url(target_vertex_url)
      if target_vertex.nil?
        target_vertex = Vertex.create!(:title => target_vertex_title, :url => target_vertex_url)
      end

      puts "target_vertex=#{target_vertex.inspect}"

      Edge.upsert!( :from_vertex => source_vertex, :to_vertex => target_vertex, :link_name => link_name )
    end
  end
end
