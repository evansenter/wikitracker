# == Schema Information
# Schema version: 20090714020442
#
# Table name: edges
#
#  id             :integer(4)      not null, primary key
#  from_vertex_id :integer(4)
#  to_vertex_id   :integer(4)
#  link_name      :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

class Edge < ActiveRecord::Base
  validates_presence_of :to_vertex, :link_name
  
  belongs_to :to_vertex, :class_name => 'Vertex'
  belongs_to :from_vertex, :class_name => 'Vertex'
  
  def self.upsert!(attributes)
    edge = Edge.find( :first, 
                      :conditions => ['from_vertex_id = ? AND to_vertex_id = ?', 
                                      (attributes[:from_vertex].nil? ? 'NULL' : attributes[:from_vertex].id), 
                                      (attributes[:to_vertex].nil? ? 'NULL' : attributes[:to_vertex].id) ] )
    if edge.nil?
      edge = Edge.create!(attributes)
    end
    
    edge
  end
end
