require './init'
require "test/unit"

PAGE_URL = "http://www.mediawiki.org/wiki/Installation"

class TestSimpleNumber < Test::Unit::TestCase

  def test_get_base_url
    assert_equal("http://www.mediawiki.org", Url.new("http://www.mediawiki.org/wiki/Installation").base_url)
    assert_equal("https://www.google.bg", Url.new("https://www.google.bg/search?q=google&oq=goo&aqs=chrome.1.69i57j0j69i60j0l2j69i61.2699j0j1&client=ubuntu-browser&sourceid=chrome&ie=UTF-8").base_url)
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
    assert_equal(expected_links, get_links(Nokogiri::HTML(html)))
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
    expected_links = {"Foo"=>"#foo", "Bar"=>"#bar", "Main page"=>'/main'}
    assert_equal(expected_links, internal_links(get_links(Nokogiri::HTML(html))))
  end

  def test_absolute_urls
    #links = {"Foo"=>"#foo", "Bar"=>"#bar", "Main page"=>'/main'}
    #expected_urls = ['http://www.mediawiki.org/wiki/Installation#foo', 'http://www.mediawiki.org/wiki/Installation#bar', 'http://www.mediawiki.org/main']
    assert_equal('http://www.mediawiki.org/wiki/Installation#foo', get_absolute_url("#foo"))
    assert_equal('http://www.mediawiki.org/wiki/Installation#bar', get_absolute_url("#bar"))
    assert_equal('http://www.mediawiki.org/main', get_absolute_url("/main"))
    assert_equal('http://www.mediawiki.org/foo', get_absolute_url("/foo"))
  end

  # def test_absolute_urls_uniq
  #   links = {"Foo"=>"#foo", "Bar"=>"#bar", "Main page"=>'/main', "Main"=>'/main', "IntenalFoo"=>"/foo", "Foobar"=>'#foo'}
  #   expected_urls = ['http://www.mediawiki.org/wiki/Installation#foo', 'http://www.mediawiki.org/wiki/Installation#bar', 'http://www.mediawiki.org/main', 'http://www.mediawiki.org/foo']
  #   assert_equal('http://www.mediawiki.org/wiki/Installation#foo', "#foo")
  #   assert_equal('http://www.mediawiki.org/wiki/Installation#bar', "#bar")
  #   assert_equal('http://www.mediawiki.org/main', "/main")
  # end

  def test_pages
    page = Page.new(PAGE_URL)
    assert_equal("Manual:Installation guide", page.heading)
    assert_equal("wiki_Installation", page.file_name)
  end

end