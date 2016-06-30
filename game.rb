require 'sinatra'
require 'sinatra/reloader'

enable :sessions

get '/' do
  if session[:game_over] || session[:answer].nil?
    redirect to('/new')
  end
  erb :index
end

get '/new' do
  session[:answer] = create_new_answer
  session[:answer_array] = session[:answer].scan(/./)
  session[:hidden] = hide_word(session[:answer])
  session[:guesses] = []
  session[:wrong_guesses] = 0
  session[:wrong_letters] = []
  session[:game_over] = false
  redirect to('/')
end

post '/' do

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

end
