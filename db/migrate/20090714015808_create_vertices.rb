class CreateVertices < ActiveRecord::Migration
  def self.up
    create_table :vertices, :force => true do |t|
      t.integer :id
      t.string  :url
      t.string  :title
      t.timestamps
    end
    
    add_index :vertices, :id
  end

  def self.down
    drop_table :vertices
  end
end
