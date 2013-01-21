require 'spec_helper'

describe Whatsapp::Api do

  it 'should have a version number' do
    Whatsapp::Api::VERSION.wont_be_nil
  end

end
