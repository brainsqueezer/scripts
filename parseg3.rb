#!/usr/bin/ruby

require 'net/http'
require 'rexml/document'
require 'cgi'
# http://blogaliza.org/index.php?val=lblogomillo

class Feed
attr_reader :title
attr_writer :title
attr_writer :type
attr_reader :id
attr_writer :id
attr_writer :htmlUrl
attr_writer :xmlUrl
attr_reader :error
attr_writer :error

	def initialize
		@error = false
	end

	def isSpace
		return @htmlUrl.include? "spaces.msn.com"
	end

	def to_s  
		@title
	end


	def isAvaliable
		res = Net::HTTP.get_response(URI.parse(@xmlUrl))
		ok = (res.code =~ /2|3\d{2}/ )
		return ok
	end 

	def update
		updateUrl = "http://www.aific.org/update/blogs/"+@id
		begin
			xml_data = Net::HTTP.get_response(URI.parse(updateUrl)).body
		rescue SocketError
			print "SocketError"
			raise
		end

		doc = REXML::Document.new(xml_data)

		doc.elements.each('result/update') do |ele|
		#@error = data.include? "404"

		#print @title+"\n"
		print "title: "+ele.attributes['title']+"\n"
		print "id: "+ele.attributes['id']+"\n"
		print "count: "+ele.attributes['count']+"\n"
		print "error: "+ele.attributes['error']+"\n"
		print "\n"
		end

	end


	def Feed.updateAll
		url = 'http://www.aific.org/api/opml'
begin
		xml_data = Net::HTTP.get_response(URI.parse(url)).body
		# extract event information
		doc = REXML::Document.new(xml_data)
		feeds = []
		doc.elements.each('opml/body/outline') do |ele|

			feed = Feed.new
			feed.title = ele.attributes['text']
			feed.type = ele.attributes['type']
			feed.id = ele.attributes['id']
			feed.htmlUrl = CGI::unescape(ele.attributes['htmlUrl'])
			feed.xmlUrl = CGI::unescape(ele.attributes['xmlUrl'])
			feeds << feed
		end
rescue TimeoutError
print "TimeoutError en la 65"

end

		feeds.each do |feed|
			if !feed.error
				 feed.update
				 sleep(5)
			 end
		end

	end
end


while 2 > 1 do
	Feed.updateAll
end


#/usr/lib/ruby/1.8/net/http.rb:560:in `initialize': getaddrinfo: Name or service not known (SocketError)
#        from /usr/lib/ruby/1.8/net/http.rb:560:in `open'
#        from /usr/lib/ruby/1.8/net/http.rb:560:in `connect'
#        from /usr/lib/ruby/1.8/timeout.rb:53:in `timeout'
#        from /usr/lib/ruby/1.8/timeout.rb:93:in `timeout'
 #       from /usr/lib/ruby/1.8/net/http.rb:560:in `connect'
 #       from /usr/lib/ruby/1.8/net/http.rb:553:in `do_start'
#        from /usr/lib/ruby/1.8/net/http.rb:542:in `start'
#        from /usr/lib/ruby/1.8/net/http.rb:379:in `get_response'
 #       from ./parseg3.rb:39:in `update'
#        from ./parseg3.rb:79:in `updateAll'
#        from ./parseg3.rb:77:in `each'
#        from ./parseg3.rb:77:in `updateAll'
#        from ./parseg3.rb:88
