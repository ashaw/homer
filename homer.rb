# Homer 0.1
# by Al Shaw

# sudo gem install shotgun, then
# shotgun ./homer.rb to reload on every request

require 'rubygems'
require 'sinatra'
require 'homer/base'
require 'config'

enable :sessions

# controller

#
# pages
#

get '/' do
	@homepages = Homepage.find(:all)
	@feeds = Feed.find(:all)
	
	if @homepages.length > 0
		erb :index
	else
		redirect '/homepage/new'
	end
end

get '/:id' do
	
	begin
		@homepage = Homepage.find(params[:id])	
		rescue ActiveRecord::RecordNotFound
			raise Sinatra::NotFound
	end
		@feeds = Feed.find(:all)
		
		if @homepage.feeds.length == 0
			@feed_prompt = true
		else
			@hpfeeds = @homepage.feeds.find(:all)
		end
	
		erb :manage_homepage
end

get '/feeds/:id' do
	@feed = Feed.find(params[:id])
	@url = @feed.url	
	@payload = Homer.get_feed(@url)
	
	erb :feed, :layout => false
end

#
# creating stuff
#

get '/homepage/new' do
	erb :new_homepage
end

post '/homepage/new' do
	@homepage = Homepage.new(params[:homepage])
	
	if @homepage.save
		redirect '/'
	end
end

get '/feed/new' do
	erb :new_feed
end

post '/feed/new' do
	@feed = Feed.new(params[:feed])
	
	if @feed.save
		redirect '/'
	end
	
end

post '/hpfeed/new' do	
	@homepage_id = params[:homepage_feed][:homepage_id]
	@feeds = params[:homepage_feed][:feed_ids] || []
	
	@feeds.each do |feed_id|
		 Homepage.find(@homepage_id).feeds << Feed.find(feed_id) 
	end
	
	#if @feeds.save
		redirect "/#{@homepage_id}"
	#end
end

post '/hpslot/new' do
	@slot = Slot.new(params[:homepage_slot])
	
	if @slot.save
		redirect "/#{@homepage_id}"
	end
end

not_found do
	'404. go <a href="/">home</a>'
end