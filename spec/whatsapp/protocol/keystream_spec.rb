require 'spec_helper'
require 'pbkdf2'

describe WhatsApp::Protocol::Keystream do

  before do
    @keystream = WhatsApp::Protocol::Keystream.new('My secret key')
  end

  it 'should encode data and append crc' do
    enc = @keystream.encode('My message')

    enc.encoding.name.must_equal 'ASCII-8BIT'
    enc.must_equal "\x01\x86\x33\xfe\x30\x78\x46\x71\x72\x5f\x42\xf8\x3c\x35".b
  end

  it 'should encode data and prepend crc' do
    enc = @keystream.encode('My message', false)

    enc.encoding.name.must_equal 'ASCII-8BIT'
    enc.must_equal "\x42\xf8\x3c\x35\x01\x86\x33\xfe\x30\x78\x46\x71\x72\x5f".b
  end

  it 'should decode data with prepended crc' do
    enc = "\x42\xf8\x3c\x35\x01\x86\x33\xfe\x30\x78\x46\x71\x72\x5f".b
    dec = @keystream.decode(enc)

    dec.encoding.name.must_equal 'ASCII-8BIT'
    dec.must_equal 'My message'
  end

  it 'should encode empty string' do
    key = PBKDF2.new(hash_function: :sha1, password: 'My secret', salt: 'My challenge', iterations: 16, key_length: 20).bin_string
    key_stream = WhatsApp::Protocol::Keystream.new(key)

    key.must_equal "\xd0\xd5\x49\x6d\x2b\x25\x5b\xe4\xcd\xe1\xd7\x20\xeb\xdc\xff\x8d\x94\x40\x69\xe5".b

    enc = key_stream.encode('')

    enc.encoding.name.must_equal 'ASCII-8BIT'
    enc.must_equal "\x3a\x40\x00\x85".b
  end

end
