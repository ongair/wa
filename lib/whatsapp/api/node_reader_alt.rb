require 'yaml'

module Whatsapp
  module Api

    class NodeReaderAlt
      DICTIONARY_PATH = File.join(File.dirname(__FILE__), 'dictionary.yml')
      DICTIONARY      = YAML.load_file(DICTIONARY_PATH)
    end

  end
end
