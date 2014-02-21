require './init'
require "test/unit"


class TestSimpleNumber < Test::Unit::TestCase

  def test_get_base_url
    assert_equal("http://www.mediawiki.org:80", Url.new("http://www.mediawiki.org/wiki/Installation").base_url)
    assert_equal("https://www.google.bg:443", Url.new("https://www.google.bg/search?q=google&oq=goo&aqs=chrome.1.69i57j0j69i60j0l2j69i61.2699j0j1&client=ubuntu-browser&sourceid=chrome&ie=UTF-8").base_url)
  end

  def test_uri_path
    assert_equal("/wiki/Installation", Url.new("http://www.mediawiki.org/wiki/Installation").path)
    assert_equal("/search", Url.new("https://www.google.bg/search?q=google&oq=goo&aqs=chrome.1.69i57j0j69i60j0l2j69i61.2699j0j1&client=ubuntu-browser&sourceid=chrome&ie=UTF-8").path)
  end

  def test_get_links
    html = "<html>
    <body>
        <a href=#foo>Foo</a>
        <a href=#bar>Bar </a>
    </body>
</html>"
    expected_links = {"Foo"=>"#foo", "Bar"=>"#bar"}
    assert_equal(expected_links, LinkUtils.get_links(Nokogiri::HTML(html)))
  end

  def test_internal_links
    html = "<html>
    <body>
        <a href=#foo>Foo</a>
        <a href=#bar>Bar </a>
        <a href='https://www.google.com'>Google</a>
        <a href='/main'>Main page</a>
    </body>
</html>"
    expected_links = {"Main page"=>'/main'}
    assert_equal(expected_links, LinkUtils.internal_links(LinkUtils.get_links(Nokogiri::HTML(html))))
  end

  def test_absolute_urls
    #links = {"Foo"=>"#foo", "Bar"=>"#bar", "Main page"=>'/main'}
    #expected_urls = ['http://www.mediawiki.org/wiki/Installation#foo', 'http://www.mediawiki.org/wiki/Installation#bar', 'http://www.mediawiki.org/main']
    #assert_equal('http://www.mediawiki.org/wiki/Installation#foo', get_absolute_url("#foo"))
    #assert_equal('http://www.mediawiki.org/wiki/Installation#bar', get_absolute_url("#bar"))
    assert_equal('http://judge.openfmi.net:9080/main', LinkUtils.get_absolute_url("/main"))
    assert_equal('http://judge.openfmi.net:9080/foo', LinkUtils.get_absolute_url("/foo"))
  end

  # def test_absolute_urls_uniq
  #   links = {"Foo"=>"#foo", "Bar"=>"#bar", "Main page"=>'/main', "Main"=>'/main', "IntenalFoo"=>"/foo", "Foobar"=>'#foo'}
  #   expected_urls = ['http://www.mediawiki.org/wiki/Installation#foo', 'http://www.mediawiki.org/wiki/Installation#bar', 'http://www.mediawiki.org/main', 'http://www.mediawiki.org/foo']
  #   assert_equal('http://www.mediawiki.org/wiki/Installation#foo', "#foo")
  #   assert_equal('http://www.mediawiki.org/wiki/Installation#bar', "#bar")
  #   assert_equal('http://www.mediawiki.org/main', "/main")
  # end

  def test_pages
    page = Page.new("http://judge.openfmi.net:9080/mediawiki/index.php/CsClub")
    assert_equal("CsClub", page.heading)
    assert_equal("data/pages/mediawiki_index.php_CsClub", page.file_name)
    assert_equal(["/mediawiki/index.php/%D0%9A%D0%BB%D1%83%D0%B1-2008",
        "/mediawiki/index.php/%D0%A1%D0%BF%D0%B5%D1%86%D0%B8%D0%B0%D0%BB%D0%BD%D0%B8:%D0%9A%D0%B0%D1%82%D0%B5%D0%B3%D0%BE%D1%80%D0%B8%D0%B8",
        "/mediawiki/index.php/%D0%9A%D0%B0%D1%82%D0%B5%D0%B3%D0%BE%D1%80%D0%B8%D1%8F:%D0%9A%D0%BB%D1%83%D0%B1%D0%BD%D0%B8"],
      page.neighbours.map { |page| page.name })
  end

  def test_counter_ignore_words
    text = "This name is a or a is they can be here next"
    counter = Counter.new(text)
    assert_equal({}, counter.frequencies)
  end

  def test_counter
    text = "Badges are primarily shown on the TopCoder websites within a member profile (Studio or Software) or copilot profile.
    They contain the achievement name and date the achievement was earned in a box that is visible upon mouse hover."
    counter = Counter.new(text)
    assert_equal({"badges"=>1,
        "primarily"=>1,
        "shown"=>1,
        "topcoder"=>1,
        "websites"=>1,
        "member"=>1,
        "profile"=>2,
        "studio"=>1,
        "software"=>1,
        "copilot"=>1,
        "achievement"=>2,
        "date"=>1,
        "earned"=>1,
        "box"=>1,
        "visible"=>1,
        "mouse"=>1,
        "hover"=>1},
      counter.frequencies)
  end
end