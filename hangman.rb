require 'yaml'

$dictionary = File.read('colors.txt').split(/\n/)


class Controller	


	def initialize(dictionary)
	  @dictionary = dictionary
    @current_game = nil
	end

	def menu
		puts "Hangman!".center(53, '-')
		puts "Play a new game, type 1. To open a saved game, type 2"
		input = gets.chomp
			if input == "1"
				new_game
			elsif input == "2"
				load_saved
			else
				puts "Type 1 or 2, please"
				menu
			end
	end  

	def new_game
		@current_game = Game.new(@dictionary.sample, 10)
		@current_game.game_loop
	end

	def show_saved
		@game_array = []
		if Dir.glob("./saved_games/*").length > 0
			Dir.glob("./saved_games/*").each do |filename|
   			@game_array << File.basename(filename,'.yml')
   		end

			game_count = 0
			@game_array.each do |gamepath|
								 game_count = game_count + 1

				puts "#{game_count} -- #{gamepath}"
			end 

			choose_saved
			else

			puts "You have not saved any games yet, here's a new game." 
			new_game
		end
	end

	def choose_saved
		puts "Enter the number of the game you would like to open"
		@game_name = @game_array[gets.chomp.to_i-1]
	end

	def load_saved
		show_saved
		game_state = YAML::load(File.read("./saved_games/#{@game_name}.yml"))
		
		  if game_state.is_a? Game
      	@current_game = game_state
      	@current_game.game_loop
	    else
	      self.menu
	    end
	end


end


class Game


	def initialize(word, guesses)
		@word = word.chomp.upcase
		@guesses = guesses
		@word_array = @word.chars.to_a
		@result_array = "_"*@word_array.length
	end

	def game_loop
	
		while !self.is_over?
			self.show_blanks(@result_array)
			self.prompt_guess
			
			self.handle_guess(self.good_guess?(@guess))  #make sure to call vars in context
			self.decrement_guesses
			self.check_win
		end
	end

	#show the correct number of blank spaces
	def show_blanks(results)
		puts "#{results}\n".center(53)
		puts ""
	end

	def prompt_guess
		puts "Guess a letter, or type 'save' to save and exit" 
		@guess = gets.chomp.upcase
			if @guess == "SAVE"
				save_game
			end
	end

	#check if the guess matches 1 or more letters and show letters in blanks
	def match_letters 
		indexes_matched = @word_array.each_index.select { |i| @word_array[i] == @guess}

		for x in indexes_matched do
			@result_array[x] = @guess
		end
	end

	#checks if players guess is included in word
	def	good_guess?(player_guess)
		@word_array.include?(player_guess)
	end

	def handle_guess(good)
		return handle_good_guess if good

		handle_bad_guess
	end

	def handle_good_guess
		match_letters
	end

	def handle_bad_guess
		puts "Try again, there's no #{@guess}" if @guesses > 0
	end

	def decrement_guesses
		@guesses = @guesses-1
		puts "You have #{@guesses} guesses left"
	end

	def check_win
		if @guesses == 0
			puts "It's all over, you're out of guesses, the word was #{@word}"
			good_bye
		elsif @word.chomp == @result_array
			puts @word
			puts "Aw yeah.  You win!"
			good_bye
		end
	end

	def is_over?
		if (@guesses == 0 or @word.chomp == @result_array)
			true
		end
	end

	def good_bye
		puts "Thanks for playing"
		exit
	end

	def save_game
		puts "Type a name for your saved game"
		game_name = gets.chomp
		filename = "#{game_name}.yml"

		 ex_file = File.expand_path("./saved_games/#{filename}")
		 
			if File.exists?(ex_file)
		   puts "#{filename} already exists"
		  
		   save_game
		  else
	  		File.open(ex_file, "w") do |f|

				f.puts YAML::dump(self)

				puts "Your game was saved as #{game_name}"  
			end
			good_bye
		end
	end

end


controller = Controller.new($dictionary)
controller.menu