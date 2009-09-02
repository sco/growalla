# growalla.rb
# Growl notifications for Gowalla checkins.
#
# Specifically: sets up a local web app using Sinatra, tunnels it out through
# ReverseHTTP using Hookout, subscribes to PubSubHubbub notifications for your
# Gowalla friends feed, and shells out to growlnotify for each notifcation.
#
# USAGE:
#  1. Install Growl and growlnotify (from the Extras folder): http://growl.info/
#  2. Install prerequisite gems:
#     $ gem sources -a http://gems.github.com
#     $ sudo gem install sinatra thin paulj-hookout
#  3. Start it (with your Gowalla username, not mine):
#     $ ruby growalla.rb sco
#
#
# TODO:
# - include checkin comments
# - download the spot image and/or user image
# - auto-discover the hub
# - say each of the summaries, not just the last
# - check that growlnotify exists
#
require 'rubygems'
require 'sinatra'
require 'hookout'
require "rexml/document"

feed = "http://gowalla.com/users/#{ARGV[0]}/friends_visits.atom"
set :server, 'hookout'
set :host, 'http://www.reversehttp.net/reversehttp'
set :port, "gowalla-friends-#{ARGV[0]}"

configure do
  Net::HTTP.post_form(URI::parse('http://pubsubhubbub.appspot.com/subscribe'), {
    'hub.topic'    => feed,
    'hub.callback' => "http://gowalla-friends-#{ARGV[0]}.www.reversehttp.net/",
    'hub.mode'     => 'subscribe',
    'hub.verify'   => 'async',
  })
end

get '/' do
  `/usr/local/bin/growlnotify -m "Watching #{feed}"`
  params['hub.challenge']
end

post '/' do
  doc = REXML::Document.new(request.body.string)
  summary = doc.root.elements["entry/summary"].text
  `/usr/local/bin/growlnotify -m "#{summary}"` # --image "/Users/sco/work/gowalla-web/public/images/temp/avatar.png"
end
