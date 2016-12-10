require_relative 'atp_data_gatherer'
require 'thread'
require 'rubygems'
require 'active_support'
require 'active_support/time'
require 'pry'

class Manager
  def self.fetch_rankings_for(page:, on_date:)
    puts "Fetching rankings"
    time_before_ranking_request = Time.now
    urls = ATPDataGatherer.fetch_data_for(page: page)
    time_after_ranking_request = Time.now
    puts "Fetching complete, took #{time_after_ranking_request - time_before_ranking_request} seconds"
    urls
  end

  def self.create_player_data_file(file_path:)
    puts "Creating player data file"
    file = File.open(file_path, "w+") do |f|
      f.puts "ranking,first_name,last_name,country,birthday,prize_money"
    end
    puts "Created File"
    file
  end

  def self.gather_all_players_data(urls:, pool_size:)

    # vars
    jobs_mutex   = Mutex.new
    result_mutex = Mutex.new
    all_data = []

    workers = (pool_size).times.map do |worker|
      thr = Thread.new(urls, all_data) do |urls, all_data|

        url = nil

        while jobs_mutex.synchronize { url = urls.pop }
          time_before_each_url = Time.now

          data = ATPDataGatherer.parse_player_page(player_page: open(url))

          info = "#{data['ranking']}," \
                 "#{data['first_name']}," \
                 "#{data['last_name']}," \
                 "#{data['country']}," \
                 "#{data['birthday']}," \
                 "#{data['prize_money']}"

          result_mutex.synchronize do
            all_data << data
          end

          time_after_each_url = Time.now
          puts "Took #{time_after_each_url - time_before_each_url} secs #{url} in worker ##{worker} - #{info}"
        end
      end
    end
    workers.each(&:join)
    all_data
  end

  def self.write_players_data_to_file(file_path:, all_data:)

    puts "Writing to players data file"
    File.open(file_path, "a") do |f|
      all_data.each do |data|
        f.puts("#{data['ranking']}," \
               "#{data['first_name']}," \
               "#{data['last_name']}," \
               "#{data['country']}," \
               "#{data['birthday']}," \
               "#{data['prize_money']}")
      end
    end
    puts "Finished writing"
    true
  end
end

def remote_page(date:)
  open("http://www.atpworldtour.com/en/rankings/singles?rankDate=#{date}&rankRange=1-5000")
end

def get_past_weeks_monday
  current_date = Date.current
  return if current_date.monday?

  while current_date.monday? == false
    current_date = current_date - 1
  end
  "#{current_date.year}-#{current_date.month}-#{current_date.strftime("%d")}"
end

class RankingFetcher

  attr_reader :date, :file_path

  def create_filepath
    "#{Dir.pwd}/data/player_data_#{get_past_weeks_monday.gsub('-', '')}.csv"
  end


  def remote_page(date:)
    open("http://www.atpworldtour.com/en/rankings/singles?rankDate=#{date}&rankRange=1-5000")
  end

  def get_past_weeks_monday
    current_date = Date.current
    return if current_date.monday?

    while current_date.monday? == false
      current_date = current_date - 1
    end
    "#{current_date.year}-#{current_date.month}-#{current_date.strftime("%d")}"
  end
end

# ranking_date = get_past_weeks_monday
ranking_fetcher = RankingFetcher.new
ranking_date = ranking_fetcher.get_past_weeks_monday

# player_data_csv = "#{Dir.pwd}/data/player_data_#{ranking_date.gsub('-', '')}.csv"
player_data_csv = ranking_fetcher.create_filepath #"#{Dir.pwd}/data/player_data_#{ranking_date.gsub('-', '')}.csv"
Manager.create_player_data_file(file_path: player_data_csv)

urls = Manager.fetch_rankings_for(page: remote_page(date: ranking_date), on_date: Date.new)

magic_number = 100

urls = urls.take(magic_number)

urls.each_slice(magic_number).to_a.each do |subset|
  a = Manager.gather_all_players_data(urls: subset, pool_size: subset.size)
  Manager.write_players_data_to_file(file_path: player_data_csv, all_data: a)
end

# i think the problem i when there is a greater number of threads created in the pool size than necessary
