class Page
  attr_accessor :level
  attr_reader :name, :html, :weight

  def initialize(url, level=0)
    begin
      @html = Nokogiri::HTML(open(url))
      @name = Url.new(url).path
      #create_local_file
      @level = level
      views = @html.css('li#viewcount').text[/\d+/].to_i
      lastmod = @html.css('li#lastmod').text[-5..-2].to_i
      @weight = 5 + views / 1000 - (Date.today.strftime("%Y").to_i - lastmod)
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
  end

  def content
    @html.css('div#bodyContent').text
  end

  def file_name
    suffix = @name.gsub('/', '_')[1..-1]
    "#{DATA_DIR}/#{suffix}"
  end
end