class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string :name

      t.timestamps
    end
    create_table :taggings do |t|
      t.integer :tag_id
      t.integer :tagged_id
      t.string :tagged_type
      
      t.timestamps
    end
    add_index :tags, :name, :unique => true
    add_index :taggings, :tag_id
    add_index :taggings, [:tagged_id, :tagged_type]
  end

  def self.down
    remove_index :tags, :name
    remove_index :taggings, :tag_id
    remove_index :taggings, :columns => [:tagged_id, :tagged_type]
    drop_table :taggings
    drop_table :tags
  end
end
