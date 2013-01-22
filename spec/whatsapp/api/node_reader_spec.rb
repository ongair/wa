require 'spec_helper'

describe Whatsapp::Api::NodeReader do

  before do
    key        = PBKDF2.new(hash_function: :sha1, password: 'My secret', salt: 'My challenge', iterations: 16, key_length: 20).bin_string
    key_stream = Whatsapp::Api::KeyStream.new(key)

    @reader     = Whatsapp::Api::NodeReader.new
    @reader.key = key_stream
  end

end
