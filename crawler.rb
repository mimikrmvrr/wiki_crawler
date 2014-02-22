class Crawler
  attr_reader :frequencies

  def crawl(page, level, *keywords)
    if keywords
      keywords = keywords.first
    end
    frequencies = Hash.new(0)
    queue = [page]
    until queue.empty?
      current_page = queue.shift
      if current_page.level <= level
        current_page.create_local_file
        text = ""
        File.open(current_page.file_name) { |file|  text = file.read }
        counter = (keywords ? Searcher.new(keywords, text) : TextParser.new(text))
        weight = (keywords ? 1 : current_page.weight)
        new_frequencies = counter.frequencies
        new_frequencies.keys.each { |key| frequencies[key] = 0 unless frequencies.keys.include? key }
        frequencies.merge!(new_frequencies) { |word, current_count, new_count| current_count + new_count * weight }
        queue << current_page.neighbours
        queue.flatten!
      else
        break
      end
    end
    @frequencies = frequencies.sort_by { |word, count| -count }
    keywords ? format(keywords) : format
  end

  def format(*keywords)
    if keywords.empty?
      frequencies_string = @frequencies.first(20).map { |phrase, _| "#{phrase} " }.reduce(&:+)
      frequencies_string[-1] = "\n"
      "Possible categories: #{frequencies_string}"
    else
      keywords = keywords.first
      frequencies_string = @frequencies.first(20).map { |phrase, count| "#{phrase} - #{count} times\n" }.reduce(&:+)
      "Found matches: #{frequencies_string}"
    end
  end
end
