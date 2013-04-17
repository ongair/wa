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

TODO: Write usage instructions here

## How to sniff HTTPS requests

1. Install [mitmproxy](http://mitmproxy.org/).
2. Set up SSL interception on Desktop AND on the Phone ([Setting up SSL interception](http://mitmproxy.org/doc/ssl.html)).
   * Install mitmproxy-ca-cert.pem on Desktop.
   * Install mitmproxy-ca-cert.pem on the Phone.
3. Connect Desktop to Internet through Ethernet.
4. Share your Ethernet connection using Wi-Fi.
   * OSX: System preferences -> Sharing -> Internet Sharing -> Share Ethernet using Wi-Fi.
5. Connect your phone to the Internet using Desktop's shared Wi-Fi connection.
   * If using OSX -> iOS connection, you must not set any password.
   * If using OSX -> Android connection, you must set WEP/WPA password.
6. Setup HTTP proxy in Phone connection's settings.
   * In iOS, set Server to your Desktop's "bridge" interface IP (192.168.2.1 usually) and Port to 8080.
   * In Android, your device must be rooted if it does not provide any system-wide Proxy settings.
7. Run mitmproxy.
   * If sniffing Android, remember to use --upstream-cert option ([Setting up SSL interception - Android](http://mitmproxy.org/doc/certinstall/android.html))

## How to decompile Android APK

1. Download "WhatsApp Messenger.apk" using Real APK Leecher (Windows only).
2. Unpack the apk using apktool.
3. Use https://code.google.com/p/dex2jar/ to get classes.dex.

## How to compile Android APK

apktool b src

Sign (+ Align) APK:
http://developer.android.com/tools/publishing/app-signing.html

OR:

d2j-apk-sign.sh -f -o app-signed.apk app.apk

Enable installation of APKs from unknown sources.

Install APK:
adb install app.apk

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
