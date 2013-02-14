require 'spec_helper'

describe Whatsapp::Protocol::NodeReader do

  before do
    key        = PBKDF2.new(hash_function: :sha1, password: 'My secret', salt: 'My challenge', iterations: 16, key_length: 20).bin_string
    key_stream = Whatsapp::Protocol::Keystream.new(key)

    @reader     = Whatsapp::Protocol::NodeReader.new
    @reader.key = key_stream
  end

  it 'should' do
    data = "\x00\x00\x05\xf8\x03\x01\x41\xab"

    node = @reader.next_tree(data)
  end

end
