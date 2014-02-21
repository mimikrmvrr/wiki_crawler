#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require './utils'

DATA_DIR = "data/pages"

print "Enter a url: "

PAGE_URL = gets.chomp
BASE_URL = Url.new(PAGE_URL).base_url

print "Depth level:"
level = gets.to_i

print "Keywords to serach:"
keywords = gets

page = Page.new(PAGE_URL)

#puts page

frequencies = Hash.new(0)

queue = [page]
until queue.empty?
  current_page = queue.shift
  #puts current_page.html
  if current_page.level <= level
    current_page.create_local_file
    text = ""
    File.open(current_page.file_name) { |file|  text = file.read }
    counter = TextParser.new text
    #puts counter.frequencies
    frequencies.merge!(counter.frequencies) { |word, current_count, new_count| current_count + new_count }
    #puts frequencies
    queue << current_page.neighbours
    queue.flatten!
  else
    break
  end
end
puts frequencies.sort_by { |word, count| -count }.first 20

text = ""
File.open(page.file_name) { |file|  text = file.read }

# def find(keywords, text)
#   kwords, phrases, f = TextParser.new(keywords).split, TextParser.new(text).phrases, Hash.new(0)
#   puts kwords[0]
#   phrases.each do |phrase|
#     frequencies = TextParser.new(phrase).split.select { |word| kwords.include? word }.size
#     f[phrase] += frequencies if frequencies > 0
#   end
#   f.sort_by { |word, count| -count }
# end

searcher = Searcher.new(keywords, text)

puts searcher.find unless keywords.empty?