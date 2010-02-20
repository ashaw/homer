require 'rake'
require 'homer'

namespace :homer do
	desc "initialize homer database"
		task :init do
		#set up the db
		
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
		
		#make the templates directory
		FileUtils.mkdir "#{SINATRA_ROOT}/templates"
	end
end
