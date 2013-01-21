module Whatsapp
  module Api

    class Node
      attr_accessor :tag, :attributes, :children, :data

      def initialize(tag, attributes = {}, children = [], data = nil)
        self.tag        = tag
        self.attributes = attributes || {}
        self.children   = children
        self.data       = data
      end

      def attribute(name)
        attributes.has_key?(name) ? attributes[name] : nil
      end

      def child(tag)
        children.each do |child|
          if child.tag == tag
            return child
          elsif grandchild = child.child(tag)
            return grandchild
          end
        end

        nil
      end

    end

  end
end
