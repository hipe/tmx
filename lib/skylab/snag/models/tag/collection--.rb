module Skylab::Snag

  class Models::Tag

    class Collection__

      def initialize body_s, identifer
        @body_s = body_s ; @identifier = identifer ; nil
      end

      attr_reader :identifier

      def find_any_existing_tag_via_tag tag
        s = tag.render
        detect do |tag_|
          s == tag_.render
        end
      end

      def detect & p
        to_enum.detect( & p )
      end

      def to_enum
        if block_given?
          scn = to_scanner ; x = nil
          yield x while x = scn.gets ; nil
        else
          enum_for :to_enum
        end
      end

      def to_scanner
        scanner = Models::Hashtag.scanner @body_s
        flyweight = Flyweight__.new
        tag = Tag_.new flyweight
        Callback_::Scn.new do
          begin
            symbol = scanner.gets
            symbol or break
            if :hashtag == symbol.symbol_i
              flyweight.replace symbol
              result = tag
              break
            end
          end while true
          result
        end
      end

      # ~ for mutation & mutating agents

      def build_controller listener
        self.class::Controller__.new self, listener
      end

      def get_body_s
        @body_s.dup
      end

      def set_body_s s
        @body_s = s ; nil
      end

      class Flyweight__

        def replace symbol
          @symbol = symbol
        end

        def to_string
          @symbol.to_s
        end

        def tag_start_offset_in_node_body_string
          @symbol.pos
        end
      end
    end
  end
end
