require 'spec_helper'

describe WhatsApp::Protocol::AuthNode do
	context 'correct generation' do
		it 'creates correctly without challenge data' do
			node = WhatsApp::Protocol::AuthNode.new('254705866564')
			expect(node.tag).to eql('auth')			
			expect(node.attribute(:mechanism)).to eql('WAUTH-2')
			expect(node.attribute(:user)).to eql('254705866564')
			expect(node.attribute(:xmlns)).to eql('urn:ietf:params:xml:ns:xmpp-sasl')
			expect(node.children).to be_empty
		end
	end
end