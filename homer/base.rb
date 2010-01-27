require 'erb'
require 'open-uri'
require 'activerecord'
require 'feedme' #for atom/rss parsing


class Homer

	def self.version
		'0.1'
	end
	
	def self.check_for_db
		if File.exists?("#{SINATRA_ROOT}/db/homer.sqlite3")
			"you're in business"
		else
			`rake homer:init`
			"reload for your fresh db"
		end
	end
	
	def self.get_feed(url)
		file = open(url).read
		feed = FeedMe.parse(file)
		entries = feed.entries
	end
	
# 	def self.generate_template(homepage)
# 		homepage_title = homepage.title
# 		filename = homepage.title.dirify
# 		f = File.new("#{filename}", "w+")
# 	
# 		
# 	end

	# boilerplate template code
	
	def self.template_top_wrapper(homepage)
		top = <<-DOCUMENT
			<!DOCTYPE html>
			<html>
			<head>
			<title><%= #{homepage.title} %></title>
			</head>
		
			<body>
				<div id="head">
					<h1><%= #{homepage.title} %></h1>
				</div>
				<div id="mid">
		DOCUMENT
		
		ERB::Util::h(top)
	end

	def self.template_slots(assigned_stories)		
		slots = []
		
		assigned_stories.each do |slot|
			label = slot.label
			wrapped_slot = <<-DOCUMENT
				<div id="#{label.dirify}" class="slot">
				<%  @#{label.dirify} = @homepage.slots.first(:conditions => {:label => "#{label}"}) %>
							<h2><%= @#{label.dirify}.story.title %></h2>
							<p><%= @#{label.dirify}.story.body %></p>
				</div>
			DOCUMENT
			slots << ERB::Util::h(wrapped_slot)
		end
		return slots
	end
	
	def self.template_bottom_wrapper
		bottom = <<-DOCUMENT
				</div>
				<div id="foot">
				</div>
			</body>			
		</html>
		DOCUMENT
		
		ERB::Util::h(bottom)
	end


#   now need to write a function that checks if the
#   file exists. if it does, it opens the file and loads
#   into the text area. otherwise, it loads in the boilerplate
#   slot code. 
#   
#   also need to write a function to save textarea code to the file
#   
#   then need to write a function that reads the file, unencodes the html, interprets the ERB, 
#   and "publishes" the raw html out to the filesystem.

  
end


# models

class Homepage < ActiveRecord::Base
	has_and_belongs_to_many :feeds
	has_many :slots
end

class Feed < ActiveRecord::Base
	has_many :stories
	has_and_belongs_to_many :homepages
end

class Slot < ActiveRecord::Base
	has_one :story
	belongs_to :homepage
end

class Story < ActiveRecord::Base
	belongs_to :feed	
	belongs_to :slot
	
	validates_presence_of :slot_id
end


# extra methods

class String
	
	def dirify
		downcase.gsub(/\W/,'_') #match non-alphanumerics
	end

end