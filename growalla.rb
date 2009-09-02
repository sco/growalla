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
