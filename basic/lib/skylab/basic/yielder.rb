module Skylab::Basic

  module Yielder

    class Mapper  # :[#056].

      # see also [#hu-047] for a stream version
      # see also [#ca-047] for more complex version

      def map_first_by & p
        @map_first = p
      end

      def map_subsequent_by & p
        @map_subsequent = p
      end

      def initialize_copy _
        @y = nil
      end

      def downstream_yielder= y
        reset
        @y = ::Enumerator::Yielder.new do |x|
          send @_m, x
        end
        @downstream_yielder = y
      end

      def reset
        @_m = :___receive_first_item ; nil
      end

      def ___receive_first_item x
        @downstream_yielder << @map_first[ x ]
        @_m = :___receive_subsequent_item
        NIL_
      end

      def ___receive_subsequent_item x
        @downstream_yielder << @map_subsequent[ x ]
        NIL_
      end

      attr_reader(
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
