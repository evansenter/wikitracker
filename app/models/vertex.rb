# == Schema Information
# Schema version: 20090714020442
#
# Table name: vertices
#
#  id         :integer(4)      not null, primary key
#  url        :string(255)
#  title      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Vertex < ActiveRecord::Base
  validates_presence_of :url
  
  NULL_URL = 'http://www.wikipedia.org'.freeze
  
  def self.upsert_with_url!(url)
    vertex = Vertex.find( :first, 
                          :conditions => ['url = ?', url ] )
    if vertex.nil?
      vertex = Vertex.create!(:url => url)
    end
    
    vertex
  end
  
  def self.null_vertex
    return @null_vertex if @null_vertex

    @null_vertex = Vertex.upsert_with_url!(NULL_URL)
    @null_vertex.title = 'Wikipedia'
    @null_vertex.save!
    
    @null_vertex.freeze
  end
end
