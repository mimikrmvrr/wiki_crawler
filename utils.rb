require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'active_support/core_ext'


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
    #page.xpath("//*[@class='mw-pt-languages-list autonym']").map(&:remove) if page.xpath("//*[@class='mw-pt-languages-list']")
    #page.xpath("//*[@class='nmbox']").remove if page.xpath("//*[@class='nmbox']")
    #age.css("div#mw-content-text").remove.xpath("//*[@id='footer-info']")
    #puts page.xpath('//a[@href]')
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


class Page
  attr_accessor :level
  attr_reader :name, :html

  def initialize(url, level=0)
    begin
      @html = Nokogiri::HTML(open(url))
      @name = Url.new(url).path
      #create_local_file
      @level = level
      puts "Open #{url}"
    rescue Exception=>e
      puts "Cannot open #{url}"
    end
  end

  def neighbours
    links = LinkUtils.get_links(@html.css("div#bodyContent"))
    neighbours = LinkUtils.internal_links(links).values.map do |name|
      if ObjectSpace.each_object(Page).select { |obj| obj.name == name }.empty?
        Page.new(LinkUtils.get_absolute_url(name), @level + 1)
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
      puts "Writing error"
      #some error occur, dir not writable etc.
    ensure
      file.close unless file == nil
    end
  end

  def heading
    @html.css('h1').text
  end

  def remove_useless
    @html.at('#toc').remove if @html.at('#toc')
    #@html.css('span[class="mw-editsection"]').map(&:remove) if @html.css('span[class="mw-editsection"]')
    #@html.at('table[class="nmbox"]').remove if @html.at('table[class="nmbox"]')
  end

  def content
    @html.css('div#bodyContent').text
  end

  def file_name
    suffix = @name.gsub('/', '_')[1..-1]
    "#{DATA_DIR}/#{suffix}"
  end
end

