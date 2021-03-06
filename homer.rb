# Homer makes Homepages
# by Al Shaw

require 'rubygems'
require 'sinatra'
require File.dirname(__FILE__) + '/homer/base'
require File.dirname(__FILE__) + '/config'

# controller

##
# showing stuff
##

get '/' do
	@homepages = Homepage.find(:all)
	@feeds = Feed.find(:all)
	@title = "Homer | Home"
	
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
		
		@title = "Homer | #{@homepage.title}"
		@assigned_stories = @homepage.slots.select {|q| q if (q.story) }
		@slots = @homepage.slots
		
		erb :manage_homepage
end

get '/feeds/:hpid/:fid' do
	@homepage = Homepage.find(params[:hpid])
	@feed = Feed.find(params[:fid])
	@url = @feed.url	
	@payload = Homer.get_feed(@url)
	
	@slots = @homepage.slots.find(:all)
	erb :feed, :layout => false
end

get '/homepage/:hpid/preview' do
	@homepage = Homepage.find(params[:hpid])
	@title = "Homer | Previewing #{@homepage.title}"
	filename = @homepage.title.dirify
	template = "#{SINATRA_ROOT}/templates/#{filename}.erb"
	
	begin
		f = File.open(template)
			rescue Errno::ENOENT 
				raise "You need to save a fresh template before you can preview it! <a href=\"javascript:window.close()\">Close</a>."	
	end
	
	@s = ""
		f.each do |line|
			@s << ERB.new(line).result(binding) rescue nil
		end
	
	erb @s, :layout => :preview
end

##
# creating stuff
##

get '/homepage/new' do
	@title = "Homer | New Homepage"

	erb :new_homepage
end

get '/homepage/:hpid/edit' do
	@homepage = Homepage.find(params[:hpid])
	@title = "Homer | Edit #{@homepage.title}"

	
	erb :edit_homepage
end

post '/homepage/:hpid/save' do
	@homepage = Homepage.find(params[:hpid])
	
	if @homepage.update_attributes(params[:homepage])
			redirect '/'
	else
			@title = "Error!"
			@errors = @homepage.errors
			erb :db_error
	end
end

get '/homepage/:hpid/destroy' do
	@homepage = Homepage.find(params[:hpid])
	
	@homepage.destroy
	
	redirect '/'
end

post '/homepage/new' do
	@homepage = Homepage.new(params[:homepage])
	
	if @homepage.save
		redirect '/'
	else
			@title = "Error!"
			@errors = @homepage.errors
			erb :db_error
	end
end

get '/feed/new' do
	@title = "Homer | New Feed"

	erb :new_feed
end

post '/feed/new' do
	@feed = Feed.new(params[:feed])
	
	if @feed.save
			redirect '/'
	else
			@title = "Error!"
			@errors = @feed.errors
			erb :db_error
	end
	
end

get '/feed/:fid/edit' do
	@feed = Feed.find(params[:fid])
	@title = "Homer | Edit #{@feed.title}"

	
	erb :edit_feed
end

post '/feed/:fid/save' do
	@feed = Feed.find(params[:fid])
	
	if @feed.update_attributes(params[:feed])
			redirect '/'
	else
			@title = "Error!"
			@errors = @feed.errors
			erb :db_error
	end
end

get '/feed/:fid/destroy' do
	@feed = Feed.find(params[:fid])
	
	@feed.destroy
	
	redirect '/'
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

post '/hpfeed/remove' do	
	@homepage_id = params[:homepage_feed][:homepage_id]
	@feeds = params[:homepage_feed][:feed_ids] || []
	
	@feeds.each do |feed_id|
		 Homepage.find(@homepage_id).feeds.delete(Feed.find(feed_id))
	end
	
	#if @feeds.save
		redirect "/#{@homepage_id}"
	#end
end

post '/hpslot/new' do
	@slot = Slot.new(params[:homepage_slot])
	
	if @slot.save
		redirect back
	else
			@title = "Error!"
			@errors = @slot.errors
			erb :db_error
	end
end

post '/hpslot/remove' do
	@homepage_id = params[:homepage_slot][:homepage_id]
	@slots = params[:homepage_slot][:slot_ids] || []
	
	@slots.each do |slot_id|
		 Slot.find(slot_id).destroy
	end
	
	#if @feeds.save
		redirect back
	#end
end

post '/story/new' do
	@stories = params[:story].values.collect {|story| Story.new(story)}
	@stories.each do |story|
		if story.slot
			story.save!
		end
	end
	
	#if @story.save
		redirect back
	#end
end

post '/homepage/:hpid/rearrange' do
	@homepage = Homepage.find(params[:hpid])
	@stories = params[:story]
	
	Story.update(@stories.keys,@stories.values)

	
	redirect back
end

get '/template/:hpid' do
	@homepage = Homepage.find(params[:hpid])
	@slots = Homepage.find(@homepage.id).slots
	@title = "Homer | Templating #{@homepage.title}"
	@stock_code = ""
	
	if Homer.check_for_template(@homepage.id) == false
		@stock_code << Homer.template_top_wrapper(@homepage.id)
		Homer.template_slots(@slots).each do |slot|
			@stock_code << slot
		end
		@stock_code << Homer.template_bottom_wrapper
	else
		Homer.check_for_template(@homepage.id).each do |line|
			@stock_code << line
		end
	end
	
	@stock_code = @stock_code.strip
	
	erb :generate_template
end

post '/template/:hpid' do
	@homepage = params[:template][:homepage]		
	@html = params[:template][:html]
	
	Homer.save_template(@html,@homepage)
	
	redirect back
end

get '/template/:hpid/reset' do
	@homepage = Homepage.find(params[:hpid])
	Homer.reset_template(@homepage.id)
	
	redirect back
end

get '/homepage/:hpid/publish' do
	@homepage = params[:hpid]
	
	Homer.publish_homepage(@homepage)
	
	redirect back
end


##
# tidying up stuff
##

not_found do
	msg = "404. go <a href=\"/\">home(r)</a>"
	error = Homer.error_wrapper(msg)
	
	erb error
end

error do
	error = Homer.error_wrapper(request.env['sinatra.error'])
	erb error
end

error ActiveRecord::StatementInvalid do
	erb "<div class=\"error\">Homer can't find the database! This probably means you haven't created it yet or have incorrect permissions set. Quit homer and run <code>homer init</code> to get started.</div>"
end