class Board
  @@colors = ['Blue', 'Red', 'Yellow', 'Green', 'Purple', 'Orange']
  @@hint_pegs = ['White', 'Black']

  def initialize
    @grid = array = Array.new(12) { Array.new(2) { Array.new(4, " ") } }
  end

   def display
    @grid.each_with_index do |row, index|
      if row[0].all? { |item| item != " " } && row[1].all? { |item| item != " " }
        attempt = index + 1
        puts "Attempt #{attempt}: " + row.to_s
      end
    end
  end

  def place_guesses(row_number, guesses)
    @grid[row_number][0] = guesses
    place_hints(row_number, guesses, @code)
  end

  def place_hints(row_number, guesses, secret)
    hints = []
    black_pegs = 0
    white_pegs = 0
    code_clone = @code.clone
    guesses.each_with_index do |guess, index|
      if code_clone.include?(guess)
        if code_clone.each_index.select { |i| code_clone[i] == guess }.include?(index)
          black_pegs+=1
          code_clone[index] = "Already Accounted"
        end
      end
    end
    guesses.each_with_index do |guess, index|
      if code_clone.include?(guess)
          white_pegs+=1
      end
    end
    for i in 1..black_pegs do
      hints.push("Black")
    end
    for i in 1..white_pegs do
      hints.push("White")
    end
    for i in 1..4-black_pegs-white_pegs do
      hints.push("Empty")
    end
    @grid[row_number][1] = hints
  end

  def secret_code
    @code = []
    for i in 1..4 do
      @code.push(@@colors[Random.rand(@@colors.length)])
    end
    @code
  end

  def guesses_valid?(guesses)
    if guesses.length == 4 && guesses.all? { |guess| @@colors.include?(guess) }
      true
    else
      false
    end
  end

  def winning_combination?(guesses)
    return false if guesses.nil?
    guesses.each_with_index.all? { |guess, index| guess == @code[index] }
  end

end

class Player
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

class Game
  def initialize
    @board = Board.new
    @player1 = Player.new("Player 1")
    @attempts = 1
    @current_player = @player1
  end

  def play
    puts "Secret Code is: #{@board.secret_code}"
    until game_over?
      puts "#{@current_player.name}'s turn number #{@attempts}"
      puts "Enter your guesses in order"
      guesses = gets.chomp.split(" ")
      if @board.guesses_valid?(guesses)
        @board.place_guesses(@attempts-1, guesses)
        @board.display
        break if @board.winning_combination?(guesses)
        @attempts += 1
      end
    end
    puts "Yeah, you won!"

  end


  def game_over?
    @attempts >= 12 || @board.winning_combination?(@guesses)
  end

end

game = Game.new
game.play
