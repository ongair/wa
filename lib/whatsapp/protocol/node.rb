module Whatsapp
  module Protocol

    class Node
      attr_accessor :tag, :attributes, :children, :data

      def initialize(tag, attributes = {}, children = [], data = nil)
        @tag        = tag
        @attributes = attributes || {}
        @children   = children
        @data       = data
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
