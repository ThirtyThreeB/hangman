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

	def self.save_game(data) #defining the method like this makes it a class method that I can call from another method, as below
		puts "Type a name for your saved game"
		game_name = gets.chomp
		filename = "#{game_name}.yml"

		Dir.mkdir('./saved_games') unless Dir.exist?('./saved_games')

		 ex_file = File.expand_path("./saved_games/#{filename}")
		 
			if File.exists?(ex_file)
		   puts "#{filename} already exists"
		  
		   save_game
		  else
	  		File.open(ex_file, "w") do |f|

				f.puts YAML::dump(data)

				puts "Your game was saved as #{game_name}"  
			end
			self.good_bye
		end
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

		def self.good_bye #this must also be a class method, moved from controller
		puts "Thanks for playing"
		exit
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
	end

	def prompt_guess
		puts "Guess a letter, or type 'save' to save and exit" 
		@guess = gets.chomp.upcase
			if @guess == "SAVE"
				Controller.save_game(self)  #gotta do it like this to call a class method from the Controller class, also passing 'self' into the method allows me to get the vars out of the class and populate the YAML object up in the controller in #save_game
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
			Controller.good_bye
		elsif @word.chomp == @result_array
			puts @word
			puts "Aw yeah.  You win!"
			Controller.good_bye
		end
	end

	def is_over?
		if (@guesses == 0 or @word.chomp == @result_array)
			true
		end
	end


end


controller = Controller.new($dictionary)
controller.menu


#problem I have here is with loading a saved game. it doesn't see the previously saved 
#game as a Game, so it's not loading it into the game loop
#however, if I save a game with hungman, and load it with hangman, then it works.

#looka again at the saved game files and see that the bad ones like 'gray' are saved as 
#ontrollers with no data, and the good ones are actual Games with data

#weds--- This saves as a Controller object, with no data, since I'm saving in in he controller class?