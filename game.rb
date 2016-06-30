require 'sinatra'
require 'sinatra/reloader'

enable :sessions

get '/' do
  if session[:answer].nil?
    redirect to('/new')
  elsif session[:game_over]
    redirect to('/game_over')
  elsif session[:hidden] == session[:answer]
    redirect to ('/winner')
  end
  erb :index
end

get '/game_over' do
  erb :game_over
end

get '/winner' do
  erb :winner
end

get '/new' do
  session[:answer] = create_new_answer
  session[:answer_array] = session[:answer].scan(/./)
  session[:hidden] = hide_word(session[:answer])
  session[:guesses] = []
  session[:wrong_guesses] = 0
  session[:wrong_letters] = []
  session[:game_over] = false
  session[:message] = ""
  redirect to('/')
end

post '/' do
  compare(params["guess"])
  redirect to('/')
end

helpers do
  def create_new_answer
    usable_words = []
    File.readlines("word_list.txt").each do |line|
      if line.length > 6 && line.length < 15 #accounts for the \n at the end of each line
        usable_words << line.gsub("\n", "")
      end
    end
    return usable_words.sample.downcase
  end

  def hide_word(word)
    hidden = ""
    word.length.times do
      hidden << "*"
    end
    return hidden
  end

  def compare(letter)
    message = ""
    if session[:guesses].include?(letter)
      session[:message] = "You've already guessed that, try again."
      return
    elsif letter.length > 1
      session[:message] = "You can only guess one letter at a time. Try again."
      return
    elsif letter.to_i.to_s == letter
      session[:message] = "Sorry, only letters work. Try again."
      return
    elsif session[:answer].include?(letter)
      session[:guesses] << letter
      session[:answer].length.times do |x|
        if session[:answer][x] == letter
          session[:hidden][x] = letter
        end
      end
      session[:message] = "You guessed correctly!"
    else
      session[:wrong_guesses] += 1
      session[:wrong_letters] << letter
      session[:guesses] << letter
      session[:message] = "Your guess was wrong!" if session[:wrong_guesses] < 6
      if session[:wrong_guesses] == 6
        session[:message] = "Nope, sorry! That was your last guess. Better luck next time!<br /><h2>The answer was: #{session[:answer]}</h2>"
        session[:game_over] = true
      end
    end
    return session[:hidden]
  end
end
