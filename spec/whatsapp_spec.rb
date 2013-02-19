require 'spec_helper'

describe WhatsApp do

  it 'should have a version number' do
    WhatsApp::VERSION.should_not be_nil
  end

end
