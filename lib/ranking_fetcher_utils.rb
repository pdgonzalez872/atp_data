class RankingFetcherUtils

  def self.create_player_data_file(file_path:)
    puts "Creating player data file"
    file = File.open(file_path, "w+") do |f|
      f.puts "ranking,first_name,last_name,country,birthday,prize_money"
    end
    puts "Created File"
  end

  def self.write_data_to_file(file_path:, data:)
    puts "Writing to players data file"
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
    puts "Finished writing to file"
  end

  def self.filepath_with_date(date:)
    "#{Dir.pwd}/data/player_data_#{date.gsub('-', '')}.csv"
  end


  def self.remote_page(date:)
    open("http://www.atpworldtour.com/en/rankings/singles?rankDate=#{date}&rankRange=1-5000")
  end

  def self.get_past_weeks_monday(date: nil)
    # Use dependency injection to make it easier to test
    current_date = date || Date.today
    return  current_date.strftime("%Y-%m-%d") if current_date.monday?

    while current_date.monday? == false
      current_date = current_date - 1
    end
    current_date.strftime("%Y-%m-%d")
  end

  # order file by amount won method
  def self.order_by_prize_money(file:)
  end

  def self.parse_player_data
end
