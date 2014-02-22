require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'active_support/core_ext'
require 'date'
require './crawler'
require './page'
require './constants'


class Url
  def initialize(url)
    @url = url
  end

  def base_url
    uri = URI.parse(@url)
    "#{uri.scheme}://#{uri.host}:#{uri.port}"
  end

  def path
    uri = URI.parse(@url)
    "#{uri.path}"
  end
end


class LinkUtils
  def self.get_links(page)
    links = {}
    page.xpath('.//a[@href]').each do |link|
      links[link.text.strip] = link['href']
    end
    #puts links
    links
  end

  def self.internal_links(links)
    links.select { |link_name, link| link.start_with?('/') and not link.start_with?('//') }
  end

  def self.get_absolute_url(link)
    "#{BASE_URL}#{link}"
  end
end


class TextParser
  attr_reader :text

  def initialize(text)
    @text = text
  end

  def split
    @text.split(/[^[[:alnum:]]]+/).map(&:mb_chars).map(&:downcase).map(&:to_s).select { |word| not word.empty? }
  end

  def frequencies
    words = split
    frequencies = Hash.new(0)
    words.each { |word| frequencies[word] += 1 unless WORDS_TO_IGNORE.include? word }
    frequencies
  end

  def phrases
    @text.split(/[[:punct:]]+/).map(&:mb_chars).map(&:downcase).map(&:to_s).select { |phrase| not phrase.empty? }.map(&:strip)
  end
end


class Searcher
  def initialize(keywords, text)
    @kwords = TextParser.new(keywords).split
    @phrases = TextParser.new(text).phrases
  end

  def frequencies
    matches = Hash.new(0)
    @phrases.each do |phrase|
      frequencies = TextParser.new(phrase).split.select { |word| @kwords.include? word }.size
      matches[phrase] += frequencies if frequencies > 0
    end
    matches
  end
end

