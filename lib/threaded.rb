require_relative 'atp_data_gatherer'
require 'thread'
require 'rubygems'
require 'active_support'
require 'active_support/time'

start = Time.now

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

  def self.gather_all_players_data(urls:)

    # remove this later
    urls = urls.take(100)

    # vars
    pool_size = 10
    jobs_mutex   = Mutex.new
    result_mutex = Mutex.new

    puts "Starting processes for #{urls.size} urls"

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
            puts "all_data.size -> #{all_data.size}"
            all_data << data
          end

          time_after_each_url = Time.now
          puts "Took #{time_after_each_url - time_before_each_url} secs #{url} in worker ##{worker} - #{info}"
        end
      end
    end
    puts "Joining Threads"
    workers.each(&:join)
    puts "Iteration complete"
    all_data
  end

  def self.write_players_data_to_file(file_path:, all_data:)

    puts "Creating player data file"
    file = File.open(file_path, "w+") do |f|
      f.puts "ranking,first_name,last_name,country,birthday,prize_money"
    end
    puts "Created File"

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

ranking_date = get_past_weeks_monday
player_data_csv = "#{Dir.pwd}/data/player_data_#{ranking_date.gsub('-', '')}.csv"

urls = Manager.fetch_rankings_for(page: remote_page(date: ranking_date), on_date: Date.new)
all_data = Manager.gather_all_players_data(urls: urls)

Manager.write_players_data_to_file(file_path: player_data_csv, all_data: all_data)
