module Hangman
  require "yaml"
  class Game
    def initialize
      @answer = Solution.new
      @display = @answer.hidden
      game_start
    end #initialize

    def game_start
      puts
      puts "                      --- INSTRUCTIONS ---                        "
      puts "Guess letters to see if you can figure out the hidden word."
      puts "If you get 6 letters wrong, you'll lose!"
      puts
      puts "At the start of any turn, type 'save' to save your game for later."
      puts
      puts "Press enter to continue, or type 'load' to load a saved game."
      start = gets.chomp.downcase
      if start == "load"
        load_game
        puts
        puts "Saved game loaded!"
        play
      else
        play
      end
    end #game_start

    def play
      loop do
        show_letters
        get_guess
        break if @answer.wrong_guesses >= 6
        if game_won?
          puts "You won! The word was #{@answer.word} Congratulations."
          break
        end
      end
      play_again?
    end #play

    def show_letters
      puts
      puts @display.join(" ")
      puts
      puts "Incorrectly guessed letters: #{@answer.wrong_letters.join(" ")}"
      puts "You've made #{@answer.wrong_guesses} wrong guesses."
    end #show_letters

    def get_guess
      puts
      puts "Enter a letter to guess."
      guess = gets.chomp.downcase
      if guess == "save"
        save_game
        puts "Game saved!"
        return
      end
      @answer.compare(guess)
    end #get_guess

    def game_won?
      if @display.join == @answer.word
        return true
      else
        return false
      end
    end #game_won?

    def play_again?
      loop do
        puts
        print "Would you like to play again? (Y/N) "
        restart = gets.chomp.downcase
        if restart == "n"
          "Thanks for playing!"
          return
        elsif restart == "y"
          Game.new
          return
        end
      end
    end #play_again?

    def load_game
      @answer = YAML.load(File.read("save.txt"))
      @display = @answer.hidden
    end #load_game

    def save_game
      file = File.open("save.txt", "w")
      YAML.dump(@answer, file)
      file.close
    end #save_game

  end #Game

  class Solution
    attr_reader :word
    attr_reader :wrong_guesses
    attr_reader :wrong_letters
    attr_accessor :hidden
    def initialize
      @word = create_new.downcase
      @hidden = []
      hide
      @wrong_guesses = 0
      @wrong_letters = []
      @guesses = []
    end #initialize

    def compare(guess)
      guess = guess.downcase
      if @guesses.include?(guess)
        puts "You've already guessed that, try again."
        again = gets.chomp.downcase
        compare(again)
      elsif guess.length > 1
        puts "You can only guess one letter at a time. Try again."
        again = gets.chomp.downcase
        compare(again)
      elsif guess.to_i.to_s == guess
        puts "Sorry, only letters work. Try again."
        again = gets.chomp.downcase
        compare(again)
      elsif @word.include?(guess)
        @guesses << guess
        @word.length.times do |x|
          if @word[x] == guess
            @hidden[x] = guess
          end
        end
        puts
        puts "You guessed correctly!"
      else
        @wrong_guesses += 1
        @wrong_letters << guess
        @guesses << guess
        puts
        puts "Your guess was wrong!" if @wrong_guesses < 6
        if @wrong_guesses == 6
          puts "Nope, sorry! That was your last wrong guess. Better luck next time!"
          puts "The answer was: #{@word}"
        end
      end
      return @hidden
    end #compare

    private
    def create_new
      usable_words = []
      File.readlines("word_list.txt").each do |line|
        if line.length > 6 && line.length < 15 #accounts for the \n at the end of each line
          usable_words << line.gsub("\n", "")
        end
      end
      return usable_words.sample.downcase
    end #create_new

    def hide
      @word.length.times do
        @hidden << "_"
      end
      return @hidden
    end #hide
  end #Solution
end #Hangman

include Hangman
Game.new
