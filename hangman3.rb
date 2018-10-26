require 'yaml'

$dictionary = File.read('colors.txt').split(/\n/)


class Controller	


	def initialize(dictionary)
	  @dictionary = dictionary
    @current_game = nil
	end

	def menu
		# new_game
		puts "Hangman!".center(53, '-')
		puts "Play a new game, type 1. To open a saved game, type 2"
		input = gets.chomp
			if input == "1"
				new_game
			elsif input == "2"
				load_saved
			else
				puts "Nope #{input}"
				p input
				menu
			end
	end  

	def new_game
		@current_game = Game.new(@dictionary.sample, 10)
		@current_game.game_loop
	end



	def load_saved
		puts "test0" 
		game_state = YAML::load(File.read('./saved_games/yellowtest.yml'))
		
		puts "test a"
		  if game_state.is_a? Game
		  	puts "test b"
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
		# puts "#{@word}, #{@result_array}, #{@guesses}"
		self.show_blanks(@result_array)

		while !self.is_over?
			# self.prompt_save
			self.prompt_guess
			self.decrement_guesses
			self.handle_guess(self.good_guess?(@guess))  #make sure to call vars in context
			self.check_win
		end
	end

	#show the correct number of blank spaces
	def show_blanks(results)
		puts results
	end

	def prompt_guess
		puts "Guess a letter, or type 'save' to save" # 
		@guess = gets.chomp.upcase
			if @guess == "SAVE"
				save_game
			end
	end

	#check if the guess matches 1 or more letters and show letters in blanks
	def match_letters #handle_guess
		indexes_matched = @word_array.each_index.select { |i| @word_array[i] == @guess}

		for x in indexes_matched do
			@result_array[x] = @guess
		end
		puts @result_array
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
		puts "Guess again" if @guesses > 0
	end

	def decrement_guesses
		@guesses = @guesses-1
		puts "You have #{@guesses} guesses left"
	end

	def check_win
		# p @guesses
		if @guesses == 0
			puts "It's all over, you're out of guesses"
			good_bye
		elsif @word.chomp == @result_array
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

				puts "Your game was saved as #{filename}"  
			end
			good_bye
		end
	end

end




controller = Controller.new($dictionary)
controller.menu









# save_it = Save.new

# game = Hangman.new

# game.prompt_load_saved

# game.get_word

# game.show_blanks

# # this works since 'game' gets me all the vars from attr_accessor
# puts YAML::dump(game)

# while !game.is_over?
# 	#game.prompt_save
# 	game.prompt_save

# 	game.prompt_guess

# 	game.decrement_guesses

# 	game.handle_guess(game.good_guess?(game.guess))  #make sure to call vars in context

# 	game.check_win

# end

