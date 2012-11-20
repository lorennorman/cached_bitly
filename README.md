# CachedBitly

An easy bit.ly toolkit with Redis as a caching layer.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cached_bitly'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install cached_bitly
```

## Usage

To communicate with bit.ly you'll need your login and API key which you can get from the [Advanced tab](https://bitly.com/a/settings/advanced) within your account settings.

If you set the bit.ly environment variables everything will just work:

```
BITLY_LOGIN=dewski
BITLY_API_KEY=Z_bf4b4fg16991dd72d276e7z9d94d1bc00b
```

There are 2 main methods to interface with bit.ly, the first being just for URLs:

```ruby
CachedBitly.fetch('https://github.com') # => http://bit.ly/WuNWHc
```

If you'd like to just pass in a large block of HTML you can cache multiple links at once:

```ruby
content = "<a href='https://github.com'>GitHub</a> and <a href='https://github.com/dewski'>@dewski</a> join forces"
CachedBitly.clean(content) # => "<a href='http://bit.ly/WuNWHc'>GitHub</a> and <a href='http://bit.ly/10p297A'>@dewski</a> join forces"
```

## Configuring CachedBitly

If you don't want to shorten all links within your HTML you can bypass bit.ly by setting your allowed hostnames:

```ruby
CachedBitly.allowed_hostnames = ['github.com']
content = "<a href='https://github.com'>GitHub</a> and <a href='http://garrettbjerkhoel.com'>Garrett</a> join forces"
CachedBitly.clean(content) # => "<a href='https://github.com'>GitHub</a> and <a href='http://bit.ly/10p297A'>@dewski</a> join forces"
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

