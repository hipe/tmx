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
    #     Foo.new( :four, "frick" )  # => ArgumentError: unrecognized keyword 'four' - did you mean two?
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

          if @client_class.respond_to? :release_any_next_fld_attrs
            p = -> fld do
              x_a_a = @client_class.release_any_next_fld_attrs
              x_a_a and fld.x_a_a_full x_a_a ; nil
            end
          end

          _muxer = MetaHell_::Lib_::Method_added_muxer[ @definee ]
          _muxer.for_each_method_added_in @p, -> m do
            @box.add m, Field_From_Method__.new( m, p )
          end ; nil

        end

      private

        def prcss_iambic
          if @i_a.length.zero?
            shell = DEFAULT_SHELL__.dup
          else
            if 1 == @i_a.length
              shell = MACRO_H__[ @i_a.first ]
              shell &&= shell.dup
            end
            if ! shell
              shell = Fields.start_shell.with_iambic_unobtrusive_fully @i_a
            end
          end
          if ! shell.client_class
            shell.client_class = eval 'self', @p.binding
          end
          if ! shell.definee_module
            shell.definee_module = shell.client_class
          end
          @client_class = shell.client_class
          @definee = shell.definee_module
          @box = shell.flush ; nil
        end

        class Field_From_Method__ < Aspect_
          def absorb_into_client_iambic client, x_a
            client.send @method_i, x_a ; nil
          end
          def accept_into_client_scan client, scan
            client.send @method_i, scan ; nil
          end
          def notify_client_of_scan client, _scan_
            client.send @method_i
          end
          attr_reader :desc_p
        private
          def prs_desc
            if @x_a.first.respond_to? :call
              @desc_p = @x_a.shift
            else
              @desc_a ||= []
              @desc_p = -> y { @desc_a.each { |s| y << s } ; nil }
              begin
                @desc_a << @x_a.shift.freeze
              end while @x_a.first.respond_to?( :ascii_only? )
            end ; nil
          end
        end

        DEFAULT_SHELL__ = Fields.start_shell.frozen  # NO ARGS

        MACRO_H__ = {
          argful: Fields.start_shell.frozen( :overriding, :globbing,
            :argful, :destructive, :absorber, :initialize ) }
      end
    end


    # here's an experimental hack to add metadata to the following field
    # like so
    #
    #     class Foo
    #       MetaHell::Fields::From.methods :use_o_DSL do
    #
    #         o :desc, "a", "b"
    #         o :desc, "c"
    #         def foo
    #         end
    #
    #         o :desc, -> y { y << "ok." }
    #         def bar
    #         end
    #       end
    #     end
    #
    #     Foo::FIELDS_[:foo].desc_p[ a = [] ]
    #     a  # => %w( a b c )
    #
    #     Foo::FIELDS_[:bar].desc_p[ a = [] ]
    #     a.first  # => "ok."

  end
end
