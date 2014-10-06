require 'spec_helper'

describe WhatsApp do

  it 'should have a version number' do
    expect(WhatsApp::VERSION).to_not be_nil
  end

end
