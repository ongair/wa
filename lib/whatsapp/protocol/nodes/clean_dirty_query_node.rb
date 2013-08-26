require 'whatsapp/protocol/node'
require 'whatsapp/protocol/nodes/category_node'

module WhatsApp
  module Protocol

    class CleanDirtyQueryNode < Node

      def initialize(dirty_node)
        category_nodes = dirty_node.children.select { |child| child.tag == 'category' }.map do |category|
          CategoryNode.new(category.attribute('name'))
        end

        super('clean', {xmlns: 'urn:xmpp:whatsapp:dirty'}, category_nodes)
      end

    end

  end
end
