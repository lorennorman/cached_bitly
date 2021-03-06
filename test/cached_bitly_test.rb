require 'test_helper'

class TestCachedBitly < Test::Unit::TestCase
  def setup
    CachedBitly.redis.flushdb
    CachedBitly.allowed_hostnames = []
    CachedBitly.stats_enabled = false
  end

  def stub_remote_bitly
    response = Class.new
    response.stubs(:short_url).returns('http://bit.ly/233')
    response.stubs(:long_url).returns('https://garrettbjerkhoel.com')
    CachedBitly.bitly_client.stubs(:shorten).returns(response)
  end

  def test_clean_with_whitelisted_urls
    stub_remote_bitly
    CachedBitly.allowed_hostnames = ['garrettbjerkhoel.com']
    content = "<p>Welcome <a href=\"http://garrettbjerkhoel.com\">@dewski</a>!</p>"
    assert_equal content, CachedBitly.clean(content)
  end

  def test_clean_without_whitelisted_urls
    stub_remote_bitly
    content = "<p>Welcome <a href=\"http://garrettbjerkhoel.com\">@dewski</a>!</p>"
    rendered_content = "<p>Welcome <a href=\"http://bit.ly/233\">@dewski</a>!</p>"
    assert_equal rendered_content, CachedBitly.clean(content)
  end

  def test_remote_shorten_url
    stub_remote_bitly
    assert_equal \
      'http://bit.ly/233',
      CachedBitly.shorten('https://garrettbjerkhoel.com'),
      'should return the shortened url'
  end

  def test_saving_long_and_short_url
    assert CachedBitly.save('https://github.com/dewski', 'http://bit.ly/123df'), 'should save'
    assert_equal 'http://bit.ly/123df', CachedBitly.fetch('https://github.com/dewski'), 'should have stored url'
  end

  def test_failing_url_fetch_with_fallback
    CachedBitly.stubs(:shortened).returns(false)
    CachedBitly.stubs(:shorten).returns(false)

    assert_equal \
      'http://garrett.com',
      CachedBitly.fetch('https://garrettbjerkhoel.com', 'http://garrett.com'),
      'should return the fallback url'
  end

  # Stats
  def test_stats_enabled
    stub_remote_bitly
    CachedBitly.stats_enabled = true
    CachedBitly.redis.expects(:incr).once
    CachedBitly.fetch('https://garrettbjerkhoel.com')
  end

  def test_stats_disabled
    stub_remote_bitly
    CachedBitly.stats_enabled = false
    CachedBitly.redis.expects(:incr).never
    CachedBitly.fetch('https://garrettbjerkhoel.com')
  end

  def test_setting_url_scheme
    stub_remote_bitly
    CachedBitly.url_scheme = 'https'
    assert CachedBitly.save('https://github.com/github', 'http://bit.ly/gzdf13'), 'should save'
    assert_equal 'https://bit.ly/gzdf13', CachedBitly.fetch('https://github.com/github'), 'should return https version'
  end

  def test_setting_invalid_url_scheme
    assert_raises(ArgumentError) {
      CachedBitly.url_scheme = 'ftp'
    }
  end
end
