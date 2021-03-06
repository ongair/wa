require 'spec_helper'

describe WhatsApp::Protocol::NodeReader do

  before do
    key        = PBKDF2.new(hash_function: :sha1, password: 'My secret', salt: 'My challenge', iterations: 16, key_length: 20).bin_string
    key_stream = WhatsApp::Protocol::Keystream.new(key, "")

    @reader           = WhatsApp::Protocol::NodeReader.new
    @reader.keystream = key_stream
  end

  it 'should' do
    data = "\x00\x00\x05\xf8\x03\x01\x41\xab".b

    node = @reader.next_tree(data)
  end

end
