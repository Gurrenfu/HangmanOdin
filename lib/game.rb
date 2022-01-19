# play hangman
# 5 to 12 words
# load words from dictionary 
# save game and load game 

require 'json'

module Constants
    MAX_HEALTH = 7
    ACCEPTED_GUESSES = /[[:alpha:]]/
end

module UserInput
    def self.get_input(valid_answers)
      answer = nil
      valid_input = false
      until valid_input
        answer = gets.chomp.delete(' ').upcase[0]
        valid_input = self.validate_input(answer, valid_answers)
      end
      answer
    end
  
    def self.validate_input(input, reg_exp)
     if reg_exp.match?(input)
        true
     else
        puts "Check your guess"
        false
     end
    end
end

module NewGame
    def self.filter_word_list(word_array, min = 7, max = 14)
        word_list = word_array.filter!{|word| word.length.between?(min,max)}
        word_list[rand(word_list.length)].chomp("\r\n")
    end 
end

module Serializable 
    @@serializer = JSON
    def serialize 
        obj = {}
        instance_variables.map do |var|
            obj[var] = instance_variable_get(var)
        end
       @@serializer.dump obj
    end

    def unserialize(string)
        obj = @@serializer.parse(string)
        obj.keys.each do |key|
            instance_variable_set(key,obj[key])
        end
    end

    def save_game 
        saved_game_data = serialize
        puts "Saving Game..."
        Dir.mkdir('saves') unless Dir.exist?('saves')
        filename = "saves/hangman_saved_game"
        File.open(filename, 'w') do |file|
            file.puts saved_game_data
        end
    end

    def load_game 
        filename = "saves/hangman_saved_game"
        data = File.exist?(filename)? File.open(filename).read : nil
        if data.nil? 
            puts "No saved game"
        else
            puts "Loading Game..."
            unserialize(data)
        end
    end
end

class Game
  include Constants
  include Serializable

   def initialize(word = '', guessed_letters =[], health = MAX_HEALTH) 
     @secret_word = word
     @secret_word_array = @secret_word.upcase.scan /\w/
     @guessed_letters = guessed_letters
     @guessed_letters.map!{|letter| letter.upcase}
     @health = health
   end

    def guessed_letter(letter)
        # check for duplicates
        @guessed_letters.push(letter.upcase)
    end

    def check_current_word
        @secret_word_array.all?{|letter| @guessed_letters.include?(letter)}
    end

    def reduce_health(delta = 1)
        @health -= delta
    end

    def display_current_word
       @secret_word.each_char{|c| print @guessed_letters.include?(c.upcase)? "#{c} " : '_ '}
       puts "\n"
    end

    def display_guesses
        puts "Guesses: #{@guessed_letters.join(',')}"
    end

    def display_health 
        puts "Health: #{@health}"
    end

    def play
      first_round = true
      game_over = false
      until game_over
        puts "\n"
        display_health
        display_guesses
        display_current_word

        unless first_round
            puts 'Would you like to save: Y N?'
            answer = UserInput.get_input('YN')
            if answer == 'Y'
                save_game
                puts 'Would you like to quit: Y N?'
                answer = UserInput.get_input('YN')
              break if answer == 'Y';
            end
        end
        
        first_round = false
        puts 'Please guess a letter'
        guessed_letter(UserInput.get_input(ACCEPTED_GUESSES)) 
        if check_current_word
            game_over = true
            puts "CONGRATS"
            break
        else
            reduce_health
            if @health <= 0 
            game_over = true
            puts "Game Over   Secret Word:  #{@secret_word}"
            break
            end
        end
      end
    end
end

            
close_game = false
until close_game
    puts "Let's Player Hangman \nThe game auto saves after each round"
    
    puts "\nNew or Load Game: N L"
    selection = UserInput.get_input('NL')
    if selection == 'N'
        puts "Starting New Game"
        secret_word = NewGame.filter_word_list(File.readlines('dictionary/5desk.txt'))
        game = Game.new(secret_word)
    else
        game = Game.new()
        game.load_game
    end

    unless game.nil?
        game.play
    end

    puts "\n Play Again: Y N  ?"
    quit = UserInput.get_input('YN')
    close_game = (quit == 'N')
end
  
puts "\nTHANKS FOR PLAYING"