require_relative 'atp_data_gatherer'

start = Time.now

def remote_page(date:)
  open("http://www.atpworldtour.com/en/rankings/singles?rankDate=#{date}&rankRange=1-5000")
end

local_page = File.open("#{Dir.pwd}/spec/support/rankings.html", "r")
player_data_csv = "#{Dir.pwd}/data/player_data_20161003.csv"


puts "Fetching rankings"
#urls = ATPDataGatherer.fetch_data_for(page: local_page) # remote_page trigger is here
time_before_ranking_request = Time.now
urls = ATPDataGatherer.fetch_data_for(page: remote_page(date:'2016-10-03')) # remote_page trigger is here
time_after_ranking_request = Time.now
puts "Fetching complete, took #{time_after_ranking_request - time_before_ranking_request} seconds"


puts "Creating file"
File.open(player_data_csv, "w+") do |f|
  f.puts "ranking,first_name,last_name,country,birthday,prize_money"
end
puts "File created"

puts "Iterating through urls and parsing each single player page"
urls.each do |url|

  time_before_each_url = Time.now

  data = ATPDataGatherer.parse_player_page(player_page: open(url))
  File.open(player_data_csv, "a") do |f|
    f.puts("#{data['ranking']}," \
           "#{data['first_name']}," \
           "#{data['last_name']}," \
           "#{data['country']}," \
           "#{data['birthday']}," \
           "#{data['prize_money']}")
    puts("#{data['ranking']}," \
         "#{data['first_name']}," \
         "#{data['last_name']}," \
         "#{data['country']}," \
         "#{data['birthday']}," \
         "#{data['prize_money']}")
  end
  time_after_each_url = Time.now
  puts "Took #{time_after_each_url - time_before_each_url} seconds"
end
puts "Iteration complete"

puts 'Metrics'
finish = Time.now
puts finish - start
