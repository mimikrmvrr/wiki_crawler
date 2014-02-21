#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require './utils'

DATA_DIR = "data/pages"

print "Enter a url: "

PAGE_URL = gets
BASE_URL = Url.new(PAGE_URL).base_url

page = Page.new(PAGE_URL)
page.create_local_file