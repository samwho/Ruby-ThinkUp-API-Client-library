require 'sinatra'
require 'cgi'
require File.dirname(__FILE__) + '/thinkup_api.rb'

$thinkup = ThinkUpAPI.new("http://localhost:80/projects/ThinkUp/webapp/")

def format_posts(posts)
  if posts.nil?
    CGI.escapeHTML($thinkup.inspect)
  else
    output = ''
    posts.each do |post|
      output += post['user']['screen_name'] + ": " + post['text'] + "<br />"
    end

    output
  end
end

get '/user_posts/:username' do
  format_posts($thinkup.get_user_posts(params[:username], params))
end

get '/user_questions/:username' do
  format_posts($thinkup.get_user_questions(params[:username], params))
end

get '/user_replies/:username' do
  format_posts($thinkup.get_user_replies(params[:username], params))
end

get '/user_mentions/:username' do
  format_posts($thinkup.get_user_mentions(params[:username], params))
end

get '/most_replied_to/:username' do
  format_posts($thinkup.get_user_posts_most_replied_to(params[:username], params))
end

get '/most_retweeted/:username' do
  format_posts($thinkup.get_user_posts_most_retweeted(params[:username], params))
end

get '/post/:post_id' do
  format_posts($thinkup.get_post(params[:post_id], params))
end

get '/post_replies/:post_id' do
  format_posts($thinkup.get_post_replies(params[:post_id], params))
end

get '/post_retweets/:post_id' do
  format_posts($thinkup.get_post_retweets(params[:post_id], params))
end

get '/related_posts/:post_id' do
  format_posts($thinkup.get_related_posts(params[:post_id], params))
end