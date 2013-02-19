require 'spec_helper'
require 'pbkdf2'

describe WhatsApp::Protocol::Keystream do

  before do
    @key = WhatsApp::Protocol::Keystream.new('My secret key')
  end

  it 'should encode data and append crc' do
    enc = @key.encode('My message')

    enc.must_equal "\x01\x86\x33\xfe\x30\x78\x46\x71\x72\x5f\x42\xf8\x3c\x35"
  end

  it 'should encode data and prepend crc' do
    enc = @key.encode('My message', false)

    enc.must_equal "\x42\xf8\x3c\x35\x01\x86\x33\xfe\x30\x78\x46\x71\x72\x5f"
  end

  it 'should decode data with prepended crc' do
    enc = "\x42\xf8\x3c\x35\x01\x86\x33\xfe\x30\x78\x46\x71\x72\x5f"
    dec = @key.decode(enc)

    dec.must_equal 'My message'
  end

  it 'should encode empty string' do
    key = PBKDF2.new(hash_function: :sha1, password: 'My secret', salt: 'My challenge', iterations: 16, key_length: 20).bin_string
    key_stream = WhatsApp::Protocol::Keystream.new(key)

    key.must_equal "\xd0\xd5\x49\x6d\x2b\x25\x5b\xe4\xcd\xe1\xd7\x20\xeb\xdc\xff\x8d\x94\x40\x69\xe5"
    key_stream.encode('').must_equal "\x3a\x40\x00\x85"
  end

end
