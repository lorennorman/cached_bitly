require 'cached_bitly/version'
require 'redis'
require 'bitly'
require 'nokogiri'

module CachedBitly
  extend self

  def redis
    @redis ||= Redis.new
  end

  def redis=(redis)
    @redis = redis
  end

  def redis_namespace
    @redis_namespace ||= 'bitly'
  end

  def redis_namespace=(namespace)
    @redis_namespace = namespace
  end

  def allowed_hostnames
    @allowed_hostnames ||= []
  end

  def allowed_hostnames=(hostnames=[])
    @allowed_hostnames = hostnames
  end

  def bitly_client
    @bitly_client ||= begin
      Bitly.use_api_version_3
      Bitly.new(ENV['BITLY_LOGIN'], ENV['BITLY_API_KEY'])
    end
  end

  def bitly_client=(client)
    @bitly_client = client
  end

  def stats_enabled?
    !!@stats_enabled
  end

  def stats_enabled
    @stats_enabled ||= false
  end

  def stats_enabled=(enabled)
    @stats_enabled = enabled
  end

  def clean(html)
    clean_doc(html).css('body').inner_html
  end

  def clean_doc(doc)
    doc = doc.is_a?(Nokogiri::HTML::Document) ? doc : Nokogiri::HTML(doc)
    doc.css('a[href^=http]').each do |link|
      url = link.attributes['href'].value
      if !allowed_hostnames.empty? && url.match(Regexp.union(*allowed_hostnames))
        next
      end
      link.attributes['href'].value = fetch(url)
    end
    doc
  end

  # Handles retreiving cached short urls and generating new
  # ones if we don't have the short url for a particular url.
  #
  # Returns short url, default if save goes wrong.
  def fetch(url, default=url)
    short_url = shortened url
    if short_url
      hit!
      short_url
    else
      miss!
      shorten(url) || default
    end
  end

  # Handles generating the short url and storing it.
  #
  # Returns short url if stored, false if not.
  def shorten(url)
    url = bitly_client.shorten(url)
    if save(url.long_url, url.short_url)
      url.short_url
    else
      false
    end
  end

  # Look to see if the url has already been shortened.
  # If the url has been shortened, return the url.
  #
  # Returns short url if it has been shortened, nil if not
  def shortened(url)
    redis.hget("#{redis_namespace}:url", digest(url))
  end

  # Save the url along with it's associated short url
  # for easy retrieval.
  #
  # Returns true if saved, false if not.
  def save(long_url, short_url)
    !!redis.hset("#{redis_namespace}:url", digest(long_url), short_url)
  end

  def totals
    { :hit   => redis.get("#{redis_namespace}:url:hit").to_i,
      :miss  => redis.get("#{redis_namespace}:url:miss").to_i,
      :total => redis.hlen("#{redis_namespace}:url") }
  end

  private

  def hit!
    return unless stats_enabled?
    redis.incr "#{redis_namespace}:url:hit"
  end

  def miss!
    return unless stats_enabled?
    redis.incr "#{redis_namespace}:url:miss"
  end

  def digest(object)
    Digest::MD5.hexdigest object.to_s
  end
end
