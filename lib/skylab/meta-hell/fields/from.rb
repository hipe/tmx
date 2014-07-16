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
    #         :overriding, :argful, :destructive, :globbing, :absorber, :initialize
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

      class Methods__

        def self.iambic_and_block a, blk
          new( a, blk ).execute
        end

        def initialize a, p
          @i_a = a ; @p = p
        end

        def execute
          prcss_iambic
          Method_Added_Muxer[ @definee ].in_block_each_method_added @p do |m|
            @box.has_field_attributes and p = flsh_field_attrs( @box )
            @box.add m, Field_From_Method__.new( m, p )
          end ; nil
        end
      private
        def prcss_iambic
          case @i_a.length
          when  0
            shell = DEFAULT_SHELL__.dup
          when  1
            shell = MACRO_H__.fetch( @i_a.first ).dup
          else
            shell = Fields.start_shell.with_iambic_unobtrusive_fully @i_a
          end
          if ! shell.client_class
            shell.client_class = eval 'self', @p.binding
          end
          if ! shell.definee_module
            shell.definee_module = shell.client_class
          end
          @definee = shell.definee_module
          @box = shell.flush ; nil
        end
        def flsh_field_attrs box
          fa = box.delete_field_attributes
          -> fld do
            if (( x = fa.desc ))
              fld.desc_p = x.respond_to?( :call ) ? x : -> y { y << x }
            end
          end
        end

        class Field_From_Method__ < MetaHell_::Lib_::Aspect[]
          def absorb_into_client_iambic client, x_a
            client.send @method_i, x_a ; nil
          end
          def accept_into_client_scan client, scan
            client.send @method_i, scan ; nil
          end
        end

        DEFAULT_SHELL__ = Fields.start_shell.frozen(
          :argful, :absorber, :absorb_iambic_fully )

        MACRO_H__ = {
          argful: Fields.start_shell.frozen( :overriding, :globbing,
            :argful, :destructive, :absorber, :initialize ) }
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
