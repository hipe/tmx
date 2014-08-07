module Skylab::Brazen

  module CLI

    class Action_Adapter_

      class Help_Renderer  # read [#004]

        def initialize op, kernel
          @action = kernel.action
          @action_adapter = kernel.action_adapter
          @is_branch_view = true
          @expression_agent = kernel.expression_agent
          @invocation = kernel.invocation
          set_op op
          set_parts kernel.partitions
          @section_separator_p = -> { @y << nil }
          @y = ::Enumerator::Yielder.new( & kernel.stderr.method( :puts ) )
          screen_boundary
        end

        attr_reader :expression_agent, :op, :y

        def set_op op
          @op = op
          op and use_formatting_of_option_parser op ; nil
        end

        def set_parts parts
          @arg_a = parts.arg_a ; @env_a = parts.env_a ; nil
        end

        def use_formatting_of_option_parser op
          @summary_indent = op.summary_indent
          @summary_width = op.summary_width ; nil
        end

        def output_help_screen
          output_usage
          @action.has_description and output_description
          output_options
          @arg_a and output_arguments
          @env_a and output_environment_variables
          nil
        end

        # ~ usage lines

        def output_usage
          section_boundary
          output_multiline_section_tight 'usage', get_full_syntax_strings ; nil
        end

        def output_usage_line
          a = [ action_invocation_string ]
          s = ( @action_adapter || @invocation ).render_syntax_string
          s and a.push s
          output_single_line_section 'usage', a * SPACE_
          @action
        end

        def get_full_syntax_strings
          a = []
          s = produce_full_main_syntax_string and a.push s
          s = produce_full_auxiliary_syntax_string and a.push s
          a
        end

        def produce_full_main_syntax_string
          y = [ action_invocation_string ]
          a = any_main_syntax_string_parts and y.concat a
          y * SPACE_
        end

        def produce_main_syntax_string
          a = any_main_syntax_string_parts and a * SPACE_
        end

        def any_main_syntax_string_parts
          r = any_option_glyphs
          a = any_argument_glyphs and r ? r.concat( a ) : ( r = a )
          r
        end

        def action_invocation_string
          if @action_adapter
            "#{ @invocation.invocation_string } #{ @action.name.as_slug }"
          else
            @invocation.invocation_string
          end
        end

        def any_option_glyphs
          sw_s_a = []
          @op.top.list.each do |arg|
            sw = arg.short.first
            SHORT_HELP__ == sw and next
            tail = case arg
            when ::OptionParser::Switch::RequiredArgument ; " X"
            when ::OptionParser::Switch::NoArgument ;
            when ::OptionParser::Switch::OptionalArgument ; " [X]"
            else raise "unepxected shape: #{ sw.class }"
            end
            sw_s_a.push "[#{ sw }#{ tail }]"
          end
          sw_s_a.length.nonzero? and sw_s_a
        end
        SHORT_HELP__ = '-h'.freeze

        def any_argument_glyphs
          @arg_a and arg_glyphs
        end

        def arg_glyphs
          a = @arg_a.map do |prop|
            if prop.has_default
              "[<#{ prop.name.as_slug }>]"
            else
              "<#{ prop.name.as_slug }>"
            end
          end
          a.length.nonzero? and a
        end

        def produce_full_auxiliary_syntax_string
          "#{ action_invocation_string } -h"
        end

        # ~ description, options, arguments & "interjections"

        def output_description
          section_boundary
          output_multiline_section 'description', @action.
            under_expression_agent_get_N_desc_lines( @expression_agent ) ; nil
        end

        def output_options
          section_boundary
          @y << @expression_agent.hdr( 'options' )
          output_option_parser_summary ; nil
        end

        def output_option_parser_summary
          @op.summarize @y ; nil
        end

        def output_arguments
          section_boundary
          output_items_with_descriptions 'argument', @arg_a ; nil
        end

        def output_environment_variables
          section_boundary
          output_items_with_descriptions 'environment variable',
            @env_a, & :environment_name_i ; nil
        end

        def output_invite_to_general_help
          s = action_invocation_string
          express do
            "use #{ code "#{ s } -h" } for help"
          end
        end

        # ~ support

        # ~ render section boundaries

        def screen_boundary
          @is_subsequent_section = false
        end

        def section_boundary
          if @is_subsequent_section
            @section_separator_p && @section_separator_p[]
          else
            @is_subsequent_section = true
          end ; nil
        end

        # ~ two-column item renderers

        def output_items_with_descriptions hdr_s, x_a, d=nil, & labelize_p
          hdr_s and output_header "#{ hdr_s }#{ 's' if 1 != x_a.length }"
          p = bld_item_outputter d, labelize_p, @y
          x_a.each( & p ) ; nil
        end

        def bld_item_outputter num_lines_per, label_p, y
          label_p ||= DEFAULT_LABELIZE_P__
          ex = @expression_agent
          no_desc = bld_item_without_desc_outputter y, label_p
          desc = bld_item_with_desc_outputter y, ex, num_lines_per, label_p
          -> x do
            ( x.has_description ? desc : no_desc )[ x ]
          end
        end
        DEFAULT_LABELIZE_P__ = -> x do
          x.name.as_slug
        end

        def bld_item_without_desc_outputter y, labelize_p
          summary_s = @summary_indent
          -> x do
            y << "#{ summary_s }#{ labelize_p[ x ] }" ; nil
          end
        end

        def bld_item_with_desc_outputter y, expag, num_lines_per, labelize_p
          d = @summary_width ; s = @summary_indent
          first_line_item_format = "#{ s }%-#{ d }s %s"
          d_ = d + s.length + 1  # " " is 1 char wide
          subsequent_line_item_format = "#{ SPACE_ * d_ }%s"
          -> x do
            a = x.under_expression_agent_get_N_desc_lines expag, num_lines_per
            if a.length.zero?
              y << "#{ s }#{ labelize_p[ x ] }"
            else
              y << first_line_item_format % [ labelize_p[ x ], a.fetch( 0 ) ]
            end
            1.upto( a.length - 1 ) do |idx|
              y << subsequent_line_item_format % a.fetch( idx )
            end ; nil
          end
        end

        # ~ multiline section renderers and their headers

        def output_multiline_section hdr_s, line_a
          case 1 <=> line_a.length
          when  0 ; output_single_line_section hdr_s, line_a.fetch( 0 )
          when -1 ; output_multi_line_section hdr_s, line_a
          end ; nil
        end

        def output_multiline_section_tight hdr_s, line_a
          case 1 <=> line_a.length
          when  0 ; output_single_line_section hdr_s, line_a.fetch( 0 )
          when -1 ; output_multi_line_section_tight hdr_s, line_a
          end ; nil
        end

        def output_multi_line_section hdr_s, line_a
          output_header hdr_s
          line_a.each do |line|
            @y << line
          end ; nil
        end

        def output_multi_line_section_tight hdr_s, line_a
          output_single_line_section hdr_s, line_a.fetch( 0 )
          margin = SPACE_ * ( hdr_s.length + 2 )  # ": " is 2 chars wide
          line_a[ 1 .. -1 ].each do |line|
            @y << "#{ margin }#{ line }"
          end ; nil
        end

        def output_single_line_section hdr_s, line
          @y << "#{ @expression_agent.hdr hdr_s } #{ line }"
        end

        def output_header hdr_s
          @y << @expression_agent.hdr( hdr_s ) ; nil
        end

        # ~ courtesy

        def express & p
          if p.arity.zero?
            @y << @expression_agent.calculate( & p ) ; nil
          else
            @expression_agent.calculate @y, & p ; nil
          end
        end
      end
    end
  end
end
