require 'spec_helper'

describe Whatsapp::Protocol::Node do

  it 'should return attribute by name' do
    node = Whatsapp::Protocol::Node.new('my-tag', {'one' => 1, 2 => 'two'})

    node.attribute('one').must_equal 1
    node.attribute(2).must_equal 'two'
  end

  it 'should return child by tag name' do
    node = Whatsapp::Protocol::Node.new('my-tag', {}, [
        Whatsapp::Protocol::Node.new('my-child-1', {}, [
            Whatsapp::Protocol::Node.new('my-child-1-child-1', {}, [
                Whatsapp::Protocol::Node.new('my-child-1-child-1-child-1'),
                child = Whatsapp::Protocol::Node.new('my-child-1-child-1-child-2'),
                Whatsapp::Protocol::Node.new('my-child-1-child-1-child-3')
            ]),
            Whatsapp::Protocol::Node.new('my-child-1-child-2'),
            Whatsapp::Protocol::Node.new('my-child-1-child-3')
        ]),
        Whatsapp::Protocol::Node.new('my-child-2'),
        Whatsapp::Protocol::Node.new('my-child-3', {}, [
            Whatsapp::Protocol::Node.new('my-child-1-child-1', {}, [
                Whatsapp::Protocol::Node.new('my-child-1-child-1-child-2')
            ])
        ])
    ])

    node.child('my-child-1-child-1-child-2').must_equal child
  end

end
