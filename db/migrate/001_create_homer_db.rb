class CreateHomerDb < ActiveRecord::Migration

	def self.up
		
		create_table :homepages do |t|
			t.string :title
			t.string :path
			
			t.timestamps
		end
		
		create_table :feeds do |t|
			t.string :url
			t.string :title
			t.text :description				
			
			t.timestamps
		end
		
		create_table :stories do |t|
			t.string :title
			t.text :body
			t.string :author
			t.datetime :pubdate
			t.string :permalink
			t.string :photo_url
			
			t.integer :feed_id
			t.integer :slot_id
			
			t.timestamps
		end

		create_table :slots do |t|
			t.string :label
			
			t.integer :homepage_id
			
			t.timestamps
		end
		
		create_table :feeds_homepages, :id => false do |t|
			t.integer :homepage_id
			t.integer :feed_id
			
			t.timestamps
		end
		
	end

	def self.down
		drop_table :homepages
		drop_table :feeds
		drop_table :stories
		drop_table :slots
		drop_table :feeds_homepages
	end

end