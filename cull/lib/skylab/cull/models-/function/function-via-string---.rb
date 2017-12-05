module Skylab::Cull

  class Models_::Function_

    class Unmarshal__  # see [#006.G]

      def initialize & p
        @_emit = p
      end

      def unmarshal s

        @scn = Home_.lib_.string_scanner s
        ok = parse_prefix_and_resolve_box_module
        ok &&= _parse_function_name_and_resolve_function
        ok &&= parse_any_args
        ok and flush
      end

      def unmarshal_via_call_expression_and_module s, box_mod

        @box_mod = box_mod

        _mod = Home_.lib_.basic::Module.value_via_relative_path box_mod, DOT_DOT_

        @prefix_name = Common_::Name.via_module _mod

        @scn = Home_.lib_.string_scanner s
        ok = _parse_function_name_and_resolve_function
        ok &&= parse_any_args
        ok and flush
      end

    private

      def flush
        Here_.new @args, @defined_function, @prefix_name.as_lowercase_with_underscores_symbol
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

        @prefix_name = Common_::Name.via_slug @prefix

        _const = @prefix_name.as_const

        _mod = Home_::Models_.const_get _const, false

        @box_mod = _mod::Items__

        ACHIEVED_
      end

      def _parse_function_name_and_resolve_function
        __parse_function_name && __resolve_function
      end

      def __parse_function_name
        s = @scn.scan FUNC_NAME_RX___
        if s
          @_function_slug_head = s
          ACHIEVED_
        else
          expecting :function_name, FUNC_NAME_RX___
        end
      end

      FUNC_NAME_RX___ = /[a-z](?:[a-z0-9-]+[a-z0-9])?/

      def __resolve_function

        # in one way we are strict and in another way lenient. strictly:
        #   - function consts in the code must be Function_cased
        #   - function names in the files must be slug-cased
        # but leniently:
        #   - you need only provide a unique head of the function name
        #     (i.e only the start of the slug not the full slug)

        _proto = Fuzzy_lookup_fuction_name_prototype___[]
        a = _proto.call_by do |o|

          o.stream = @box_mod.to_special_boxxy_item_name_stream__

          o.string = @_function_slug_head
        end

        case 1 <=> a.length
        when  0 ; __when_one a.fetch 0
        when  1 ; __when_zero
        when -1 ; self._DO_ME_when_ambiguous found_a, i_a
        end
      end

      Fuzzy_lookup_fuction_name_prototype___ = Lazy_.call do

        Home_.lib_.basic::Fuzzy.prototype_by do |o|

          o.string_via_item_by do |name|
            name.as_slug
          end

          o.result_via_matching_by do |name|
            # this const should not be Wide_Camel_Cased but Function_cased
            # (preserve the casing that the name function was constructed with)
            name.as_const
          end
        end
      end

      def __when_zero

        _partial_const = FUNCTION_NAME_CONVENTION_[ @_function_slug_head ]

        @_emit.call :error, :uninitialized_constant do

          Build_not_OK_event_[ :uninitialized_constant, :constant, _partial_const ]
        end
        UNABLE_
      end

      def __when_one const

        x = @box_mod.const_get const, false

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

      DOT_DOT_ = '..'
      QUOTED_STRING_TAIL_RX___ = /(\\"|[^"])*(?=")/
    end
  end
end
