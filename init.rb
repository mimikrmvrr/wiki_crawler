require 'rubygems'
require 'nokogiri'
require 'open-uri'

PAGE_URL = "http://www.mediawiki.org/wiki/Installation"

#page = Nokogiri::HTML(open(PAGE_URL))
page_title = Nokogiri::HTML(open(PAGE_URL)).css('title').text
h1 = Nokogiri::HTML(open(PAGE_URL)).css('h1').text
parsed_file_name = "parsed.txt"
begin
  file = File.open(parsed_file_name, "w")
  file.write(page_title)
  file.write(h1)
rescue IOError => e
  #some error occur, dir not writable etc.
ensure
  file.close unless file == nil
end