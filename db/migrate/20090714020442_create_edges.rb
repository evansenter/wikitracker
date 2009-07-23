class CreateEdges < ActiveRecord::Migration
  def self.up
    create_table :edges, :force => true do |t|
      t.integer :id
      t.integer :from_vertex_id
      t.integer :to_vertex_id
      t.string  :link_name
      t.timestamps
    end
  end

  def self.down
    drop_table :edges
  end
end
