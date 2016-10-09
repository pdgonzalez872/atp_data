require 'nokogiri'
require 'open-uri'

# page = File.open("rankings.htm")
#:puts page

dummy_path = "#{Dir.pwd}/lib/rankings.html"

File.open(dummy_path, "r") do |f|
  f.each_line do |line|
    puts line
  end
end

#stuff = Nokogiri::HTML("rankings.htm")
#puts stuff
