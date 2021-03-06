#!/usr/bin/env ruby

require_relative 'atp_data_gatherer'
require_relative 'ranking_fetcher_utils'
require 'thread'
require 'rubygems'
#require 'pry'

class Manager

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

          begin
            data = ATPDataGatherer.parse_player_page(player_page: open(url))
          rescue
            puts "ERROR fetching #{url}, retrying..."
            data = ATPDataGatherer.parse_player_page(player_page: open(url))
          end

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

  def self.main(date: nil)
    slice_size = 10

    delimiter = '-'
    delimiter_size = 5

    ranking_date_string = RankingFetcherUtils.get_past_weeks_monday(date: date)
    page = RankingFetcherUtils.remote_page(date: ranking_date_string)
    file_path = RankingFetcherUtils.filepath_with_date(date: ranking_date_string)

    RankingFetcherUtils.create_player_data_file(file_path: file_path)

    puts "Fetching ranking list"
    urls = ATPDataGatherer.fetch_data_for(page: page)
    puts "#{delimiter * delimiter_size} Ranking list fetch completed"

    urls.each_slice(slice_size).to_a.each do |subset|
      puts "Gathering Data"
      data = Manager.gather_data_from_urls(urls: subset, pool_size: subset.size)
      puts "#{delimiter * delimiter_size} Gathered Data"

      RankingFetcherUtils.write_data_to_file(file_path: file_path, data: data)
    end
    RankingFetcherUtils.order_by_prize_money(file: file_path)
  end
end

start = Time.now
puts "Starting at #{start}"
# Can pass date, example below:
# date = Date.new(2017, 1, 16) # choose date
Manager.main # (date: date) # -> pass it in
puts "Took #{Time.now - start}"

# quick and dirty script to automate things
date = RankingFetcherUtils.get_past_weeks_monday(date: Date.today)
system("git status")
system("git add .")
system("git commit -m 'Fetch data for -> #{date}'")
system("git push origin master")
