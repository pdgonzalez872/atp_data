require 'nokogiri'
require 'open-uri'
require 'pry'

# page = File.open("rankings.htm")
#:puts page

# Rankings url
# http://www.atpworldtour.com/en/rankings/singles?rankDate=2016-10-03&rankRange=1-5000

module DummyRun
  def self.run

    page = File.open(path, "r")
    doc = Nokogiri::HTML(page)
    root_url = "http://www.atpworldtour.com"

    urls = gather_urls_from(doc: doc, root_url: root_url)

    urls.each do |url|
      puts url
    end
  end

  def self.path
    "#{Dir.pwd}/lib/rankings.html"
  end

  def self.gather_urls_from(doc:, root_url:)
    urls = []
    doc.css('td.player-cell').each_with_index do |row, i|
      urls << "#{root_url}#{row.children[1]['href']}"
    end
    urls
  end
end

DummyRun.run
