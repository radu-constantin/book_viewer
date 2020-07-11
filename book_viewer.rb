require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  erb :home
end
