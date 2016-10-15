require_relative 'atp_data_gatherer'
require 'thread'

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

  # currently not used
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
    file = File.open(file_path, "w+") do |f|
      f.puts "ranking,first_name,last_name,country,birthday,prize_money"
    end
    puts "Created File"
    true
  end

  def self.gather_all_players_data(urls:)
    # good resource: https://www.toptal.com/ruby/ruby-concurrency-and-parallelism-a-practical-primer
    puts "Iterating through urls and parsing each single player page"

    # May need to find a large number to divide here so I can find the best number to make this whole
    # 2061/9 = 229
    #
    # Maybe create as many jobs as necessary
    pool_size = 9
    semaphore = Mutex.new

    jobs = Queue.new

    urls.each do |i|
      jobs.push(i)
    end

    all_data = []

    workers = (pool_size).times.map do |worker|
      thr = Thread.new(urls, all_data) do |urls, all_data|
        begin
          while url = semaphore.synchronize { jobs.pop }
            time_before_each_url = Time.now
            # data = url
            data = ATPDataGatherer.parse_player_page(player_page: open(url))
            semaphore.synchronize do
              info = ("#{data['ranking']}," \
                   "#{data['first_name']}," \
                   "#{data['last_name']}," \
                   "#{data['country']}," \
                   "#{data['birthday']}," \
                   "#{data['prize_money']}")
              all_data << data
              time_after_each_url = Time.now
              puts "Took #{time_after_each_url - time_before_each_url} secs #{url} in worker ##{worker} - #{info}"
            end
          end
        rescue ThreadError
        end
      end
    end

    workers.each do |worker|
      worker.join(35) # increase time to join here?
    end
    puts "Iteration complete"
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

  def self.linear_fetch_for(output_file_path:, urls:)
    puts "Creating output file"
    File.open(output_file_path, "w+") do |f|
      f.puts "ranking,first_name,last_name,country,birthday,prize_money"
    end
    puts "Output file created"

    puts "Iterating through urls and parsing each single player page"
    urls.each do |url|

      time_before_each_url = Time.now

      data = ATPDataGatherer.parse_player_page(player_page: open(url))
      File.open(output_file_path, "a") do |f|
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

def threading
  all_data = Manager.gather_all_players_data(urls: urls)
  Manager.create_player_data_file(file_path: player_data_csv)
  Manager.write_players_data_to_file(file_path: player_data_csv, all_data: all_data)

  puts 'Metrics'
  puts all_data.length
  finish = Time.now
  puts finish - start
end

local_page = File.open("#{Dir.pwd}/spec/support/rankings.html", "r")
player_data_csv = "#{Dir.pwd}/data/player_data_20161010.csv"
ranking_date = '2016-10-10'

# urls = Manager.fetch_rankings_for(page: local_page, on_date: Date.new)
urls = Manager.fetch_rankings_for(page: remote_page(date: ranking_date), on_date: Date.new)
Manager.linear_fetch_for(output_file_path: player_data_csv, urls: urls)


