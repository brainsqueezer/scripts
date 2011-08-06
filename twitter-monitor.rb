#!/usr/bin/ruby 

# requires JSON ruby gem ('gem install json') and growlnotify

require 'pp'
#require 'rubygems'
require 'json'
require 'net/http'

user = "rap@ramonantonio.net"
password = "123456789"
path = "/statuses/friends_timeline.json"
timefile = ENV["HOME"]+"/.twittercheck-date"

begin
    last = Time.parse(open(timefile).read)
rescue
    last = Time.now
end
http = Net::HTTP.new("twitter.com", 80)
http.start do |http|
    req = Net::HTTP::Get.new(path, {"User-Agent" => "mattb"})
    req.basic_auth(user, password)
    response = http.request(req)
    resp = response.body
    data = JSON.parse(resp)
    for twitter in data.select { |d| Time.parse(d["created_at"]) > last } do
        title = twitter['user']['name'].gsub("'",'`')
        msg = twitter['text'].gsub("'",'`')
# system "growlnotify -n twitter --image /Users/mattb/bin/twitter.png  -m '#{msg}' '#{title}' --sticky"
    end
end

open(timefile,"w").write(Time.now.to_s)
