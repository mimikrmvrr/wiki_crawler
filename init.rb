#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require './utils'

DATA_DIR = "data/pages"

print "Enter a url: "

PAGE_URL = gets.chomp
BASE_URL = Url.new(PAGE_URL).base_url

page = Page.new(PAGE_URL)
page.create_local_file

text = ""
File.open(page.file_name) { |file|  text = file.read }
words = text.split(%r{\W+})

frequencies = Hash.new(0)
words.each { |word| frequencies[word] += 1 }

puts frequencies.sort_by(&:last)