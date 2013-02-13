# Whatsapp

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'whatsapp'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install whatsapp

## Usage

TODO: Write usage instructions here

## How to sniff HTTPS requests

1. Install [mitmproxy](http://mitmproxy.org/).
2. Set up SSL interception on Desktop AND on the Phone ([Setting up SSL interception](http://mitmproxy.org/doc/ssl.html)).
   * Install mitmproxy-ca-cert.pem on Desktop.
   * Install mitmproxy-ca-cert.pem on the Phone.
3. Connect Desktop to Internet through Ethernet.
4. Share your Ethernet connection using Wi-Fi.
5. Connect your phone to the Internet using Desktop's shared Wi-Fi connection.
6. Setup HTTP proxy in Phone connection's settings (set server to Desktop's Ethernet IP address and Port to 8080).
7. Run mitmproxy.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
