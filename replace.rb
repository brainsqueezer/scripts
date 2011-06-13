#!/usr/bin/ruby


require 'find' 
if ARGV.size < 3 || ARGV[0] == '-h'
  puts "replace.rb Finds and replaces strings in the given directory."
  puts "syntax: findreplace.rb PATH find_string replace_string [ignore_dirs]"
  exit
end

puts ARGV[0]
puts ARGV[1]
puts ARGV[2]
puts ARGV[3]

Find.find(ARGV[0]) do |file_name| 
  if File.file? file_name
    file = File.new(file_name)
    lines = file.readlines
    file.close

    changes = false
    lines.each do |line|
      changes = true if line.gsub!(/#{ARGV[1]}/, ARGV[2])
    end

    # Don't write the file if there are no changes
    if changes
      file = File.new(file_name,'w')
      lines.each do |line|
        file.write(line)
      end
      file.close
    end
  end

  Find.prune if ARGV[3] && file_name =~ /#{ARGV[3]}/  
end

