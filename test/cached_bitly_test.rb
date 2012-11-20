require 'test_helper'

class TestCachedBitly < Test::Unit::TestCase
  def setup
    CachedBitly.redis.flushdb
  end

  def stub_remote_bitly
    response = Class.new
    response.stubs(:short_url).returns('http://bit.ly/233')
    response.stubs(:long_url).returns('https://garrettbjerkhoel.com')
    CachedBitly.bitly_client.stubs(:shorten).returns(response)
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
end
