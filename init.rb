require 'rubygems'
require 'nokogiri'
require 'open-uri'

PAGE_URL = "http://www.mediawiki.org/wiki/Installation"

page = Nokogiri::HTML(open(PAGE_URL))
page_title = page.title
h1 = page.css('h1').text
redirected_from = page.css('div#contentSub').text
page.at('#toc').remove
page.css('span[class="mw-editsection"]').map(&:remove)
content = page.css('div#mw-content-text').text
parsed_file_name = "parsed.txt"
begin
  file = File.open(parsed_file_name, "w")
  file.write(page_title)
  file.write(h1)
  file.write(redirected_from)
  file.write(content)
  file.write(page.css('span[class="mw-editsection"]'))
rescue IOError => e
  #some error occur, dir not writable etc.
ensure
  file.close unless file == nil
end