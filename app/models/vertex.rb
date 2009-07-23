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
  validates_presence_of :url, :title
end
