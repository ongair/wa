require 'spec_helper'

describe Whatsapp::Api::KeyStream do

  before do
    @key = Whatsapp::Api::KeyStream.new('My secret key')
  end

  it 'should encode data and append crc' do
    enc = @key.encode('My message')

    enc.must_equal "\x01\x86\x33\xfe\x30\x78\x46\x71\x72\x5f\x42\xf8\x3c\x35"
  end

  it 'should encode data and prepend crc' do
    enc = @key.encode('My message', false)

    enc.must_equal "\x42\xf8\x3c\x35\x01\x86\x33\xfe\x30\x78\x46\x71\x72\x5f"
  end

  it 'should decode data' do
    enc = "\x42\xf8\x3c\x35\x01\x86\x33\xfe\x30\x78\x46\x71\x72\x5f"
    dec = @key.decode(enc)

    dec.must_equal 'My message'
  end

end
