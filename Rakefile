require 'rake'
require 'homer'

namespace :homer do
	desc "initialize homer database"
		task :init do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
	end
end
