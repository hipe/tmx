module Skylab::Basic

  module Yielder

    class Mapper  # :[#056].

      # see also [#hu-047] for a stream version
      # see also [#ca-047] for more complex version

      def initialize * x_a

        st = Callback_::Polymorphic_Stream.via_array x_a

        y = st.gets_one
        if y
          self.downstream_line_yielder = y
        end

        begin
          instance_variable_set IVARS___.fetch( st.gets_one ), st.gets_one
        end until st.no_unparsed_exists
      end

      IVARS___ = {
        first: :@on_first_string,
        subsequent: :@on_subsequent_string,
      }

      def initialize_copy _
        @y = nil
      end

      def downstream_line_yielder= y
        reset
        @y = ::Enumerator::Yielder.new do |s|
          send @_m, s
        end
        @downstream_line_yielder = y
      end

      def reset
        @_m = :___receive_first_line ; nil
      end

      def ___receive_first_line s
        _ = @on_first_string[ s ]
        @downstream_line_yielder << _
        @_m = :___receive_subsequent_line
        NIL_
      end

      def ___receive_subsequent_line s
        _ = @on_subsequent_string[ s ]
        @downstream_line_yielder << _
        NIL_
      end

      attr_reader(
        :on_first_string,
        :on_subsequent_string,
        :y,
      )
    end

    # <-

  class Counting < ::Enumerator::Yielder

    # do what ::Enumerator::Yielder does but maintain an internal count of
    # how many times either `<<` or `yield` was called.

    def initialize
      super
      @count = 0
    end

    attr_reader :count  # after above

    i_a = %i| yield << |
    i_a_ = ancestors[ 1 ].public_instance_methods( false )

    i_a != i_a_ and fail "greetings from the past - please update me to #{
      }accomodate these new Yielder methods - #{ ( i_a_ - i_a ).inspect }"

    # LOOK we write the below literally just for whatever, readability,
    # but be careful! the below should parallel i_a above

    def yield( * )
      @count += 1
      super
    end

    def <<( * )
      @count += 1
      super
    end
  end

  # ->

    class Byte_Downstream_Identifier  # :+[#br-019.D]

      def initialize yld

        @_yielder = yld
      end

      def to_minimal_yielder

        @_yielder
      end

      def shape_symbol

        :yielder
      end
    end
  end
end