WORDS_TO_IGNORE =  ["a", "able", "about", "above", "abroad", "according", "accordingly", "across", "actually", "adj",
  "after", "afterwards", "again", "against", "ago", "ahead", "ain", "t", "all", "allow", "allows", "almost", "alone",
  "along", "alongside", "already", "also", "although", "always", "am", "amid", "amidst", "among", "amongst", "an",
  "and", "another", "any", "anybody", "anyhow", "anyone", "anything", "anyway", "anyways", "anywhere", "apart", "appear",
  "appreciate", "appropriate", "are", "aren", "around", "as", "s", "aside", "ask", "asking", "associated", "at",
  "available", "away", "awfully", "back", "backward", "backwards", "be", "became", "because", "become", "becomes", "becoming",
  "been", "before", "beforehand", "begin", "behind", "being", "believe", "below", "beside", "besides", "best", "better",
  "between", "beyond", "both", "brief", "but", "by", "came", "can", "cannot", "cant", "caption", "cause", "causes", "certain",
  "certainly", "changes", "clearly", "c", "mon", "co", "com", "come", "comes", "completely", "concerning", "consequently",
  "consider", "considering", "contain", "containing", "contains", "corresponding", "could", "couldn", "course", "currently",
  "dare", "daren", "decrease", "decreasingly", "definitely", "described", "despite", "did", "didn", "different", "directly",
  "do", "does", "doesn", "doing", "done", "don", "down", "downwards", "during", "each", "eg", "eight", "eighty", "either",
  "else", "elsewhere", "end", "ending", "enough", "entirely", "especially", "et", "etc", "even", "ever", "evermore", "every",
  "everybody", "everyone", "everything", "everywhere", "ex", "exactly", "example", "except", "fairly", "far", "farther",
  "few", "fewer", "fifth", "first", "firstly", "five", "followed", "following", "follows", "for", "forever", "former",
  "formerly", "forth", "forward", "found", "four", "from", "further", "furthermore", "get", "gets", "getting", "given",
  "gives", "go", "goes", "going", "gone", "got", "gotten", "greetings", "had", "hadn", "half", "happens", "hardly", "has",
  "hasn", "have", "haven", "having", "he", "d", "ll", "hello", "help", "hence", "her", "here", "hereafter", "hereby", "herein",
  "hereupon", "hers", "herself", "hi", "him", "himself", "his", "hither", "hopefully", "how", "howbeit", "however", "hundred",
  "i", "ie", "if", "ignored", "m", "immediate", "in", "inasmuch", "inc", "increase", "increasingly", "indeed", "indicate",
  "indicated", "indicates", "inner", "inside", "insofar", "instead", "into", "inward", "is", "isn", "it", "its", "itself",
  "ve", "just", "keep", "keeps", "kept", "know", "known", "knows", "last", "lastly", "lately", "later", "latter", "latterly",
  "least", "less", "lest", "let", "like", "liked", "likely", "likewise", "little", "look", "looking", "looks", "low", "lower",
  "ltd", "made", "main", "mainly", "make", "makes", "many", "may", "maybe", "mayn", "me", "mean", "meantime", "meanwhile",
  "merely", "might", "mightn", "mine", "minus", "miss", "more", "moreover", "most", "mostly", "mr", "mrs", "ms", "much", "must",
  "mustn", "my", "myself", "name", "namely", "nd", "near", "nearly", "necessary", "need", "needn", "needs", "neither", "never",
  "neverless", "nevertheless", "new", "next", "nine", "ninety", "no", "nobody", "non", "none", "nonetheless", "noone", "one",
  "nor", "normally", "not", "nothing", "notwithstanding", "novel", "now", "nowhere", "obviously", "of", "off", "often", "oh",
  "ok", "okay", "old", "on", "once", "ones", "only", "onto", "opposite", "or", "other", "others", "otherwise", "ought",
  "oughtn", "our", "ours", "ourselves", "out", "outside", "over", "overall", "own", "particular", "particularly", "past",
  "per", "perfectly", "perhaps", "placed", "please", "plus", "possible", "presumably", "probably", "provided", "provides",
  "que", "quick", "quickly", "quite", "qv", "rather", "rd", "re", "really", "reasonably", "recent", "recently", "regarding",
  "regardless", "regards", "relatively", "respectively", "right", "round", "said", "same", "saw", "say", "saying", "says",
  "second", "secondly", "see", "seeing", "seem", "seemed", "seeming", "seems", "seen", "self", "selves", "sensible", "sent",
  "serious", "seriously", "seven", "several", "shall", "shan", "she", "should", "shouldn", "since", "six", "so", "some",
  "somebody", "someday", "somehow", "someone", "something", "sometime", "sometimes", "somewhat", "somewhere", "soon", "sorry",
  "specified", "specify", "specifying", "still", "sub", "such", "sup", "sure", "surely", "take", "taken", "taking", "tell",
  "tends", "th", "than", "thank", "thanks", "thanx", "that", "thats", "the", "their", "theirs", "them", "themselves", "then",
  "thence", "there", "thereafter", "thereby", "therefore", "therein", "theres", "thereupon", "these", "they", "thing", "things",
  "think", "third", "thirty", "this", "thorough", "thoroughly", "those", "though", "three", "thrice", "through", "throughout",
  "thru", "thus", "thusly", "till", "to", "together", "too", "took", "toward", "towards", "tried", "tries", "truly", "try",
  "trying", "twice", "two", "un", "under", "underneath", "undoing", "unfortunately", "unless", "unlike", "unlikely", "until",
  "unto", "up", "upon", "upwards", "us", "use", "used", "useful", "uses", "using", "usually", "utterly", "value", "various",
  "versus", "very", "via", "viz", "vs", "want", "wants", "was", "wasn", "way", "we", "welcome", "well", "went", "were", "weren",
  "what", "whatever", "when", "whence", "whenever", "where", "whereafter", "whereas", "whereby", "wherein", "whereupon",
  "wherever", "whether", "which", "whichever", "while", "whilst", "whither", "who", "whoever", "whole", "wholly", "whom",
  "whomever", "whose", "why", "will", "willing", "wish", "with", "within", "without", "wonder", "wondered", "wondering", "won",
  "worst", "would", "wouldn", "yes", "yet", "you", "your", "yours", "yourself", "yourselves", "zero", "на", "в", "и", "от", "е", "http",
  "html", "то", "за", "при", "по", "го", "bg", "en", "мо", "са", "ви", "не", "се", "d0", "d1", "b5", "b8", "към", "b0", "1", "80", "b3",
  "ro", "po", "ро", "2", "eet", "си", "тази", "това", "ок", "00", "но", "ще", "или", "т", "22", "да", "в", "нещо", 'с', "със", "във",
  "трябва", "като", "я", "и", "защото", "защо", "още", 'ако', "има", "30", 'а', "че", "може", "можете", "някои", "някоя", "някое", "някой",
  "неща", "други", "др", "неща", "нещата", "около", "ми", "има", "имате", "имат"]


# class Counter
#   def frequencies(text)
#     words = TextParser.new(text).split
#     frequencies = Hash.new(0)
#     words.each { |word| frequencies[word] += 1 unless WORDS_TO_IGNORE.include? word }
#     frequencies
#   end
# end

class TextParser
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

  def find
    f = Hash.new(0)
    @phrases.each do |phrase|
      frequencies = TextParser.new(phrase).split.select { |word| @kwords.include? word }.size
      f[phrase] += frequencies if frequencies > 0
    end
    f.sort_by { |word, count| -count }
  end
end


