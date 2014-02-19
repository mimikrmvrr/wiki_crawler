require 'rubygems'
require 'nokogiri'
require 'open-uri'

PAGE_URL = "http://www.mediawiki.org/wiki/Installation"

class Url
  def initialize(url)
    @url = url
  end

  def base_url()
    uri = URI.parse(@url)
    "#{uri.scheme}://#{uri.host}"
  end
end

BASE_URL = Url.new(PAGE_URL).base_url

def get_links(page)
  links = {}
  page.xpath('//a[@href]').each do |link|
    links[link.text.strip] = link['href']
  end
  links
end

def internal_links(links)
  links.select {|link_name, link| link.start_with?('/', '#')}
end

page = Nokogiri::HTML(open(PAGE_URL))
page_title = page.title
h1 = page.css('h1').text
redirected_from = page.css('div#contentSub').text
page.at('#toc').remove
page.css('span[class="mw-editsection"]').map(&:remove)
content = page.css('div#mw-content-text').text
links = get_links(page.css('div#mw-content-text'))
internal = internal_links(links)
parsed_file_name = "parsed.txt"
begin
  file = File.open(parsed_file_name, "w")
  file.write(h1)
  file.write(redirected_from)
  file.write(content)
  file.write(internal)
rescue IOError => e
  #some error occur, dir not writable etc.
ensure
  file.close unless file == nil
end