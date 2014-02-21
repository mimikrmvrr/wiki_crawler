require 'rubygems'
require 'nokogiri'
require 'open-uri'


class Url
  def initialize(url)
    @url = url
  end

  def base_url
    uri = URI.parse(@url)
    "#{uri.scheme}://#{uri.host}"
  end

  def path
    uri = URI.parse(@url)
    "#{uri.path}"
  end
end


class LinkUtils
  def self.get_links(page)
    links = {}
    page.xpath('//a[@href]').each do |link|
      links[link.text.strip] = link['href']
    end
    links
  end

  def self.internal_links(links)
    links.select { |link_name, link| link.start_with?('/') and not link.start_with?('//') }
  end

  def self.get_absolute_url(link)
    "#{BASE_URL}#{link}"
  end
end


class Page
  attr_reader :name

  def initialize(url)
    begin
      @html = Nokogiri::HTML(open(url))
      @name = Url.new(url).path
    rescue Exception=>e
      puts "Cannot open #{url}"
    end
  end

  def neighbours
    links = LinkUtils.get_links(@html.css('div#mw-content-text'))
    neighbours = LinkUtils.internal_links(links).values.map do |name|
      if ObjectSpace.each_object(Page).select { |obj| obj.name == name }.empty?
        #puts get_absolute_url(name)
        Page.new(LinkUtils.get_absolute_url(name))
      else
        ObjectSpace.each_object(Page).select { |obj| obj.name == name }.first
      end
    end
    @neighbours = neighbours.select { |obj| not obj.name.nil? }
  end

  def create_local_file
    remove_useless
    begin
      file = File.open(file_name, "w")
      file.write(heading)
      file.write(content)
    rescue IOError => e
      #some error occur, dir not writable etc.
    ensure
      file.close unless file == nil
    end
  end

  def heading
    @html.css('h1').text
  end

  def remove_useless
    @html.at('#toc').remove
    @html.css('span[class="mw-editsection"]').map(&:remove)
  end

  def content
    @html.css('div#mw-content-text').text
  end

  def file_name
    @name.gsub('/', '_')[1..-1]
  end
end

# page = Nokogiri::HTML(open(PAGE_URL))
# page_title = page.title
# h1 = page.css('h1').text
# redirected_from = page.css('div#contentSub').text
# page.at('#toc').remove
# page.css('span[class="mw-editsection"]').map(&:remove)
# content = page.css('div#mw-content-text').text
#links = get_links(page.css('div#mw-content-text'))
#hrefs = internal_links(links)

# hrefs.map do |href_name, href|
#   absolute_url = get_absolute_url(href)
#   file_name = "#{DATA_DIR}/#{File.basename(href, '.html')}"
#   unless File.exists?(file_name)
#     begin
#       content = open(absolute_url).read
#       rescue Exception=>e
#       puts "Error: #{e}"
#     else
#       file = File.open(file_name, 'w')
#       file.write(content)
#     end
#   end    
# end

# parsed_file_name = "parsed.txt"

# begin
#   file = File.open(parsed_file_name, "w")
#   file.write(h1)
#   file.write(redirected_from)
#   file.write(content)
#   #file.write(internal)
# rescue IOError => e
#   #some error occur, dir not writable etc.
# ensure
#   file.close unless file == nil
# end