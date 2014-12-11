module Skylab::Brazen

  class CLI

    class Action_Adapter_

      class Help_Renderer  # read [#004]

        def initialize op, kernel
          @arg_a = nil
          @action = kernel.action
          @action_adapter = kernel.action_adapter
          @expression_agent = kernel.expression_agent
          @invocation = kernel.invocation
          set_op op
          @section_a = []
          @section_separator_p = -> { @y << nil }
          @y = ::Enumerator::Yielder.new( & kernel.stderr.method( :puts ) )
          kernel.partitions.receive_help_renderer self
          screen_boundary
        end

        attr_reader :expression_agent, :op, :y
        attr_reader :invocation

        attr_writer :arg_a

        def set_op op
          @op = op
          op and use_formatting_of_option_parser op ; nil
        end

        def use_formatting_of_option_parser op
          @summary_indent = op.summary_indent
          @summary_width = op.summary_width ; nil
        end

        def output_help_screen
          output_usage
          @action.has_description and output_description
          @section_a.each( & method( :output_section ) )
          nil
        end

        # ~ usage lines

        def output_primary_usage_line
          subject.write_any_primary_syntax_string a=[]
          output_single_line_section 'usage', a[ 0 ]
          @action
        end

        def output_usage
          section_boundary
          a = get_full_syntax_strings
          output_usage_section_via_full_syntax_strings a
        end

        def output_usage_section_via_full_syntax_strings a
          output_multiline_section_tight 'usage', a ; nil
        end

        def get_full_syntax_strings
          subject.write_full_syntax_strings a=[]
          a
        end

        def produce_full_main_syntax_string
          y = [ subject_invocation_string ]
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

        def any_option_glyphs
          sw_s_a = []
          @op.top.list.each do |opt|
            sw = opt.short.first
            SHORT_HELP__ == sw and next
            sw_s_a.push "[#{ render_native_opt_switch_with_arg opt }]"
          end
          sw_s_a.length.nonzero? and sw_s_a
        end
        SHORT_HELP__ = '-h'.freeze

        def render_native_opt_switch_with_arg opt
          arity_i = argument_arity_from_native_optparse_switch opt
          if :zero != arity_i
            moniker = some_arg_moniker_for_switch opt
          end
          tail = render_argument_moniker_and_arity moniker, arity_i
          sw = shortest_moniker_for_opt opt
          "#{ sw }#{ tail }"
        end

        def as_opt_render_property prop
          look_for = "--#{ prop.name.as_slug }"
          found = @op.top.list.detect do |arg|
            look_for == arg.long.first
          end
          if found
            as_opt_render_property_when_found_opt prop, found
          end
        end

        def as_opt_render_property_when_found_opt prop, opt
          arity_i = argument_arity_from_native_optparse_switch opt
          head = shortest_moniker_for_opt opt
            ( opt.short ? opt.short : opt.long ).first
          if :zero != arity_i
            moniker = prop.argument_moniker
            moniker ||= some_arg_moniker_for_switch opt
          end
          tail = render_argument_moniker_and_arity moniker, arity_i
          "#{ head }#{ tail }"
        end

        def shortest_moniker_for_opt opt
          ( opt.short ? opt.short : opt.long ).first  # #todo
        end

        def render_argument_moniker_and_arity moniker, arity_i
          case arity_i
          when :one ; " #{ moniker }"
          when :zero
          when :zero_or_one_placed ; " [#{ moniker }]"
          when :zero_or_one_misplaced ; "[=#{ moniker }]"
          else raise say_bad_shape arity_i
          end
        end

        def say_bad_shape arity_i
          "unepxected shape: #{ arity_i }"
        end

        def some_arg_moniker_for_switch  sw
          'X'
        end

        def argument_arity_from_native_optparse_switch arg
          case arg
          when ::OptionParser::Switch::RequiredArgument ; :one
          when ::OptionParser::Switch::NoArgument ; :zero
          when ::OptionParser::Switch::PlacedArgument ; :zero_or_one_placed
          when ::OptionParser::Switch::OptionalArgument ; :zero_or_one_misplaced
          end
        end

        def any_argument_glyphs
          @arg_a and arg_glyphs
        end

        def arg_glyphs
          a = @arg_a.reduce [] do |m, prop|
            s = if prop.has_custom_moniker
              prop.custom_moniker
            else
              "<#{ prop.name.as_slug }>"
            end

            _is_effectively_optional = prop.has_default || ! prop.is_required

            if _is_effectively_optional  # near [#006]
              open = '[' ; close = ']'
            end

            if prop.takes_many_arguments
              addendum = " [#{ s } [..]]"
            end
            m << "#{ open }#{ s }#{ addendum }#{ close }"
          end
          a.length.nonzero? and a
        end

        # ~ section rendering (description, options, arguments, child actions)

        def output_description
          section_boundary
          output_multiline_section 'description', @action.
            under_expression_agent_get_N_desc_lines( @expression_agent ) ; nil
        end

        def output_option_parser_summary
          @op.summarize @y ; nil
        end

        def add_section rendering_method, * a, & p
          @section_a.push Section__.new( rendering_method, a, p ) ; nil
        end
        Section__ = ::Struct.new :rendering_method_i, :arguments, :p

        def output_section section
          send section.rendering_method_i, * section.arguments, & section.p
        end

        def ad_hoc_section label_s, & p
          section_boundary
          @y << @expression_agent.hdr( label_s )
          p[ self ] ; nil
        end

        def item_section label_s, item_a, & p
          section_boundary
          output_items_with_descriptions label_s, item_a, & p ; nil
        end

        # ~ "interjections"

        def output_invite_to_general_help
          s = subject_invocation_string
          express do
            "use #{ code "#{ s } -h" } for help"
          end
        end

        def output_invite_to_particular_action i_a
          o = @action_adapter.retrieve_bound_action_via_normalized_name i_a
          s = o.primary_syntax_string
          express do
            "use #{ code s }"
          end
        end

        def subject_invocation_string
          subject.invocation_string
        end

        def subject
          ( @action_adapter || @invocation )
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
