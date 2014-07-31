module Skylab::Brazen

  module CLI

    class Action_Adapter_

      class Help_Renderer

        def initialize action, op, arg_a, client
          @action = action ; @arg_a = arg_a ; @client = client ; @op = op
          @expression_agent = client.expression_agent
          @section_separator_p = -> { @y << nil }
          @summary_indent = op.summary_indent
          @summary_width = op.summary_width
          @y = ::Enumerator::Yielder.new( & client.stderr.method( :puts ) )
        end

        attr_reader :y

        def output_help_screen
          screen_boundary
          output_usage
          @action.has_description and output_description
          output_options
          @arg_a and output_arguments
          nil
        end

        # ~ usage lines

        def output_usage
          section_boundary
          output_multiline_section_tight 'usage', get_syntax_strings ; nil
        end

        def get_syntax_strings
          a = []
          s = produce_main_syntax_string and a.push s
          s = produce_auxiliary_syntax_string and a.push s
          a
        end

        def produce_main_syntax_string
          y = [ action_invocation_string ]
          a = any_option_glyphs and y.concat a
          a = any_argument_glyphs and y.concat a
          y * SPACE_
        end

        def action_invocation_string
          "#{ @client.invocation_string } #{ @action.name.as_slug }"
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
          a = @arg_a.map do |prop|
            if prop.has_default
              "[<#{ prop.name.as_slug }>]"
            else
              "<#{ prop.name.as_slug }>"
            end
          end
          a.length.nonzero? and a
        end

        def produce_auxiliary_syntax_string
          "#{ action_invocation_string } -h"
        end

        # ~ description, options, arguments & "interjections"

        def output_description
          section_boundary
          output_multiline_section 'description',
            @action.get_description_lines( @expression_agent ) ; nil
        end

        def output_options
          section_boundary
          @y << @expression_agent.hdr( 'options' )
          @op.summarize @y ; nil
        end

        def output_arguments
          section_boundary
          output_items_with_descriptions 'argument', @arg_a ; nil
        end

        def invite_to_general_help_line
          s = action_invocation_string
          @expression_agent.calculate do
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

        def output_items_with_descriptions hdr_s, x_a
          output_header "#{ hdr_s }#{ 's' if 1 != x_a.length }"
          prepare_output_items_with_descriptions
          x_a.each do |x|
            if x.has_description
              output_item_with_description x
            else
              @y << "#{ @summary_indent }#{ x.name.as_slug }"
            end
          end ; nil
        end

        def prepare_output_items_with_descriptions
          d = @summary_width
          @first_line_item_format = "#{ @summary_indent }%-#{ d }s %s"
          d_ = d + @summary_indent.length + 1  # " " is 1 char wide
          @subsequent_line_item_format = "#{ SPACE_ * d_ }%s" ; nil
        end

        def output_item_with_description x
          a = x.get_description_lines @expression_agent
          @y << @first_line_item_format % [ x.name.as_slug, a.fetch( 0 ) ]
          1.upto( a.length - 1 ) do |d|
            @y << @subsequent_line_item_format % a.fetch( d )
          end ; nil
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
      end
    end
  end
end
