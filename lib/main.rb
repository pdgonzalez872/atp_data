require 'nokogiri'
require 'open-uri'

# page = File.open("rankings.htm")
#:puts page

dummy_path = "#{Dir.pwd}/lib/rankings.html"

page = File.open(dummy_path, "r")

stuff = Nokogiri::HTML(page)
puts stuff
