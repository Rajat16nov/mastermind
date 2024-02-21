class Board
  @@colors = ['Blue', 'Red', 'Yellow', 'Green', 'Purple', 'Orange']
  @@hint_pegs = ['White', 'Black']
  attr_accessor :code
  attr_reader :grid

  def initialize
    @grid = array = Array.new(12) { Array.new(2) { Array.new(4, " ") } }
    @code = []
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
    place_hints(row_number, guesses)
  end

  def get_guesses_pool
    @@colors.repeated_permutation(4).to_a
  end

  def secrets_fetcher(guess, hint)
    #returns secrets that would all have given the same hint
    # puts "Secrets Fetcher got guess: #{guess}"
    # puts "Secrets Fetcher got hint: #{hint}"
    possible_secrets = []
    all_secrets = @@colors.repeated_permutation(4).to_a
    all_secrets.each do |secret| 
      if get_hints(guess, secret) == hint
        possible_secrets.push(secret)
      end
    end
    possible_secrets.delete(guess)
    possible_secrets
  end

  def get_hints(guesses, secret)
    #returns the tally of hints given any guess and secret
    hints = []
    black_pegs = 0
    white_pegs = 0
    code_clone = secret.clone
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
    hints.tally
  end

  def place_hints(row_number, guesses)
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
    return false if guesses.nil?
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
    @computer = Player.new("Computer")
    @attempts = 1
    @current_player = @player1
  end

  def play
    puts "Choose your role: Code Maker (CM) or Code Breaker (CB)"
    role = gets.chomp
    if role == "CB"
      puts "Secret Code is: #{@board.secret_code}"
      until game_over?
        puts "#{@current_player.name}'s turn number #{@attempts}"
        puts "Enter your guesses in order"
        guesses = gets.chomp.split(" ")
        if @board.guesses_valid?(guesses)
          @board.place_guesses(@attempts-1, guesses)
          @board.display
          if @board.winning_combination?(guesses)
            puts "Yeah, you won!"
            break
          end
          @attempts += 1
        end
      end

    elsif role == "CM"
      entered_code = []
      guesses_pool = @board.get_guesses_pool
      until @board.guesses_valid?(entered_code) do
        puts "Enter Secret Code: "
        entered_code = gets.chomp.split(" ")
      end
      @board.code = entered_code
      @current_player = @computer
      until game_over?
        puts "#{@current_player.name}'s turn number #{@attempts}"
        if @attempts>=2
          previous_hint = @board.grid[@attempts-2][1].tally
          previous_guess = @board.grid[@attempts-2][0]
          #need to eliminate all codes that would not have given this tally if they were the secret
          guesses_pool = guesses_pool & @board.secrets_fetcher(previous_guess, previous_hint)
          puts "Guesses Pool now has #{guesses_pool.length} items"
          guesses = guesses_pool[0]
          puts "Computer Guessed: #{guesses}"
        else 
          guesses = ["Blue", "Blue", "Blue", "Blue"]
        end
        if @board.guesses_valid?(guesses)
          @board.place_guesses(@attempts-1, guesses)
          @board.display
          if @board.winning_combination?(guesses)
            puts "Yeah, computer won!"
            break
          end
          @attempts += 1
        end
      end  
    else
      puts "Invalid Input"
    end

  end


  def game_over?
    @attempts >= 13 || @board.winning_combination?(@guesses)
  end

end

game = Game.new
game.play
