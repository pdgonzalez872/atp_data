require 'nokogiri'
require 'open-uri'
require 'pry'

# page = File.open("rankings.htm")
#:puts page

# Rankings url
# http://www.atpworldtour.com/en/rankings/singles?rankDate=2016-10-03&rankRange=1-5000

module Atp

  def self.call
    puts "Fetching remote rankings"
    puts "Fetching complete"
    puts "Iterating through urls and parsing each single player page"
    puts "Iteration complete"
  end

  def self.fetch_remote
    page = open("http://www.atpworldtour.com/en/rankings/singles?rankDate=2016-10-03&rankRange=1-5000")
    doc = Nokogiri::HTML(page)

    urls = gather_urls_from(doc: doc, root_url: "http://www.atpworldtour.com")
  end

  def self.dummy_run

    page = File.open(path, "r")
    doc = Nokogiri::HTML(page)

    urls = gather_urls_from(doc: doc, root_url: "http://www.atpworldtour.com")
  end

  def self.path
    "#{Dir.pwd}/lib/rankings.html"
  end

  def self.gather_urls_from(doc:, root_url:)
    [].tap do |urls|
      doc.css('td.player-cell').each_with_index do |row, i|
        urls << "#{root_url}#{row.children[1]['href']}"
      end
    end
  end
end

Atp.call
urls = Atp.dummy_run

urls.each do |url|
  puts url
end

# work on player page
