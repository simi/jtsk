# JTSK  [![Build Status](https://travis-ci.org/simi/jtsk.svg?branch=master)](https://travis-ci.org/simi/jtsk)

Convert from JTSK to WGS84.

Based on [JTSK Converter](https://github.com/josefzamrzla/JTSK_Converter) by [@josefzamrzla](https://github.com/josefzamrzla).

## Installation

Add this line to your application's Gemfile:

    gem 'jtsk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jtsk

## Usage

```ruby
converter = JTSK::Converter.new
x = 1043033.89
y = 738371.58
result = converter.to_wgs84(x, y) #=> #<struct JTSK::Wgs84Result latitude=50.092696246901404, longitude=14.482746557404647>
result.latitude #=> 50.092696246901404
result.longitude #=> 14.482746557404647
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/jtsk/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
