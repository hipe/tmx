module Skylab::MetaHell

  module Fields

    # let a class define its fields via particular methods it defines
    # in a special DSL block
    #
    #     class Foo
    #
    #       def one
    #       end
    #
    #       MetaHell::Fields::From.methods(
    #         :argful, :overriding, :globbing, :absorber, :initialize
    #       ) do
    #         def two a
    #           @two_value = a.shift
    #         end
    #       end
    #
    #       attr_reader :two_value
    #
    #       def three
    #       end
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
    #       MetaHell::Fields::From.methods :argful do
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

    module From  # :[#053]

      def self.methods *a, &blk
        if blk
          Methods__.iambic_and_block a, blk
        elsif a.length.zero?
          Methods__
        else
          raise ::ArgumentError, "no."
        end
      end
    end

    class From::Methods__

      def self.iambic_and_block a, blk
        client = eval 'self', blk.binding
        new( client, a, blk ).execute
      end

      def initialize client, a, p
        @client = client ; @i_a = a ; @p = p
      end

      def execute
        parse_modifiers
        box = MetaHell_::Fields.box_for_client( * bld_modifiers, @client )
        Method_Added_Muxer[ @client ].in_block_each_method_added @p do |m|
          if box.has_field_attributes
            fa = box.delete_field_attributes
            p = -> fld do
              if (( x = fa.desc ))
                fld.desc_p = x.respond_to?( :call ) ? x : -> y { y << x }
              end
            end
          end
          box.add m, Field_From_Method__.new( m, p )
        end ; nil
      end
    private
      def parse_modifiers
        @explicit_pass_thru = nil
        @d = -1 ; last = @i_a.length - 1
        while @d < last
          send OP_H__.fetch @i_a.fetch @d += 1
        end
      end
      OP_H__ = {
        absorber: :pass_thru_two,  # EEW [#064]
        argful: :parse_argful,
        globbing: :pass_thru_one,
        overriding: :pass_thru_one,
        passive: :pass_thru_one
      }.freeze

      def pass_thru_one
        pass_thru 1
      end

      def pass_thru_two
        pass_thru 2
      end

      def pass_thru d
        @explicit_pass_thru ||= []
        @explicit_pass_thru.concat @i_a[ @d, d ]
        @d += ( d - 1 ) ; nil
      end

      def parse_argful
        # one day use this to knock out [#063]
      end

      def bld_modifiers
        if @explicit_pass_thru
          @explicit_pass_thru
        else
          DEFAULT_MODIFIERS__
        end
      end

      DEFAULT_MODIFIERS__ = [
        :absorber, :absorb_iambic_fully,
        :passive, :absorber, :absorb_iambic_passively ].freeze

      class Field_From_Method__ < MetaHell_::Lib_::Aspect[]
        def absorb_into_client_iambic client, x_a
          client.send @method_i, x_a ; nil
        end
      end
    end

    # an extreme hack exists that lets you add metadata to these nodes
    # like so (for now)
    #
    #     class Foo
    #       MetaHell::Fields::From.methods do
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
