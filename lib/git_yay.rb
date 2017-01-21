require_relative 'atp_data_gatherer'
require_relative 'ranking_fetcher_utils'
require 'thread'
require 'rubygems'
require 'pry'

date = RankingFetcherUtils.get_past_weeks_monday(date: Date.today)

system("git status")
system("git add .")
system("git commit -m '#{date}'")

