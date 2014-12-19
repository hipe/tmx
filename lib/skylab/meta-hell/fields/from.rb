module Skylab::MetaHell

  module Fields

    # in this primordial ancestor of `entity`, define fields with methods:
    #
    #     class Foo
    #
    #       def one
    #       end
    #
    #       MetaHell_::Fields::From.methods(
    #         :overriding, :argful, :destructive, :globbing, :absorber, :initialize
    #       ) do
    #
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
    #
    # the "absorber" you defined was globbing, and was `initialize` so:
    #
    #     Foo.new( :two, "foozle" ).two_value  # => 'foozle'
    #
    #
    # a subclass will inherit the same behavior and fieldset (by default)
    #
    #     class Bar < Foo
    #     end
    #
    #     Bar.new( :two, "fazzle" ).two_value  # => 'fazzle'
    #
    #
    # a subclasss can mutate its own fieldset without disturbing parent:
    #
    #     class Baz < Foo
    #
    #       MetaHell_::Fields::From.methods :argful do
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

          _muxer = Touch_method_added_muxer_of__[ @definee ]

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

      class Touch_method_added_muxer_of__  # moved back to [mh] from [br]
        class << self
          def [] mod
            me = self
            mod.module_exec do
              @method_added_mxr ||= me.bld_for self
            end
          end
          def bld_for client
            muxer = new client
            client.send :define_singleton_method, :method_added do |m_i|
              muxer.method_added_notify m_i
            end
            muxer
          end
          private :new
        end
        def initialize reader
          @reader = reader ; @p = nil
        end
        def for_each_method_added_in defs_p, do_p
          add_listener do_p
          @reader.module_exec( & defs_p )
          remove_listener do_p
        end
        def add_listener p
          @p and fail "not implemented - actual muxing"
          @p = p ; nil
        end
        def remove_listener _
          @p = nil
        end
        def stop_listening
          @stopped_p = @p ; @p = nil
        end
        def resume_listening
          @p = @stopped_p ; @stopped_p = nil
        end
        def method_added_notify method_i
          @p && @p[ method_i ] ; nil
        end
      end
    end

    # use the experimental `use_o_DSL` to give yourself the 'o' method
    #
    #     class Fob
    #       MetaHell_::Fields::From.methods :use_o_DSL do
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
    #
    # the `desc` function is an experimental way to add this metadata to
    # the subsequent field.
    #
    # you can add desc strings in long lists or one at a time
    #
    #     Fob::FIELDS_[:foo].desc_p[ a = [] ]
    #     a  # => %w( a b c )
    #
    #
    # you can define desc strings by defining functions that will produce them
    #
    #     Fob::FIELDS_[:bar].desc_p[ a = [] ]
    #     a.first  # => "ok."

  end
end
