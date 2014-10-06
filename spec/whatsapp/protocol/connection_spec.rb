require 'spec_helper'
# require 'pbkdf2'

describe WhatsApp::Protocol::Connection do
	context 'Constants' do

		it { expect(WhatsApp::Protocol::Connection::WHATSAPP_VERSION).to eql('2.11.301') }
		it { expect(WhatsApp::Protocol::Connection::DEVICE).to eql('Android') }
		it { expect(WhatsApp::Protocol::Connection::WHATSAPP_HOST).to eql('c.whatsapp.net') }
	end
end