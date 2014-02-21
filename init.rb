#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require './utils'

PAGE_URL = "http://www.mediawiki.org/wiki/Installation"
BASE_URL = Url.new(PAGE_URL).base_url
DATA_DIR = "data/pages"