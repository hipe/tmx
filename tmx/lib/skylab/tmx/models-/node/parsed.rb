module Skylab::TMX

  class Models_::Node::Parsed

    class << self

      def via h, index, json_file, & p

        box = Common_::Box.new
        extra = nil
        h.each_pair do |s, x|

          attr = index.formal_via_human s
          if attr
            box.add s, AttributeValue___.new( attr,  x )
          else
            ( extra ||= [] ).push s
          end
        end

        if extra
          p.call :error, :expression, :parse_error do |y|
            y << "unrecognized attribute(s) #{ extra.inspect } in #{ json_file }"
          end
          UNABLE_
        else
          new box
        end
      end

      private :new
    end  # >>

    Parsed____ = self

    class Parsed____

      def initialize box
        @box = box
      end

      attr_reader(
        :box,
      )
    end

    # ==

    class AttributeValue___

      def initialize attr, x
        @formal_attribute = attr
        @value_x = x
      end

      attr_reader(
        :formal_attribute,
        :value_x,
      )
    end

    # ==

    class Unparsed

      class << self
        alias_method :via_json_file_path, :new
        undef_method :new
      end  # >>

      def initialize json_file
        @json_file = json_file
      end

      def parse_against index, & p

        json_file = @json_file
        _big_string = ::File.read json_file
        begin
          h = ::JSON.parse _big_string
        rescue ::JSON::ParserError => e
        end

        if e
          p.call :error, :expression, :parse_error do |y|
            y << "    ( while parsing #{ json_file }"
            s_a = e.message.split NEWLINE_
            s_a.each do |s|
              y << "      #{ s }"
            end
            y << "    )"
          end
        else
          Home_::Models_::Node::Parsed.via h, index, @json_file, & p
        end
      end

      def express_into y
        y << get_filesystem_directory_entry_string
      end

      def get_filesystem_directory_entry_string
        ::File.basename ::File.dirname @json_file
      end
    end

    # ==
  end
end
