require 'cgi'

module Whatsapp
  module Protocol

    class Node
      attr_accessor :tag, :attributes, :children, :data

      def initialize(tag, attributes = nil, children = nil, data = nil)
        @tag        = tag
        @attributes = attributes || {}
        @children   = children || []
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

      def to_s
        to_xml(false)
      end

      def to_xml(formatted = true)
        xml = "<#{tag}"

        attributes.each { |key, value| xml << " \"#{key}\"=\"#{value}\""}

        if children.any? || data
          xml << ">"
          xml << "#{'\n  ' if formatted && children.any?}#{CGI::escapeHTML(data).unpack('H*').first}" if data
          if children.any?
            xml << "\n" if formatted
            children.each { |node| formatted ? xml << node.to_xml(formatted).lines.map { |l| "  #{l}" }.join << "\n" : xml << node.to_xml(formatted) }
          end
          xml << "</#{tag}>"
        else
          xml << " />"
        end

        xml
      end

    end

  end
end
