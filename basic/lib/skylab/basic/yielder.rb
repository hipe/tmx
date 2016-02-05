module Skylab::Basic

  module Yielder

    class Mapper  # :[#056]. see also [#ca-047] for more complex version

      def initialize * x_a

        st = Callback_::Polymorphic_Stream.via_array x_a

        y = st.gets_one

        sct = Params___.new
        until st.no_unparsed_exists
          sct[ st.gets_one ] = st.gets_one
        end
        first, subsequent = sct.to_a

        subsequent_p = -> s do
          y << subsequent[ s ]
        end

        p = -> s do
          y << first[ s ]
          p = subsequent_p
        end

        first_p = p

        @y = ::Enumerator::Yielder.new do |s|
          p[ s ]
        end

        @_reset = -> do
          p = first_p ; nil
        end
      end

      Params___ = ::Struct.new :first, :subsequent

      def reset
        @_reset[]
      end

      attr_reader(
        :y
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
