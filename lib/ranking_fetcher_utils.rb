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

  # order file by prizemoney
  # return Boolean
  def self.order_by_prize_money(file:)
    player_data = []
    headers = ""

    File.open(file, 'r') do |f|
      headers = f.gets.chomp

      f.each_line do |line|
        player_data << parse_player_data(line: line)
      end
    end

    # duplication here, can be dried out -> pass a w,r,a, arg and if from there?
    File.open(file, "w+") do |f|
      f.puts headers
      sorted_array = sort_array_of_hashes(array_of_hashes: player_data)
      sorted_array.each do |data|
        f.puts("#{data['ranking']}," \
               "#{data['first_name']}," \
               "#{data['last_name']}," \
               "#{data['country']}," \
               "#{data['birthday']}," \
               "#{data['prize_money']}")
      end
    end
    true
  end

  # return Hash
  def self.parse_player_data(line:)
    data = {}
    temp = line.delete("\n").split(",")

    data['ranking']     = temp[0]
    data['first_name']  = temp[1]
    data['last_name']   = temp[2]
    data['country']     = temp[3]
    data['birthday']    = temp[4]
    data['prize_money'] = temp[5].to_i
    data
  end

  # return Array
  def self.sort_array_of_hashes(array_of_hashes:)
    array_of_hashes.sort_by { |hsh| -hsh['prize_money'] }
  end
end

# one time use -> order all files
# Dir.glob("data/*.csv") { |file| puts RankingFetcherUtils.order_by_prize_money(file: file)}
