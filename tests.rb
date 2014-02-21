require './init'
require "test/unit"

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
    expected_links = {"Main page"=>'/main'}
    assert_equal(expected_links, internal_links(get_links(Nokogiri::HTML(html))))
  end

  def test_absolute_urls
    #links = {"Foo"=>"#foo", "Bar"=>"#bar", "Main page"=>'/main'}
    #expected_urls = ['http://www.mediawiki.org/wiki/Installation#foo', 'http://www.mediawiki.org/wiki/Installation#bar', 'http://www.mediawiki.org/main']
    #assert_equal('http://www.mediawiki.org/wiki/Installation#foo', get_absolute_url("#foo"))
    #assert_equal('http://www.mediawiki.org/wiki/Installation#bar', get_absolute_url("#bar"))
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
    assert_equal(["/wiki/Category:Installation",
      "/wiki/Manual:Installation_guide/ca",
      "/wiki/Manual:Installation_guide/cs",
      "/wiki/Manual:Installation_guide/da",
      "/wiki/Manual:Installation_guide/de",
      "/wiki/Manual:Installation_guide/en-gb",
      "/wiki/Manual:Installation_guide/es",
      "/wiki/Manual:Installation_guide/fr",
      "/wiki/Manual:Installation_guide/he",
      "/wiki/Manual:Installation_guide/id",
      "/wiki/Manual:Installation_guide/it",
      "/wiki/Manual:Installation_guide/ja",
      "/wiki/Manual:Installation_guide/ko",
      "/wiki/Manual:Installation_guide/pl",
      "/wiki/Manual:Installation_guide/pt",
      "/wiki/Manual:Installation_guide/pt-br",
      "/wiki/Manual:Installation_guide/ro",
      "/wiki/Manual:Installation_guide/ru",
      "/wiki/Manual:Installation_guide/uk",
      "/wiki/Manual:Installation_guide/yue",
      "/wiki/Manual:Installation_guide/zh",
      "/wiki/Manual:Installation_guide/zh-cn",
      "/wiki/Manual:Installation_guide/zh-hans",
      "/wiki/Manual:Installation_guide/zh-hant",
      "/wiki/Manual:Installation_guide/zh-tw",
      "/wiki/Special:MyLanguage/MediaWiki",
      "/wiki/Special:MyLanguage/Manual:What_is_MediaWiki%3F",
      "/wiki/Special:MyLanguage/Documentation",
      "/wiki/Special:MyLanguage/Customization",
      "/wiki/Special:MyLanguage/Download",
      "/wiki/Special:MyLanguage/Communication",
      "/wiki/Special:MyLanguage/Development",
      "/wiki/Manual:What_is_MediaWiki%3F",
      "/wiki/Manual:MediaWiki_feature_list",
      "/wiki/Special:MyLanguage/Manual:Installation_requirements",
      "/wiki/Download",
      "/wiki/Manual:Installing_MediaWiki",
      "/wiki/Manual:Configuring_MediaWiki",
      "/wiki/Special:MyLanguage/software_bundles",
      "/wiki/Special:MyLanguage/Hosting_services",
      "/w/index.php",
      "/w/index.php",
      "/wiki/Special:MyLanguage/Manual:Upgrading",
      "/wiki/Special:MyLanguage/Download",
      "/wiki/Special:MyLanguage/SQLite",
      "/wiki/Special:MyLanguage/Manual:image_thumbnailing",
      "/wiki/Special:MyLanguage/Texvc",
      "/wiki/Special:MyLanguage/Manual:Installation_requirements",
      "/wiki/Special:MyLanguage/Download",
      "/wiki/Special:MyLanguage/Manual:Config_script",
      "/wiki/Special:MyLanguage/Manual:What_is_MediaWiki%3F",
      "/wiki/Special:MyLanguage/Manual:MediaWiki_feature_list",
      "/wiki/Special:MyLanguage/Manual:Installing_MediaWiki",
      "/wiki/Special:MyLanguage/Manual:Config_script",
      "/wiki/Special:MyLanguage/Manual:Configuring_MediaWiki",
      "/wiki/Special:MyLanguage/Manual:Extensions",
      "/wiki/Special:MyLanguage/Software_appliances",
      "/wiki/Special:MyLanguage/How_to_become_a_MediaWiki_hacker",
      "/wiki/Special:MyLanguage/mediawiki-vagrant",
      "/wiki/Special:MyLanguage/Download_from_Git",
      "/wiki/Special:MyLanguage/Manual:Wiki_on_a_stick",
      "/wiki/Special:MyLanguage/Manual:Configuration",
      "/wiki/Special:MyLanguage/Manual:Administrators",
      "/wiki/Special:MyLanguage/Project:PD_help/Copying",
      "/wiki/Special:MyLanguage/FAQ",
      "/wiki/Special:MyLanguage/MediaWiki_on_IRC",
      "/wiki/Special:MyLanguage/Manual:Installing_MediaWiki",
      "/wiki/Special:MyLanguage/Manual:Installing_MediaWiki",
      "/wiki/Special:MyLanguage/Manual:Running_MediaWiki_on_FreeBSD",
      "/wiki/Special:MyLanguage/Manual:Running_MediaWiki_on_Linux",
      "/wiki/Special:MyLanguage/Manual:Running_MediaWiki_on_ALT_Linux",
      "/wiki/Special:MyLanguage/Manual:Running_MediaWiki_on_Arch_Linux",
      "/wiki/Special:MyLanguage/Manual:Running_MediaWiki_on_Damnsmalllinux",
      "/wiki/Special:MyLanguage/Manual:Running_MediaWiki_on_Debian_GNU/Linux",
      "/wiki/Special:MyLanguage/Manual:Running_MediaWiki_on_Fedora",
      "/wiki/Special:MyLanguage/Manual:Running_MediaWiki_on_Gentoo_Linux",
      "/wiki/Special:MyLanguage/Manual:Running_MediaWiki_on_Mandriva",
      "/wiki/Special:MyLanguage/Manual:Running_MediaWiki_on_Red_Hat_Linux",
      "/wiki/Special:MyLanguage/Manual:Running_MediaWiki_on_Slackware_Linux",
      "/wiki/Special:MyLanguage/Manual:Running_MediaWiki_on_Ubuntu",
      "/wiki/Special:MyLanguage/Manual:Running_MediaWiki_on_Mac_OS_X",
      "/wiki/Special:MyLanguage/Manual:Running_MediaWiki_on_NetWare",
      "/wiki/Special:MyLanguage/Manual:Running_MediaWiki_on_Solaris",
      "/wiki/Special:MyLanguage/Manual:Running_MediaWiki_on_Solaris_10",
      "/wiki/Special:MyLanguage/Manual:Running_MediaWiki_on_Windows",
      "/wiki/Special:MyLanguage/Manual:Installing_MediaWiki_on_Windows_XP",
      "/wiki/Special:MyLanguage/Manual:Installing_MediaWiki_on_Windows_Server_2003",
      "/wiki/Special:MyLanguage/Manual:Installing_MediaWiki_on_Windows_Server_2008",
      "/wiki/Special:MyLanguage/Manual:Installing_MediaWiki_on_Windows_Server_2008_R2",
      "/wiki/Special:MyLanguage/Manual:Newcomers_guide_to_installing_on_Windows",
      "/wiki/Special:MyLanguage/Manual:Streamlined_Windows_Install_Guide",
      "/wiki/Special:MyLanguage/Manual:Simple_Windows_Apache_Installation",
      "/wiki/Special:MyLanguage/MediaWiki_1.19",
      "/wiki/Special:MyLanguage/Software_bundles",
      "/wiki/Special:MyLanguage/Hosting_services",
      "/wiki/Special:MyLanguage/Manual:Before_installing",
      "/wiki/Special:MyLanguage/Manual:Upgrading",
      "/wiki/Special:MyLanguage/Manual:Uninstallation",
      "/wiki/Manual:FAQ",
      "/w/index.php",
      "/wiki/Special:Categories",
      "/wiki/Manual:Installation_guide",
      "/wiki/Manual_talk:Installation_guide",
      "/wiki/Manual:Installation_guide",
      "/w/index.php",
      "/w/index.php",
      "/w/index.php",
      "/wiki/MediaWiki",
      "/wiki/Download",
      "/wiki/Category:Extensions",
      "/wiki/Special:MyLanguage/Communication",
      "/wiki/Help:Contents",
      "/wiki/Manual:Contents",
      "/wiki/Project:Support_desk",
      "/wiki/Bugzilla",
      "/wiki/Development_statistics",
      "/wiki/Category:Top_level",
      "/wiki/Project:Help",
      "/wiki/Special:RecentChanges",
      "/wiki/Project:Current_issues",
      "/w/index.php",
      "/w/index.php",
      "/w/index.php",
      "/wiki/Special:WhatLinksHere/Manual:Installation_guide",
      "/wiki/Special:RecentChangesLinked/Manual:Installation_guide",
      "/wiki/Special:SpecialPages",
      "/w/index.php",
      "/w/index.php",
      "/w/index.php",
      "/wiki/Project:About",
      "/wiki/Project:General_disclaimer"], page.neighbours.map { |page| page.name })
  end

end