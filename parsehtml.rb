#!/usr/bin/ruby

require 'net/http'
require 'rexml/document'
require 'cgi'
require 'iconv'



# w3m -dump -T text/html tagling.php3 | tagling
#http://www.oblomovka.com/code/tagling.php3

# eliminar comentarios html
# self.gsub!(/\<![ \r\n\t]*(--([^\-]|[\r\n]|-[^\-])*--[ \r\n\t]*)\>/, '')

require 'cgi' #yte
require 'rexml/document' #yte
require 'net/http' #yte


class Extractor

attr_reader :texto
attr_writer :texto


	def initialize(url)
		@texto = Net::HTTP.get_response(URI.parse(url)).body
#line = Iconv.conv('iso-8859-1', 'utf-8', line)
	end

	def striphtml()
		line = self.body
		line = line.gsub(/\n/, ' ')
		line = line.gsub(/<[^>]+>/, "\n")
		line = line.gsub(/  /, ' ')
		line = line.gsub(/\n \n/, '\n')
	end


	def process()
		#puts "What is the name and path of the file?"
		#filename = gets.chomp
		#text = String.new
		#File.open(filename) { |f| text = f.read }

		words = @texto.split(/[^a-zA-Z]/)
		freqs = Hash.new(0)
		words.each { |word| freqs[word] += 1 }
		freqs = freqs.sort_by {|x,y| y }
		freqs.reverse!
		freqs.each {|word, freq| puts word+" "+freq.to_s}
		return freqs
	end


	def images()
		regex =/(<img\s.+?>)/i
		results = @texto.scan(regex)
		p results.size
 
		results.each { |result|
			print result
			print "\n"
		}
	end

	def title()
		regex =/<title>(.*)<\/title>/i
		results = @texto.scan(regex)
		#p results.size
 
		return results[0][0]
	end

	def body()
		regex =/<body>(.*)<\/body>/i
		results = @texto.scan(regex)
		p results.size
 
		return results[0]
	end

	def emails()
		regex = /([a-z0-9_.-]+)@([a-z0-9-]+)\.[a-z.]+/i
	end


	def yte()
		appid = 'tagling1.0'
		api_uri = URI.parse('http://api.search.yahoo.com/ContentAnalysisService/V1/termExtraction')

		#text = STDIN.read 
		i = Net::HTTP.post_form(api_uri, { 'appid' => appid, 'context' => @texto  } )

		i = REXML::Document.new i.body

		i.each_element("//Result") do |a| 
			t = a.text
			print t+"\n"
		#	puts case ARGV[0] 
			#when '-txt' then t
			#else  %(<a href="http://technorati.com/tag/#{CGI.escape(t)}" rel="tag">#{t}</a>)
			#end
		end

	end


end










url ="http://www.lavozdegalicia.es/especiales2009/eleccionesgallegas/2009/02/20/0003_7542372.htm"

#print data

e = Extractor.new(url)
#strip = e.striphtml(line)
#print strip+"\n"
print "title: "
print e.title
print "\n"


print "body: "
print e.body
print "\n"


e.images()
e.yte

 