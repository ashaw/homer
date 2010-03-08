require 'erb'
require 'ftools'
require 'open-uri'
require 'active_record'
require 'feedme' #for atom/rss parsing


class Homer

	def self.version
		'0.1.2'
	end
		
	def self.get_feed(url)
		file = open(url).read
		feed = FeedMe.parse(file)
		entries = feed.entries
	end

	# boilerplate template code
	
	def self.template_top_wrapper(homepage)
 top = <<-DOCUMENT

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
            "http://www.w3.org/TR/html4/loose.dtd">
<html>
 <head>
 <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
 <title><%= @homepage.title %></title>
 </head>
		
 <body>
 <div id="head">
  <h1><%= @homepage.title %></h1>
 </div>
 <div id="mid">
		DOCUMENT
		
		ERB::Util::h(top)
	end

	def self.template_slots(slots)		
		wrapped_slots = []
		
		slots.each do |slot|
			label = slot.label
			label_instance_var = label.dirify.gsub(/^(\d)/,'_\1') #numbers can't start instance vars

			wrapped_slot = <<-DOCUMENT
 
 <div id="#{label.dirify}" class="slot">
  <%  @#{label_instance_var.dirify} = Ho.new(@homepage,'#{label}') %>
  <h2><a href="<%= @#{label_instance_var}.url %>"><%= @#{label_instance_var}.title %></a></h2>
  <p><%= @#{label_instance_var}.body %></p>
 </div>
			
			DOCUMENT
			wrapped_slots << ERB::Util::h(wrapped_slot)
		end
		return wrapped_slots
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
	
	# if we already have a file, open it, and print in the textarea
	# otherwise, go straight to the boilerplate
	def self.check_for_template(homepage)
		filename = Homepage.find(homepage).title.dirify
		template = "#{SINATRA_ROOT}/templates/#{filename}.erb"
		if File.exists?(template)
			f = File.open(template, "r")
			return f
		else
			return false
		end
	end
	
	# save template
	def self.save_template(html,homepage)
		filename = Homepage.find(homepage).title.dirify
		template = "#{SINATRA_ROOT}/templates/#{filename}.erb"
		
			f = File.new(template, "w+")
				f.write html	
			f.close
	end
	
	#reset template
	def self.reset_template(homepage)
		filename = Homepage.find(homepage).title.dirify
		template = "#{SINATRA_ROOT}/templates/#{filename}.erb"

		f = File.delete(template)
	end

   
	#  read the file, unencode the html, interpret the ERB, 
	#  and "publish" the raw html out to the filesystem.
	
	def self.publish_homepage(homepage)
		@homepage = Homepage.find(homepage)
		filename = @homepage.title.dirify
		template = "#{SINATRA_ROOT}/templates/#{filename}.erb"
		destination = @homepage.path
		
		begin
			f = File.open(template)
			
			rescue Errno::ENOENT 
				raise "you must <a href='/template/#{@homepage.id}'>generate a template</a> and save it before you can publish!"
		end
		
		@s = ""
		
		f.each do |line|
			@s << ERB.new(line).result(binding) rescue nil
		end
		
		published_file = File.new("#{destination}", "w+")
		published_file.write(@s)
		published_file.close
		f.close
	end
  
	def self.error_wrapper(msg)
	error = <<DOCUMENT
<div class="error">
	<h1>Error</h1>
	<ul>
		<li>#{msg}</li>
	</ul>
</div>
<input class="error_accept" type="submit" value="OK!">
DOCUMENT
	end

end

# Ho is for templating in Homer
# Usage:
#  <% left = Ho.new(@homepage,'left') %>
#   <%= left.title %>
#   <%= left.body %>
#   <%= left.url %>

class Ho

	def initialize(homepage,slot)
		@homepage = Homepage.find(homepage)
		@slot = @homepage.slots.first(:conditions => {:label => slot})
	end
	
	def title 
		@slot.story.title
	end
	
	def body 
		@slot.story.body
	end
	
	def url
		@slot.story.permalink
	end
	
end



# models

class Homepage < ActiveRecord::Base
	has_and_belongs_to_many :feeds
	has_many :slots, :dependent => :destroy
	
	validates_presence_of :title
	validates_presence_of :path
	
	before_create :check_path
	
	#validate homepage publish path
	#todo, make this more comprehensive
	def check_path
		path = self.path
		dir = path.match(/^(.+)\//)[0] # /foo/bar/index.html -> /foo/bar/
		begin
			if File::exists?(path)
				raise 'There\'s already a file in that location'
			end
		end
	end

end

class Feed < ActiveRecord::Base
	has_many :stories
	has_and_belongs_to_many :homepages
	
	validates_presence_of :title
	validates_presence_of :url
	validate :url_is_valid_feed
	
  # validate url format, then check to see if it is a valid URL, and valid XML feed
  # based on http://actsasblog.wordpress.com/2006/10/16/url-validation-in-rubyrails/
  def url_is_valid_feed
		begin
			uri = URI.parse(url)
			if uri.class != URI::HTTP
				errors.add(:url, '- Make sure your feed url starts with http://')
			
			else #should know the url is well-formed now, and can check for valid url and valid xml
					begin
					u = open(uri)
						rescue OpenURI::HTTPError
							raise "There's nothing at that feed URL. Maybe you mistyped it?"
					end
					if u.content_type.match(/xml/).nil?
						errors.add(:url, '- That does not look like a valid XML, RSS or ATOM feed.')
						# at this point, maybe we should crawl the page for autodetect tags and make a suggestion?

					end
			end #otherwise let's say why this is a fail
			rescue URI::InvalidURIError 
				errors.add(:url, '- that doesn\'t look like a valid url.')
		end
	end		
end

class Slot < ActiveRecord::Base
	has_one :story
	belongs_to :homepage
	
	validates_presence_of :label
end

class Story < ActiveRecord::Base
	belongs_to :feed	
	belongs_to :slot
	before_create :bump_slot

	# bump_slot is a replacement for validates_uniqueness_of
	# if checks to see if a story is already assigned to a desired slot
	# and bumps it out in favor of your new story
	def bump_slot
		filled_slots = Slot.all.collect { |s| s.story }.collect { |q| q.slot_id rescue nil }.select { |v| v if not v.nil? }

		slot = self.slot_id
		if filled_slots.include?(slot)
			bumped_story = Story.first(:conditions => {:slot_id => slot})
			bumped_story.slot_id = nil
			bumped_story.save!
		end
	
	end

end


# extra methods

class String
	
	def dirify
		downcase.gsub(/\W/,'_') #match non-alphanumerics
	end

end