#!/usr/bin/ruby

require 'net/http'
require 'rexml/document'
require 'cgi'
require 'ftools'

#http://www.xunta.es/Dog/Dog2009.nsf/FichaContenido/B576?OpenDocument



#"A".upto("Z") do |l|

#['a','b','c','ch','d','e','f','g','h','i','j','k','l','m','n','�','o','p','q','r','s','t','u','v','w','x','y','z'].each do |l|


class Cache

# save as marshalize.rb in /usr/local/lib/ruby/1.8/ and then require 'marshalize'

TMP_DIR = "/Library/Caches/"

def marshal(filename,data=nil)
  Dir.chdir(TMP_DIR) do
    if data != nil
      open(filename, "w") { |f| Marshal.dump(data, f) }
    elsif File.exists?(filename)
      open(filename) { |f| Marshal.load(f) }
    end
  end
end

def marshal_destroy(filename)
  Dir.chdir(TMP_DIR) do
  if File.exists?(filename)
    File.delete(filename)
  else
    return "File does not exists."
  end
  end
end

def marshal_clone(data)
  filename = srand.to_s << '.tmp'
  marshal(filename,data)
  h = marshal(filename)
  marshal_destroy(filename)
  return h
end


def Cache.get(url)

	if !Cache.existe(url)
	data = Cache.write(url)
	else
	data = Cache.read(url)
	end
	 
	if data.size == 0
	data = Cache.write(url)
	end

	return data
end



def Cache.write(url)
	response = Net::HTTP.get_response(URI.parse(url))
	data = response.body
	#response.class Net::HTTPOK
	#response.code 200

	print "write: "+url+" code:"+response.code+" size:"+data.size.to_s+"\n"

	if data.size == 0
		print "size:0"
		#Process.exit
	end

	if data == ""
		print "size:0b"
		#Process.exit
	end

	filename = "/home/rap/cache/"+CGI::escape(url)
	my_file = File.new(filename, File::CREAT|File::TRUNC|File::RDWR, 0644)
	my_file.puts data
	return data
end


def Cache.existe(url)
	filename = "/home/rap/cache/"+CGI::escape(url)
	existe = File.exists?(filename) 
	return existe
end


def Cache.read(url)
	filename = "/home/rap/cache/"+CGI::escape(url)
	data=IO.read(filename)

	errortext = "ERRO DE ACCESO"
	if data.include? errortext
		print "error "
		return ""
	end
	return data
end

def Cache.read2(url)
	filename = "/home/rap/cache/"+CGI::escape(url)
	begin
	file = File.new("readfile.rb", "r")
	while (line = file.gets)
		puts "#{counter}: #{line}"
		counter = counter + 1
	end
	file.close
	rescue => err
	puts "Exception: #{err}"
	err
	end
end

end


class Doga
#print data1

#"/Dog/Dog2008.nsf/TablaMes/38F66?OpenDocument"
#mes
def Doga.getDiario()
	url1 = "http://www.xunta.es/Dog/dogpriv.nsf/TablaContenido/50A6?OpenDocument"
	data1 = Cache.get(url1)
#r1 = Regexp.new('^a-z+:\\s+\w+')           #=> /^a-z+:\s+\w+/
 #  r2 = Regexp.new('cat', true)               #=> /cat/i

	regex1 =/\/Dog\/Dog([0-9][0-9][0-9][0-9]).nsf\/TablaMes\/([A-Z0-9]*)\?OpenDocument/i

	results1 = data1.scan(regex1)
	#p results1.size
 
	#results1.each { |result|
	#	print result[0]
	#	print result[1]
	#	print "-1\n"
	#}
	return results1
end


#dia
#2000
#10B46
def Doga.getMes(id1, id2)
	url2 = "http://www.xunta.es/Dog/Dog"+id1+".nsf/TablaMes/"+id2+"?OpenDocument"
	data2 = Cache.get(url2)

	regex2 = /\/Dog\/Dog([0-9][0-9][0-9][0-9]).nsf\/IndiceSumario\/([A-Z0-9]*)\?OpenDocument/i

	results2 = data2.scan(regex2)
	#p results2.size
 
	#results2.each { |result|
	#	print result[0]
	#	print result[1]
	#	print "-2\n"
	#}
	return results2
end


#seccions
#2000
#115D2
def Doga.getDia(id1, id2)
	url3 = "http://www.xunta.es/Dog/Dog"+id1+".nsf/IndiceSumario/"+id2+"?OpenDocument"
	data3 = Cache.get(url3)
	regex3 = /\/Dog\/Dog([0-9][0-9][0-9][0-9]).nsf\/FichaSeccion\/([A-Z0-9]*)\?OpenDocument\"/i

	results3 = data3.scan(regex3)
	#p results3.size
 
	#results3.each { |result|
	#	print result[0]
	#	print result[1]
	#	print "-3\n"
	#}
	return results3
end

#fichas
#2000
#1160A
def Doga.getSeccion(id1, id2)
	url4 = "http://www.xunta.es/Dog/Dog"+id1+".nsf/FichaSeccion/"+id2+"?OpenDocument"
	data4 = Cache.get(url4)
	regex4 = /\/Dog\/Dog([0-9][0-9][0-9][0-9]).nsf\/FichaContenido\/([A-Z0-9]*)\?OpenDocument/i
	results4 = data4.scan(regex4)
	#p results4.size
 
	#results4.each { |result|
		#print result[0]
	#	print result[1]
	#	print "-4\n"
	#}
	return results4
end

#ficha
#http://www.xunta.es/Dog/Dog2007.nsf/FichaContenido/305DE?OpenDocument
def Doga.getFicha(id1, id2)
    url5 = "http://www.xunta.es/Dog/Dog"+id1+".nsf/FichaContenido/"+id2+"?OpenDocument"
	data5 = Cache.get(url5)
end
end




#diario -> meses
meses = Doga.getDiario

#meses -> dias
dias = Array.new
meses.each { |mes|
	print "Mes "+mes[0]+" "+mes[1]
	auxdias = Doga.getMes(mes[0], mes[1])
	print " Dias "+auxdias.size.to_s+"\n"
	dias = dias | auxdias
}

#dias -> secciones
secciones = Array.new
dias.each { |dia|
	print "Dia "+dia[0]+" "+dia[1]
	auxsecciones = Doga.getDia(dia[0], dia[1])
	print " Secciones "+auxsecciones.size.to_s+"\n"
	secciones = secciones | auxsecciones
}

#secciones -> fichas
fichas = Array.new
secciones.each { |seccion|
	print "Seccion "+seccion[0]+" "+seccion[1]
	auxfichas = Doga.getSeccion(seccion[0], seccion[1])
	print " Fichas "+auxfichas.size.to_s+"\n"

	fichas = fichas | auxfichas
}

#fichas
fichas.each { |ficha|
	print "Ficha "+ficha[0]+" "+ficha[1]+"\n"
	Doga.getFicha(ficha[0], ficha[1])
}