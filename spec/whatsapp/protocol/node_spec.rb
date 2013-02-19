require 'spec_helper'

describe WhatsApp::Protocol::Node do

  it 'should return attribute by name' do
    node = WhatsApp::Protocol::Node.new('my-tag', {'one' => 1, 2 => 'two'})

    node.attribute('one').must_equal 1
    node.attribute(2).must_equal 'two'
  end

  it 'should return child by tag name' do
    node = WhatsApp::Protocol::Node.new('my-tag', {}, [
        WhatsApp::Protocol::Node.new('my-child-1', {}, [
            WhatsApp::Protocol::Node.new('my-child-1-child-1', {}, [
                WhatsApp::Protocol::Node.new('my-child-1-child-1-child-1'),
                child = WhatsApp::Protocol::Node.new('my-child-1-child-1-child-2'),
                WhatsApp::Protocol::Node.new('my-child-1-child-1-child-3')
            ]),
            WhatsApp::Protocol::Node.new('my-child-1-child-2'),
            WhatsApp::Protocol::Node.new('my-child-1-child-3')
        ]),
        WhatsApp::Protocol::Node.new('my-child-2'),
        WhatsApp::Protocol::Node.new('my-child-3', {}, [
            WhatsApp::Protocol::Node.new('my-child-1-child-1', {}, [
                WhatsApp::Protocol::Node.new('my-child-1-child-1-child-2')
            ])
        ])
    ])

    node.child('my-child-1-child-1-child-2').must_equal child
  end

end
