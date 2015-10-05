module Skylab::Fields

  module From_Methods___  # :[#005].

    # in this primordial ancestor of `entity`, define fields with methods:
    #
    #     self._REWRITE_in_reverse  # from the existing tests, all in this file
    #
    #     class Foo
    #
    #       def one
    #       end
    #
    #       M_etaHell_::Fields::From.methods(
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
    #       M_etaHell_::Fields::From.methods :argful do
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


    class << self

      def call_via_arglist a, & defn_p
        Actor___.new( a, & defn_p ).execute
      end
    end  # >>

    class Actor___

      def initialize a, & defn_p
        @i_a = a
        @p = defn_p
      end

      def execute

        __process_iambic

        if @client_class.respond_to? :release_any_next_fld_attrs
          p = -> fld do
            x_a_a = @client_class.release_any_next_fld_attrs
            x_a_a and fld.x_a_a_full x_a_a ; nil
          end
        end

        _muxer = Touch_method_added_muxer_of__[ @definee ]

        _muxer.for_each_method_added_in @p, -> m do
          @box.add m, Field_From_Method___.new( m, p )
        end
        NIL_
      end

      def __process_iambic

        if @i_a.length.zero?
          shell = DEFAULT_SHELL___.dup
        else
          if 1 == @i_a.length
            shell = MACRO_H___[ @i_a.first ]
            shell &&= shell.dup
          end
          if ! shell
            shell = Lib__.start_shell.with_iambic_unobtrusive_fully @i_a
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
        @box = shell.flush
        NIL_
      end
    end

    Lib__ = Home_::Declared

    class Field_From_Method___ < Lib__::Aspect

      def absorb_into_client_iambic client, x_a
        client.send @method_i, x_a
        NIL_
      end

      def accept_into_client_scan client, scan
        client.send @method_i, scan
        NIL_
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
        end
        NIL_
      end
    end

    DEFAULT_SHELL___ = Lib__.start_shell.frozen  # NO ARGS

    _x = Lib__.start_shell.frozen(
      :overriding, :globbing, :argful, :destructive, :absorber, :initialize
    )

    MACRO_H___ = { argful: _x }

      class Touch_method_added_muxer_of__  # it went [m-h]->[br]->[here]

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
        end  # >>

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

    # use the experimental `use_o_DSL` to give yourself the 'o' method
    #
    #     class Fob
    #       M_etaHell_::Fields::From.methods :use_o_DSL do
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
