SINATRA_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '.'))

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database =>  "#{SINATRA_ROOT}/db/homer.sqlite3"
)