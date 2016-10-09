require_relative 'atp_data_gatherer'

start = Time.now

class Manager
  def self.fetch_rankings_for(page:, on_date:)
    puts "Fetching rankings"
    time_before_ranking_request = Time.now
    urls = ATPDataGatherer.fetch_data_for(page: page) # remote_page trigger is here
    time_after_ranking_request = Time.now
    puts "Fetching complete, took #{time_after_ranking_request - time_before_ranking_request} seconds"
    urls
  end

  def self.create_player_urls_file(urls:)
    puts "Creating player urls file"
    urls_file = File.open("#{Dir.pwd}/data/player_urls.txt", "w+") do |f|
      f.puts(urls)
    end
    puts "Created File"
    urls_file
  end

  def self.create_player_data_file(file_path:)
    puts "Creating player data file"
    File.open(file_path, "w+") do |f|
      f.puts "ranking,first_name,last_name,country,birthday,prize_money"
    end
    puts "Created File"
    true
  end

  def self.gather_all_players_data(urls:, player_file:)

    puts "Iterating through urls and parsing each single player page"
    urls.each do |url|

      time_before_each_url = Time.now

      data = ATPDataGatherer.parse_player_page(player_page: open(url))
      File.open(player_file, "a") do |f|
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
  end
end

def remote_page(date:)
  open("http://www.atpworldtour.com/en/rankings/singles?rankDate=#{date}&rankRange=1-5000")
end

local_page = File.open("#{Dir.pwd}/spec/support/rankings.html", "r")
player_data_csv = "#{Dir.pwd}/data/player_data_20161003.csv"

urls = Manager.fetch_rankings_for(page: local_page, on_date: Date.new)
# urls = Manager.fetch_rankings_for(page: remote_page, on_date: Date.new)

urls_file = Manager.create_player_urls_file(urls: urls)

Manager.create_player_data_file(file_path: player_data_csv)

Manager.gather_all_players_data(urls: urls, player_file: player_data_csv)

puts 'Metrics'
finish = Time.now
puts finish - start
