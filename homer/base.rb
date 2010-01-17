require 'erb'
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
end


# extra methods

class String
	
	def dirify
		downcase.gsub(/\W/,'_') #match non-alphanumerics
	end

end