require_relative 'atp_data_gatherer'

start = Time.now

def remote_page(date:)
  open("http://www.atpworldtour.com/en/rankings/singles?rankDate=#{date}&rankRange=1-5000")
end

local_page = File.open("#{Dir.pwd}/spec/support/rankings.html", "r")
player_data_csv = "#{Dir.pwd}/data/player_data_20161003.csv"


puts "Fetching rankings"
#urls = ATPDataGatherer.fetch_data_for(page: local_page) # remote_page trigger is here
urls = ATPDataGatherer.fetch_data_for(page: remote_page(date:'2016-10-03')) # remote_page trigger is here
puts "Fetching complete"


puts "Creating file"
File.open(player_data_csv, "w+") do |f|
  f.puts "ranking,first_name,last_name,country,birthday,prize_money"
end
puts "File created"

puts "Iterating through urls and parsing each single player page"
urls.each do |url|
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
end
puts "Iteration complete"

puts 'Metrics'
finish = Time.now
puts finish - start
