class RankingFetcherUtils

  def self.filepath_with_date(date:)
    "#{Dir.pwd}/data/player_data_#{date.gsub('-', '')}.csv"
  end


  def self.remote_page(date:)
    open("http://www.atpworldtour.com/en/rankings/singles?rankDate=#{date}&rankRange=1-5000")
  end

  def self.get_past_weeks_monday(date: nil)
    binding.pry
    current_date = date || Date.today
    return  current_date.strftime("%Y-%m-%d") if current_date.monday?

    while current_date.monday? == false
      current_date = current_date - 1
    end
    current_date.strftime("%Y-%m-%d")
  end
end
