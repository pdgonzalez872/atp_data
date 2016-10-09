require 'nokogiri'
require 'open-uri'

# page = File.open("rankings.htm")
#:puts page

File.open("test.txt", "r") do |f|
  f.each_line do |line|
    puts line
  end
end

#stuff = Nokogiri::HTML("rankings.htm")
#puts stuff
