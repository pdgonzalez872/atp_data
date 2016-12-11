require_relative 'atp_data_gatherer'
require 'thread'
require 'rubygems'
require 'active_support'
require 'active_support/time'
require 'pry'

class Manager
  def self.fetch_rankings_for(page:)
    ATPDataGatherer.fetch_data_for(page: page)
  end

  def self.create_player_data_file(file_path:)
    file = File.open(file_path, "w+") do |f|
      f.puts "ranking,first_name,last_name,country,birthday,prize_money"
    end
    puts "Created File"
    file
  end

  def self.gather_data_from_urls(urls:, pool_size:)

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

  def self.write_data_to_file(file_path:, data:)
    File.open(file_path, "a") do |f|
      data.each do |data|
        f.puts("#{data['ranking']}," \
               "#{data['first_name']}," \
               "#{data['last_name']}," \
               "#{data['country']}," \
               "#{data['birthday']}," \
               "#{data['prize_money']}")
      end
    end
  end

  def self.main
    slice_size = 5

    delimiter = '-'

    ranking_fetcher = RankingFetcher.new
    ranking_date = ranking_fetcher.get_past_weeks_monday
    page = ranking_fetcher.remote_page(date: ranking_date)

    file_path = ranking_fetcher.filepath_with_date

    puts "Creating player data file"
    Manager.create_player_data_file(file_path: file_path)
    puts "#{delimiter * 1} File created"

    puts "Fetching ranking list"
    urls = Manager.fetch_rankings_for(page: page)
    puts "#{delimiter * 1} Ranking list fetch completed"

    # This is so we have short feedback
    # urls = urls.take(slice_size)

    urls.each_slice(slice_size).to_a.each do |subset|
      puts "Gathering Data"
      data = Manager.gather_data_from_urls(urls: subset, pool_size: subset.size)
      puts "#{delimiter * 1} Gathered Data"

      puts "Writing to players data file"
      Manager.write_data_to_file(file_path: file_path, data: data)
      puts "#{delimiter * 1} Finished writing"
    end
  end
end

class RankingFetcher

  attr_reader :date, :file_path

  def filepath_with_date
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

Manager.main

# Notes:
# i think the threading problem I was having was when there is a greater number of threads created in the pool size than necessary
