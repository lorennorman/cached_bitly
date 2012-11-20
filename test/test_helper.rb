require 'rubygems'
require 'bundler'
Bundler.setup(:default, :test)
Bundler.require(:default, :test)

dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'
$TESTING = true

require 'test/unit'
require 'shoulda-context'
require 'mocha'
require 'cached_bitly'

if ENV.key?('GH_REDIS_URL')
  uri = URI.parse(ENV.fetch('GH_REDIS_URL', 'redis://localhost:6139'))
  redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password, :db => 1)
  CachedBitly.redis = redis
end
