# WhatsApp

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'whatsapp'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install whatsapp

## Usage


  ### Create a client using the phone number and password

  ```
    require 'whatsapp'
    client = WhatsApp::Client.new(phone_number, nickname)
    client.connect
    client.auth(password)

  ```
