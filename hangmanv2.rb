require 'yaml'

$dictionary = File.read('colors.txt').split(/\n/)


class Controller

	def initialize(dictionary)
		@dictionary = dictionary
		@current_game = nil

		#@guesses_remaining = 10
		#@guess = ''
		#Intro text
		puts "Alright, this is a hangman game.  
		Guess letters to fill in the blanks. 
		You have 10 guesses to start."
	end

	def new_game
		@current_game = Game.new(@dictionary.sample, 10)
		puts "Here's the word cheaty, #{@word}"
		# p word
		p @current_game
		game_loop
	end

	def prompt_load_saved
		puts	"Would you like to to open a saved game? Type y/n"
		@answer = gets.chomp
		if @answer == "y"
			self.open_saved
		else
			puts "Cool, lets play a new game."
		end
	end

	def prompt_save
		puts "Save game? y/n"
		answer = gets.chomp
		if answer == "y"

			save_game
		else puts "Play on!"
		end
	end

	

	#Save the game to a file   ##load saved games into an array or hash so user can choose by number or index
	def save_game
		puts "Type a name for your saved game"
		game_name = gets.chomp	
		filename = "#{game_name}.yml"

		 ex_file = File.expand_path("./saved_games/#{filename}")
		 
		if File.exists?(ex_file)
	   puts "#{filename} exists" #overwrite method?
	  
	   self.save_game
	  else
			File.open(ex_file, "w") do |f|
				game_state = YAML::dump(self)
				f.puts game_state
				puts "Your game was saved as #{filename}"  
			end
		end
	end


#list contents of saved games directory
#prompt player to choose one of the saved games

	def show_saved
		puts Dir.glob("./saved_games/*")
	end

	def choose_saved
		puts "Enter the name of the game you would like to open, just the last part of the filename before the .txt" ###readfrom file########
		@open_name = gets.chomp
	end

	def open_saved
		 self.show_saved
		
		# file_to_open = File.expand_path("./saved_games/#{@open_name}")


		File.open("./saved_games/pinktest.txt", "r") do |f|
			 game_state = YAML::load_file(f.read)
		end

		# data =  YAML::load_file("./saved_games/redyaml.yml")
		puts game_state

		puts "__________________________"
	end
end #controller class


class Game

	@word = ''
	@word_array = []

	def initialize   (word, guesses_remaining)

		# @word = word

		# self.word = 'horse'
		@word_array = word.split()
	# attr_accessor :word, :answer, :guess, :result_array, :guesses_remaining, :word_array
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

	#alternative to match_letters, use word as first arg and guesses as an array, check each time looping thru word to check if there's a match and put match or leave

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
			puts "Aw yeah.  You win, you wiener!"
			good_bye
		end
	end

	def is_over?
		# puts "guesses = #{@guesses_remaining}, result_array = #{@result_array}"
		if (@guesses_remaining == 0 or @word.chomp == @result_array)
			true
		end
	end

	def good_bye
		puts "Thanks for playing"
		exit
	end

	def game_loop

		# Controller.prompt_load_saved ###this doesn't work

		self.get_word

		self.show_blanks

		while !self.is_over?
			self.prompt_save

			self.prompt_guess

			self.decrement_guesses

			self.handle_guess(game.good_guess?(game.guess))  #make sure to call vars in context

			self.check_win

		end
end

end

play = Controller.new($dictionary)
play.new_game
# game.game_loop