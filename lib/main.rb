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

  def self.fetch_data_for(page:)
    doc = Nokogiri::HTML(page)
    gather_urls_from(doc: doc, root_url: "http://www.atpworldtour.com")
  end

  def self.gather_urls_from(doc:, root_url:)
    [].tap do |urls|
      doc.css('td.player-cell').each_with_index do |row, i|
        urls << "#{root_url}#{row.children[1]['href']}"
      end
    end
  end

  def self.parse_player_page(player_page:)
    doc = Nokogiri::HTML(player_page)

    player_data = {}
    player_data['first_name'] = doc.css(".player-profile-hero-name .first-name").text
    player_data['last_name'] = doc.css(".player-profile-hero-name .last-name").text
    player_data['country'] = doc.css(".player-flag-code").text
    player_data['ranking'] = raw_ranking(ranking: doc.css(".data-number").text)
    player_data['birthday'] = raw_birthday(messy_birthday: doc.css(".table-birthday").text)
    player_data['prize_money'] = raw_prize_money(doc.css('#playersStatsTable tr').last.css('td').last.children[1].attributes['data-doubles'].value)
    puts player_data
  end

  def self.raw_birthday(messy_birthday:)
    messy_birthday.gsub(/\t/, '').gsub(/\r\n/, '').gsub('(', '').gsub(')', '').gsub('.', '-')
  end

  def self.raw_ranking(ranking:)
    ranking.gsub(/\t/, '').gsub(/\r\n/, '')
  end

  def self.raw_prize_money(prize_money)
    prize_money.gsub('$', '').gsub(',', '').to_i
  end
end

Atp.call

# some sort of date handling always for Tuesdays (assume rankings are released on Mondays)
#remote_page = open("http://www.atpworldtour.com/en/rankings/singles?rankDate=2016-10-03&rankRange=1-5000")
local_page = File.open("#{Dir.pwd}/lib/rankings.html", "r")
urls = Atp.fetch_data_for(page: local_page)

urls.each do |url|
  puts url
end


Atp.parse_player_page(player_page: File.open("#{Dir.pwd}/lib/player_page_2.htm"))

# this works!
# Atp.parse_player_page(player_page: open("http://www.atpworldtour.com/en/players/juan-martin-del-potro/d683/overview"))



# work on player page
