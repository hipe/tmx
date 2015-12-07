module Skylab::Brazen

  class CLI

    class Adapter_Expression__

      # the "expression" (for leaf or branch) is a stateful session that
      # provides a middle-level interface to facilities that render (or
      # "express") the various parts of the node. its lifetime should be
      # identical with the lifetime of the "section boundarizer" (see).
      #
      # it exists primarily in service of the of the "when" nodes (view
      # controllers) as they make the higher-level choices about which
      # sections to express and what order to express them in. they rely on
      # the subject to delegate requests appropriately to express the pieces.

      def initialize line_yielder, expag, op, invocation_reflection

        @_expression_agent = expag

        @_line_yielder = line_yielder

        @_option_parser = op

        @_reflection = invocation_reflection
      end

      # -- for the help screen "when" node

      def express_usage_section

        _primary_syntax_string = _render_main_syntax_string_didactically

        _section_expression.express_section(
          :header, 'usage',
          :tight,

        ) do | y |

          y << _primary_syntax_string  # assume

          @_reflection.write_any_auxiliary_syntax_strings_into_ y
        end
        NIL_
      end

      def express_description

        if Field_::Has_description[ @_reflection ]  # woah

          s_a = Field_::N_lines[ nil, @_expression_agent, @_reflection ]
        end

        if s_a && s_a.length.nonzero?

          _section_expression.express_section(
            :header, 'description',
            :tight_IFF_one_line,

          ) do | y |

            s_a.each( & y.method( :<< ) )
          end
        end

        NIL_
      end

      def express_section * x_a, & x_p

        _section_expression.express_section_via x_a, & x_p
      end

      def option_parser
        @_option_parser
      end

      # -- for general "when" nodes

      def express_primary_usage_line

        _primary_syntax_string = _render_main_syntax_string_didactically

        _section_expression.express_section :header, 'usage', :tight do | y |

          y << _primary_syntax_string  # assume
        end

        NIL_
      end

      def express_invite_to_general_help( * )

        _ = @_reflection.subprogram_name_string_
        __ = Home_::CLI_Support::SHORT_HELP
        _express_invite_to "#{ _ } #{ __ }"  # eek - assumes this
      end

      def expression_agent
        @_expression_agent
      end

      def line_yielder
        @_line_yielder
      end

      # -- for client

      def render_property_as_option_ prp
        _build_syntax_assembly.render_property_as_option prp
      end

      def _build_syntax_assembly
        Home_::CLI_Support::Syntax_Assembly.via @_option_parser, @_reflection
      end

      # -- support

      def _render_main_syntax_string_didactically

        _sxy = _build_syntax_assembly

        _sxy.render_main_syntax_string_didactically
      end

      def _section_expression

        @_section_expression ||= ___build_section_expression
      end

      def ___build_section_expression

        Home_::CLI_Support::Section::Expression.new(
          @_line_yielder,
          @_expression_agent )
      end

      def _express_invite_to command_s

        express do
          "use #{ code command_s } for help"
        end
        NIL_
      end

      def express & p  # for general "when" nodes too

        if p.arity.nonzero?  # #TODO
          self._WHERE
        end

        _ = @_expression_agent.calculate( & p )
        @_line_yielder << _
        NIL_
      end

      class Redundancy_Filter

        def initialize
          @_last_line = nil
        end

        def [] s
          if @_last_line
            "also #{ s }"
          else
            @_last_line = s
            s
          end
        end
      end
    end
  end
end
