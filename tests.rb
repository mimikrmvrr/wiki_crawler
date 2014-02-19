require './init'
require "test/unit"

class TestSimpleNumber < Test::Unit::TestCase

  def test_get_base_url
    assert_equal("http://www.mediawiki.org", Url.new("http://www.mediawiki.org/wiki/Installation").base_url)
    assert_equal("https://www.google.bg", Url.new("https://www.google.bg/search?q=google&oq=goo&aqs=chrome.1.69i57j0j69i60j0l2j69i61.2699j0j1&client=ubuntu-browser&sourceid=chrome&ie=UTF-8").base_url)
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

end