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

  def path()
    uri = URI.parse(@url)
    "#{uri.path}"
  end
end

BASE_URL = Url.new(PAGE_URL).base_url
DATA_DIR = "data/pages"

def get_links(page)
  links = {}
  page.xpath('//a[@href]').each do |link|
    links[link.text.strip] = link['href']
  end
  links
end

def internal_links(links)
  links.select { |link_name, link| link.start_with?('/', '#') }
end

def get_absolute_url(link)
  link.start_with?('#') ? "#{PAGE_URL}#{link}" : "#{BASE_URL}#{link}"
end

class Page
  def initialize(url)
    @html = Nokogiri::HTML(open(url))
    @name
  end

  def neighbours()
    links = get_links(@html.css('div#mw-content-text'))
    @neighbours = internal_links(links).values
  end

end

page = Nokogiri::HTML(open(PAGE_URL))
page_title = page.title
h1 = page.css('h1').text
redirected_from = page.css('div#contentSub').text
page.at('#toc').remove
page.css('span[class="mw-editsection"]').map(&:remove)
content = page.css('div#mw-content-text').text
links = get_links(page.css('div#mw-content-text'))
hrefs = internal_links(links)

hrefs.map do |href_name, href|
  absolute_url = get_absolute_url(href)
  file_name = "#{DATA_DIR}/#{File.basename(href, '.html')}"
  unless File.exists?(file_name)
    begin
      content = open(absolute_url).read
      rescue Exception=>e
      puts "Error: #{e}"
    else
      file = File.open(file_name, 'w')
      file.write(content)
    end
  end    
end

parsed_file_name = "parsed.txt"

begin
  file = File.open(parsed_file_name, "w")
  file.write(h1)
  file.write(redirected_from)
  file.write(content)
  #file.write(internal)
rescue IOError => e
  #some error occur, dir not writable etc.
ensure
  file.close unless file == nil
end