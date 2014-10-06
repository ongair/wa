require 'spec_helper'
# require 'pbkdf2'

describe WhatsApp::Protocol::Connection do
	context 'Constants' do
		it { expect(WhatsApp::Protocol::Connection::WHATSAPP_VERSION).to eql('2.11.301') }
		it { expect(WhatsApp::Protocol::Connection::DEVICE).to eql('Android') }
		it { expect(WhatsApp::Protocol::Connection::WHATSAPP_HOST).to eql('c.whatsapp.net') }
		it { expect(WhatsApp::Protocol::Connection::PORT).to eql(5222) }
		it { expect(WhatsApp::Protocol::Connection::OPERATION_TIMEOUT).to eql(2) }
		it { expect(WhatsApp::Protocol::Connection::CONNECT_TIMEOUT).to eql(5) }
	end

	context 'Connectivity' do
		subject { WhatsApp::Protocol::Connection }

		it "creates a socket to the right url" do
			connection = subject.new '12345'
			socket_stub = WhatsApp::Net::TCPSocket.stubs(:new).with(WhatsApp::Protocol::Connection::WHATSAPP_HOST,
				WhatsApp::Protocol::Connection::PORT,
				WhatsApp::Protocol::Connection::OPERATION_TIMEOUT,
				WhatsApp::Protocol::Connection::CONNECT_TIMEOUT,
				nil)
			connection.connect
		end
	end

end