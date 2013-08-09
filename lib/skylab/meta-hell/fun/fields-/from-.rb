module Skylab::MetaHell

  module FUN::Fields_

    # let a class define its fields via particular methods it defines
    # in a special DSL block
    #
    #     class Foo
    #
    #       def one
    #       end
    #
    #       MetaHell::FUN::Fields_::From_.methods do
    #         def two a
    #           @two_value = a.shift
    #         end
    #       end
    #
    #       attr_reader :two_value
    #
    #       def three
    #       end
    #
    #       alias_method :initialize, :absorb
    #     end
    #
    #     Foo.new( :two, "foozle" ).two_value  # => 'foozle'
    #
    # a subclass will inherit the same behavior and fieldset (by default)
    #
    #     class Bar < Foo
    #     end
    #
    #     Bar.new( :two, "fazzle" ).two_value  # => 'fazzle'
    #
    # a subclasss can extend the fieldset (and it won't do the bad thing)
    #
    #     class Baz < Foo
    #
    #       MetaHell::FUN::Fields_::From_.methods do
    #         def four a
    #           @four_value = a.shift
    #         end
    #       end
    #
    #       attr_reader :four_value
    #     end
    #
    #     Baz.new( :four, "frick" ).four_value  # => 'frick'
    #     Foo.new( :four, "frick" )  # => ArgumentError: unrecognized keyword "four" - did you mean two?
    #

    self::Mechanics_.touch

    module From_

      def self.methods &blk
        client = eval 'self', blk.binding
        box = Puff_client_and_give_box_[ :absorb, client ]
        Method_Added_Muxer_[ client ].in_block_each_method_added blk do |m|
          box.add m, Field_From_Method_.new( m )
        end
        nil
      end

      class Field_From_Method_ < Aspect_
        def absorb agent, a
          agent.send @method_i, a
          nil
        end
      end
    end
  end
end
