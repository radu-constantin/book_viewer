require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

helpers do
  def format_text(text)
    text.split(/\n\n/).each_with_index.map do |line, index|
      "<p id=paragraph#{index}>#{line}</p>"
    end.join
  end

  def highlight(text, term)
    text.gsub(term, %(<strong>#{term}</strong>))
  end
end

before do
  @contents = File.readlines("data/toc.txt")
end

not_found do
  redirect "/"
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  chapter_name = @contents[number - 1]

  redirect "/" unless (1..@contents.size).cover? number

  @title = "Chapter #{number}: #{chapter_name}"
  @chapter  = File.read ("data/chp#{number}.txt")

  erb :chapter
end

def each_chapter
  @contents.each_with_index do |name, index|
    number = index + 1
    paragraphs = File.read("data/chp#{number}.txt")
    yield number, name, paragraphs
  end
end

def chapters_matching(query)
  results = []

  return results unless query

  each_chapter do |number, name, contents|
    matches = {}
    contents.split("\n\n").each_with_index do |paragraph, index|
      matches[index] = paragraph if paragraph.include?(query)
    end
    results << {number: number, name: name, paragraphs: matches} if matches.any?
  end

  results
end

get "/search" do
  @results = chapters_matching(params[:query])
  erb :search
end
