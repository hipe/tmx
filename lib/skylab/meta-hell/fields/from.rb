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

    module From_  # :[#053]

      def self.methods &blk
        client = eval 'self', blk.binding
        box = Touch_client_and_give_box_[ :_FIXME_absrb, client ]
        Method_Added_Muxer[ client ].in_block_each_method_added blk do |m|
          if box.has_field_attributes
            fa = box.delete_field_attributes
            p = -> fld do
              if (( x = fa.desc ))
                fld.desc_p = x.respond_to?( :call ) ? x : -> y { y << x }
              end
            end
          end
          box.add m, Field_From_Method_.new( m, p )
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

    # an extreme hack exists that lets you add metadata to these nodes
    # like so (for now)
    #
    #     class Foo
    #       MetaHell::FUN::Fields_::From_.methods do
    #         FIELDS_.set :next_field, :desc, -> y { y << "ok." }
    #         def bar
    #         end
    #       end
    #     end
    #
    #     Foo::FIELDS_[:bar].desc_p[ a = [ ] ]
    #     a.first  # => "ok."

  end
end
