require 'spec_helper'

describe WhatsApp::Client do

	describe 'It should log in with the correct steps' do
		
		it "creates a new connection" do
			client = WhatsApp::Client.new('12345')
			client.connection.expects(:connect).once
			client.connection.expects(:auth).once

			client.connect
			client.auth '09876'
		end

	end

end