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

def find(keywords, text)
  kwords, words, f = keywords.split(/[^[[:alnum:]]]+/).map(&:mb_chars).map(&:downcase).map(&:to_s).map { |x| Regexp.new(x) }, text.split(/[^[[:alnum:]]]+/).map(&:mb_chars).map(&:downcase).map(&:to_s), Hash.new(0)
  kwords.each { |kword| words.each { |word| f[kword] += 1 if word =~ kword } }
  [f.values.inject(0) { |a, x| a + x }, f, f.size]
end


puts find(keywords, text) unless keywords.empty?