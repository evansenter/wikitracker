require 'test_helper'

class VertexTest < ActiveSupport::TestCase
  test "url and title are present" do
    Vertex.create!( :url => 'balls', :title => 'nuts')
    
    v = Vertex.new( :url => 'balls')
    assert ! v.valid?
    
    v = Vertex.new( :title => 'nuts')
    assert_not_valid_on v, :url, "can't be blank"
  end
end
