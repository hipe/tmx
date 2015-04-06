module Skylab::Snag

  class Models_::Tag_Collection

    Actions = THE_EMPTY_MODULE_

    # ->

      def initialize body_s, identifer
        self._REDO
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

      def to_a
        to_enum.map do |shell_with_flyweight_as_kernel|
          shell_with_flyweight_as_kernel.duplicate
        end
      end

      def each & p
        to_enum( & p )  # we keep it explicitly separate for now
      end

      def to_enum
        if block_given?
          scn = to_stream ; x = nil
          yield x while x = scn.gets ; nil
        else
          enum_for :to_enum
        end
      end

      def to_stream
        scanner = Models::Hashtag.value_peeking_stream @body_s
        flyweight = Flyweight__.new -> { scanner.peek_for_value }
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

      def build_controller delegate
        self.class::Controller__.new self, delegate
      end

      def get_body_s
        @body_s.dup
      end

      def set_body_s s
        @body_s = s ; nil
      end

      class Flyweight__

        def initialize p
          @peek_for_value_p = p
        end

        def replace symbol
          @symbol = symbol
        end

        def duplicate_kernel
          dup
        end

        def stem_i
          @symbol.local_normal_name
        end

        def to_string
          @symbol.to_s
        end

        def tag_start_offset_in_node_body_string
          @symbol.pos
        end

        def tag_value_x
          x = @peek_for_value_p[]
          x and x.to_s
        end
      end

      # <-
  end
end
