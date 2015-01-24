module Skylab::Cull

  class Models_::Function_

    class Unmarshal__  # see #note-006 in [#006]

      def initialize & oes_p
        @on_event_selectively = oes_p
      end

      def unmarshal s
        @scn = Cull_.lib_.string_scanner s
        ok = parse_prefix_and_resolve_box_module
        ok &&= parse_function_name_and_resolve_function
        ok &&= parse_any_args
        ok and flush
      end

      def unmarshal_via_call_expression_and_module s, box_mod
        @box_mod = box_mod

        @prefix_name = Callback_::Name.via_module(
          Cull_.lib_.basic::Module.value_via_relative_path( box_mod, '..' ) )

        @scn = Cull_.lib_.string_scanner s
        ok = parse_function_name_and_resolve_function
        ok &&= parse_any_args
        ok and flush
      end

    private

      def flush
        Function_.new @args, @defined_function, @prefix_name.as_lowercase_with_underscores_symbol
      end

      def parse_prefix_and_resolve_box_module
          parse_prefix and resolve_box_module
      end

      def parse_prefix
        s = @scn.scan PREFIX_RX___
        if s
          @scn.skip COLON_RX___
          @prefix = s
          ACHIEVED_
        else
          expecting :prefix, PREFIX_RX___
        end
      end

      COLON_RX___ = /:/
      PREFIX_RX___ = /[a-z](?:[a-z-]*[a-z])?(?=:)/

      def resolve_box_module

        @prefix_name = Callback_::Name.via_slug @prefix

        @box_mod = Cull_::Models_.const_get(
          @prefix_name.as_const,
          false )::Items__

        ACHIEVED_
      end

      def parse_function_name_and_resolve_function
          parse_function_name and resolve_function
      end

      def parse_function_name
        s = @scn.scan FUNC_NAME_RX___
        if s
          @function_name = s
          ACHIEVED_
        else
          expecting :function_name, FUNC_NAME_RX___
        end
      end

      FUNC_NAME_RX___ = /[a-z](?:[a-z0-9-]+[a-z0-9])?/

      def resolve_function

        nm = Callback_::Name.via_slug @function_name
        i_a = @box_mod.constants

        found_a = Cull_.lib_.basic::Fuzzy.reduce_array_against_string(
          i_a, nm.as_const.id2name.downcase )

        case 1 <=> found_a.length
        when  1 ; when_none nm, i_a
        when  0 ; when_one found_a.first
        when -1 ; self._DO_ME_when_ambiguous found_a, i_a
        end
      end

      def when_none nm, i_a
        maybe_send_event :error, :uninitialized_constant do
          build_not_OK_event_with :uninitialized_constant, :constant, nm.as_const
        end
        UNABLE_
      end

      include Simple_Selective_Sender_Methods_

      def when_one const

        x = Autoloader_.const_reduce do | o |
          o.from_module @box_mod
          o.const_path [ const ]
          # o.result_in_name_and_value  # name is not case-corrected
        end

        p = Callback_.distill

        tgt_sym = p[ const ]

        correct = @box_mod.constants.detect do | const_ |
          tgt_sym == p[ const_ ]
        end

        const = correct

        @defined_function = if x.respond_to? :name
          x
        else
          Proc_Wrapper___.new x, const, @box_mod
        end

        ACHIEVED_
      end

      class Proc_Wrapper___

        def initialize * a
          @p, @const, @mod = a
        end

        def hash
          @p.hash + @const.hash
        end

        def eql? otr
          @p == otr.p && @const == otr.const
        end

      protected

        attr_reader :const, :p

      public

        def members
          [ :[], :name ]
        end

        def name
          "#{ @mod.name }::#{ @const }"
        end

        def [] * a, & p
          @p[ * a , & p ]
        end
      end

      def parse_any_args
        if @scn.eos?
          @args = nil
          ACHIEVED_
        elsif @scn.skip OPEN_PAREN_RX__
          if @scn.skip CLOSE_PAREN_RX__
            if @scn.eos?
              @args = nil
              ACHIEVED_
            else
              expecting :end_of_string
            end
          else
            go_money
          end
        else
          expecting :open_parenthesis, OPEN_PAREN_RX__
        end
      end

      OPEN_PAREN_RX__ = /[ \t]*\(/

      def go_money
        args = []
        ok = true
        @scn.skip BLANKS_RX__
        begin

          if @scn.skip DOUBLE_QUOTE_RX__

            ok = parse_double_quoted_string
            ok or break
            args.push ok

          elsif s = @scn.scan( FLOAT_RX___ )

            args.push s.to_f

          elsif s = @scn.scan( INTEGER_RX___ )

            args.push s.to_i

          elsif @scn.skip COMMA_RX__

            @scn.skip BLANKS_RX__

            args.push nil

            redo
          else

            args.push @scn.scan FREE_CONTENT_RX___
          end

          @scn.skip BLANKS_RX__

          if @scn.skip COMMA_RX__
            @scn.skip BLANKS_RX__
            redo
          end

          if @scn.skip CLOSE_PAREN_RX__
            @scn.skip BLANKS_RX__
            break
          end

          ok = false
          expecting :comma_or_close_parenthesis
        end while nil

        if ok

          if @scn.eos?
            @args = args
          else
            ok = false
            expecting :no_more_input
          end
        end
        ok
      end

      BLANKS_RX__ = /[ \t]+/
      CLOSE_PAREN_RX__ = /\)/
      COMMA_RX__ = /,/
      FLOAT_RX___ = /-?\d+\.\d+/  # scientific notation meh
      x = '[^ \t,"\(\)\[\]]'
      FREE_CONTENT_RX___ = /#{ x }(?:[^,"\(\)\[\]]*#{ x })?/
      DOUBLE_QUOTE_RX__ = /"/
      INTEGER_RX___ = /-?\d+/

      def parse_double_quoted_string
        s = @scn.scan QUOTED_STRING_TAIL_RX___
        if s
          @scn.skip DOUBLE_QUOTE_RX__
          s
        else
          expecting :end_quote
          UNABLE_
        end
      end

      QUOTED_STRING_TAIL_RX___ = /(\\"|[^"])*(?=")/
    end
  end
end
