module Skylab::Brazen

  module CLI_Support

    class Syntax_Assembly

      # session.

      class << self

        def brackets_for_reqity_ opt_req_rest_sym
          _singleton.__brackets_for_reqity opt_req_rest_sym
        end

        def render_as_argument_uninflected_for_arity__ prp  # (with default styling)
          _singleton._render_moniker_for_property prp
        end

        def _singleton
          Singleton___[]
        end

        alias_method :via, :new
        private :new
      end  # >>

      def initialize op, invocation_reflection

        @_reflection = invocation_reflection
        @_option_parser = op
      end

      def render_main_syntax_string_didactically

        @_parts = []
        ___add_invocation_string_parts
        __add_parts_from_option_parser
        __add_didactic_parts_for_arguments
        s_a = remove_instance_variable :@_parts
        if s_a.length.nonzero?
          s_a.join SPACE_
        end
      end

      def ___add_invocation_string_parts

        s = @_reflection.subprogram_name_string_
        if s
          @_parts.push s
        end
        NIL_
      end

      # -- from & of option-parser

      def render_property_as_option prp

        look_for = "--#{ prp.name.as_slug }"

        found = @_option_parser.top.list.detect do | sw |
          look_for == sw.long.first
        end

        if found
          @_property = prp ; @_switch = found
          __render_as_option
        end
      end

      def __add_parts_from_option_parser

        # :+#experimental: :+#public-API-for-custom-option-parsers

        op = @_option_parser
        if op
          if op.respond_to? :main_syntax_string_parts
            ___when_custom_option_parser
          else
            __when_standard_libraryesque_option_parser
          end
        end
        remove_instance_variable :@_option_parser
        NIL_
      end

      def ___when_custom_option_parser

        s_a = @_option_parser.main_syntax_string_parts
        if s_a
          @_parts.concat s_a
        end
        NIL_
      end

      def __when_standard_libraryesque_option_parser

        @_option_parser.top.list.each do | sw |

          s = sw.short.first
          if ! s
            next
          end
          if SHORT_HELP == s
            next
          end
          s_ = ___add_parts_for_option_parser_switch sw
          if s_
            @_parts.push s_
          end
        end
        NIL_
      end

      def ___add_parts_for_option_parser_switch sw

        _head = _shortest_moniker_for sw

        arity_sym = _argument_arity_of sw

        if :zero != arity_sym
          _moniker = _some_option_argument_moniker_for sw
        end

        _tail = _render_option_argument_moniker_and_arity _moniker, arity_sym

        "[#{ _head }#{ _tail }]"
      end

      def __render_as_option

        _head = _shortest_moniker_for @_switch

        arity_sym = _argument_arity_of @_switch

        if :zero != arity_sym
          moniker = @_property.option_argument_moniker
          if ! moniker
            moniker = _some_option_argument_moniker_for opt
          end
        end

        _tail = _render_option_argument_moniker_and_arity moniker, arity_sym

        remove_instance_variable :@_property
        remove_instance_variable :@_switch

        "#{ _head }#{ _tail }"
      end

      # -- support for o.p

      def _argument_arity_of sw

        case sw
        when ::OptionParser::Switch::RequiredArgument ; :one
        when ::OptionParser::Switch::NoArgument ; :zero
        when ::OptionParser::Switch::PlacedArgument ; :zero_or_one_placed
        when ::OptionParser::Switch::OptionalArgument ; :zero_or_one_misplaced
        else
          sw.option_argument_arity
        end
      end

      def _shortest_moniker_for sw
        ( sw.short ? sw.short : sw.long ).first
      end

      def _some_option_argument_moniker_for sw
        Home_::CLI_Support::Option_argument_moniker_via_switch[ sw ]
      end

      def _render_option_argument_moniker_and_arity moniker, arity_sym

        case arity_sym

        when :one
          " #{ moniker }"

        when :zero

        when :zero_or_one_placed
          " [#{ moniker }]"

        when :zero_or_one_misplaced
          "[=#{ moniker }]"

        else
          self._NO
        end
      end

      # -- arguments

      def __add_didactic_parts_for_arguments

        arg_a = @_reflection.didactic_argument_properties

        if arg_a
          Require_fields_lib_[]
          arg_a.each do | prp |
            s = ___render_as_argument prp
            if s
              @_parts.push s
            end
          end
        end

        remove_instance_variable :@_reflection

        NIL_
      end

      def ___render_as_argument prp

        s = _render_moniker_for_property prp

        if Field_::Takes_many_arguments[ prp ]
          s = __render_moniker_as_glob s
        end

        if Field_::Is_effectively_optional[ prp ]
          s = __render_expression_as_optional s
        end
        s
      end

      def _render_moniker_for_property prp

        # (from here on down either don't mutate state or don't use singleton)

        s = prp.argument_argument_moniker
        if s
          s
        else
          ARGUMENT_MONIKER_FORMAT___ % prp.name.as_slug
        end
      end

      ARGUMENT_MONIKER_FORMAT___ = '<%s>'

      def __render_moniker_as_glob moniker
        LONG_GLOB_FORMAT___ % { moniker: moniker }
      end

      LONG_GLOB_FORMAT___ = '%{moniker} [%{moniker} [..]]'
      # SHORT_GLOB_FORMAT___ = '%{moniker} [..]'

      def __render_expression_as_optional s

        _, __ = Brackets_of_arity__[ :zero_or_one ]

        "#{ _ }#{ s }#{ __ }"
      end

      def __brackets_for_reqity opt_req_rest_sym

        Brackets_of_arity__[ Arity_of_reqity___[ opt_req_rest_sym ] ]
      end

      Arity_of_reqity___ = {
        opt: :zero_or_one,
        req: :one,
        rest: :one_or_more,
        # ([#105]storypoint-2 explains why no `block`)
        req_group: :syntactic_group,
      }.method :fetch

      open = '[' ; close = ']'

      Brackets_of_arity__ = {
        zero_or_one: [ open, close ],
        one: nil,
        one_or_more: [ open, ' [..]]' ],
        syntactic_group: %w( { } ),
      }.method :fetch

      Singleton___ = Callback_::Lazy.call do
        Here_.via( NIL_, NIL_ ).freeze
      end

      Here_ = self
    end
  end
end
