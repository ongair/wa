require 'spec_helper'

describe Whatsapp do

  it 'should have a version number' do
    Whatsapp::VERSION.should_not be_nil
  end

end
