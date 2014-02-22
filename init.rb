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

print "Keywords to search:"
keywords = gets.strip

page = Page.new(PAGE_URL)

unless keywords.empty?
  puts Crawler.new.crawl page, level, keywords
else
  puts Crawler.new.crawl page, level
end
