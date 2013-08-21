module WhatsApp
  module Protocol

    class Node
      EMPTY_ATTRIBUTES = {}.freeze
      EMPTY_CHILDREN   = [].freeze

      attr_accessor :tag, :attributes, :children, :data

      def initialize(tag, attributes = nil, children = nil, data = nil)
        @tag        = tag
        @attributes = attributes || EMPTY_ATTRIBUTES
        @children   = children || EMPTY_CHILDREN
        @data       = data
      end

      def attribute(name)
        attributes[name]
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
          xml << "#{'\n  ' if formatted && children.any?}#{data.inspect}" if data

          if children.any?
            xml << "\n" if formatted

            children.each do |node|
              if formatted
                xml << node.to_xml(formatted).lines.map { |l| "  #{l}" }.join << "\n"
              else
                xml << node.to_xml(formatted)
              end
            end
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