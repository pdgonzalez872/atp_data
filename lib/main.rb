require 'nokogiri'
require 'open-uri'
require 'pry'

# page = File.open("rankings.htm")
#:puts page

dummy_path = "#{Dir.pwd}/lib/rankings.html"

page = File.open(dummy_path, "r")

doc = Nokogiri::HTML(page)

# This gives the href for Djoko
# doc.css('td.player-cell').first.children[1]['href']

# this is the root url
root_url = "http://www.atpworldtour.com"

urls = []

doc.css('td.player-cell').each do |row|
  urls << row.children[1]['href']
end

urls.each do |url|
  puts "#{root_url}#{url}"
end
