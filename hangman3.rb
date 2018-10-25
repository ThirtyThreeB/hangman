require 'yaml'

class Hangman	

	attr_accessor :word, :answer, :guess, :result_array, :guesses_remaining, :word_array

	def initialize   #=(game_state)
		@guesses_remaining = 10
		@guess = ''
		#Intro text
		puts "Alright, this is a hangman game.  
		Guess letters to fill in the blanks. 
		You have 10 guesses to start."
	end

	# load dictionary from the page?
	def load_library
		#wget some url
	end

#save was here

	#grab a random word from text file
	def get_word
		selection = IO.readlines("colors.txt")
		@word = selection[rand(selection.length)].downcase.chomp
		@word_array = @word.chars.to_a
		puts "Here's the word for debugging, #{@word.upcase}"
	end

	#show the correct number of blank spaces
	def show_blanks
		@result_array = "_"*@word_array.length
		puts @result_array
	end

	def prompt_guess
		puts "Guess a letter"
		@guess = gets.chomp
	end


	#check if the guess matches 1 or more letters and show letters in blanks
	def match_letters #handle_guess
		indexes_matched = @word_array.each_index.select { |i| @word_array[i] == @guess}

		for x in indexes_matched do
			@result_array[x] = guess
		end

		puts @result_array
	end

	#checks if players guess is included in word
	def	good_guess?(g)
		@word_array.include?(g)
	end

	def handle_guess(good)
		return handle_good_guess if good

		handle_bad_guess
	end

	def handle_good_guess
		match_letters
	end

	def handle_bad_guess
		puts "Guess again"
	end

	def decrement_guesses
		@guesses_remaining = @guesses_remaining-1
		puts "You have #{@guesses_remaining} guesses left"
	end

	def check_win
		p @guesses_remaining
		if @guesses_remaining == 0
			puts "It's all over, you're out of guesses"
			good_bye
		elsif @word.chomp == @result_array
			puts "Aw yeah.  You win!"
			good_bye
		end
	end

	def is_over?
		if (@guesses_remaining == 0 or @word.chomp == @result_array)
			true
		end
	end

	def good_bye
		puts "Thanks for playing"
		exit
	end

	##########saving stuff

	def prompt_load_saved
		puts	"Would you like to to open a saved game? Type y/n"
		@answer = gets.chomp
		if @answer == "y"
			load_saved
		else
			puts "Cool, lets play a new game."
		end
	end

	def load_saved
		puts "here's the #{@answer}, load_saved method gets that far" ###read from file########
		@game_state = YAML::load(File.read('./saved_games/doot.yml'))
	
	end

	def prompt_save
		puts "Save game? y/n"
		answer = gets.chomp
		if answer == "y"

			save_game
			# save_game
		else puts "Play on!"
		end
	end

	
		#Save the game to a file
	def save_game
		puts "Type a name for your saved game"
		game_name = gets.chomp
		filename = "#{game_name}.yml"

		 ex_file = File.expand_path("./saved_games/#{filename}")
		 
		if File.exists?(ex_file)
	   puts "#{filename} exists"
	  
	   save_game
	  else
	  	# @game_state = game
	  	puts @game_state
			File.open(ex_file, "w") do |f|

				f.puts YAML::dump(self)

				puts "Your game was saved as #{filename}"  
			end
		end
	end
end


# save_it = Save.new

game = Hangman.new

game.prompt_load_saved

game.get_word

game.show_blanks

# this works since 'game' gets me all the vars from attr_accessor
puts YAML::dump(game)

while !game.is_over?
	#game.prompt_save
	game.prompt_save

	game.prompt_guess

	game.decrement_guesses

	game.handle_guess(game.good_guess?(game.guess))  #make sure to call vars in context

	game.check_win

end

