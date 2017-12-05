module Skylab::CodeMetrics

  # -- stowaway our custom action adapter shared base class notes in [#005]

    class CLI::Action_Adapter < CLI::Action_Adapter

        MUTATE_PRPS__ = nil

        class << self
          def _mutate_properties & p
            const_set :MUTATE_PRPS__, p
          end
        end  # >>

        def init_properties
          super
          p = self.class::MUTATE_PRPS__
          if p

            sess = CLI::Mutate_Front_and_Back_Properties___.new
            sess.extmod = EXTMOD__
            sess.mutable_front_props = mutable_front_properties
            sess.mutable_back_props = mutable_back_properties
            p[ sess ]
          end
          NIL_
        end

      # -- our common properties

      EXTMOD__ = Brazen_::Modelesque::Entity

      COMMON_PROPERTIES = Brazen_::CommonAssociations::LEGACY.new(
        EXTMOD__
      ) do | sess |

        sess.edit_common_properties_module(

          :description, -> y do

            y << "raise the verbosity level by one \"unit\""

          end,
          :argument_arity, :zero,
          :parameter_arity, :zero_or_more,
          :property, :verbose,
        )
      end

      # -- misc support for our action adapters

      PERCENT_FORMAT__ = "%6.2f%%"

        # -- our default hook-in behavior for particular shared events

        # ~ most of our events are on the "data" channel but see [#here.B]

        def receive_conventional_emission i_a, & ev_p

          if :info == i_a.first
            send :"receive__#{ i_a.fetch 1 }__data", i_a, & ev_p
          else
            super
          end
        end

        def receive__ping__data i_a, & ev_p

          _ev = ev_p[]

          receive_event_on_channel _ev, i_a

          NIL_
        end

        def receive__enoent__data i_a, & x_p

          _ev = x_p[]
          receive_event_on_channel _ev, i_a
          NIL_
        end

        def receive__file_list__data i_a, & x_p

          if _verbosity_is_at_level_for_lists

            _files = x_p.call
            io = @resources.serr

            _files.each do | file |

              io.puts file
            end
            NIL_
          end
        end

        def receive__find_dirs_command__data i_a, & x_p

          if _verbosity_is_at_level_for_commands

            receive_event_on_channel x_p[], i_a
          end
        end

        def receive__find_files_command__data i_a, & x_p

          if _verbosity_is_at_level_for_commands

            receive_event_on_channel x_p[], i_a
          end
        end

        def receive__line_count_command__data i_a, & ev_p

          if _verbosity_is_at_level_for_commands

            receive_event_on_channel ev_p[], i_a
          end
        end

        def receive__linecount_NLP_frame__data i_a, & x_p

          if _verbosity_is_at_entry_level

            _o = x_p[]
            y = _o.express_into_line_context []
            y.fetch( 0 )[ 0, 0 ] = '('
            y.fetch( -1 ).concat ')'
            y.each do |s|
              # (this context is the CLI action eew)
              @resources.serr.puts s
            end
            NIL_
          end
        end

        def receive__wc_command__data i_a, & x_p

          if _verbosity_is_at_level_for_commands

            cmd = x_p.call
            @resources.serr.puts cmd.to_string
            NIL_
          end
        end

        # -- our universal customization to achieve final custom rendering

        def bound_call_via_bound_call_from_back bc

          Common_::BoundCall.by do

            totes = bc.receiver.send bc.method_name, * bc.args

            if totes and totes.respond_to? :count
              _result_via_backstream_result totes
            else
              totes
            end
          end
        end

        def _result_via_backstream_result totes

          if totes.children_count.zero?
            __when_zero_children
          else
            _express_totals_when_nonzero_children totes
          end
        end

        def __when_zero_children
          @resources.serr.puts "(no files)"
          NIL_
        end
      # -
    end

  # -- end the stowed away custom action adapter shared base class

  class CLI
    # -
      # -- our action adapters

      Actions = ::Module.new  # everything's here

      class Actions::LineCount < Action_Adapter

        _mutate_properties do | sess |
          sess.add_additional_properties(
            :property_object, COMMON_PROPERTIES.fetch( :verbose ),
          )
        end

        def _express_totals_when_nonzero_children totes

          totes.finish
          __express_totals_as_table @resources.sout, totes
        end

        def __express_totals_as_table out, totes

          # TABLE 1

          # 1. declare these pseudo constants

          column_for_path = 0
          column_for_count = 1
          column_for_total_share = 2
          column_for_normal_share = 3
          number_of_columns = 4

          # 2. map each "totaller" object into a plain old array, lined up

          _mixed_tuple_stream = totes.to_value_stream.map_by do |subnode|
            a = ::Array.new number_of_columns
            a[ column_for_path ] = subnode.slug
            a[ column_for_count ] = subnode.count
            a[ column_for_total_share ] = subnode.total_share * 100  # e.g 0.25
            a[ column_for_normal_share ] = subnode.normal_share * 100  # e.g 0.5
            a
          end

          # 3. "design" the table (lining up the fields with above)

          _target_final_width = _lookup_expression_width

          _design = Zerk_lib_[]::CLI::Table::Design.define do |defn|

            defn.separator_glyphs '| ', ' | ', ' |'

            defn.add_field(  # `slug`, column 0
              :label, "File",
            )

            defn.add_field(  # `count`, column 1
              :label, "Lines",
            )

            defn.add_field(  # `total_share`, column 2
              :label, "Total share",
              :sprintf_format_string_for_nonzero_floats, PERCENT_FORMAT__,
            )

            defn.add_field(  # `normal_share`, column 3
              :label, "Normal share",
              :sprintf_format_string_for_nonzero_floats, PERCENT_FORMAT__,
            )

            Add_lipstick_field_[ defn, column_for_count ]

            defn.add_field_observer(
              :_observer_for_path_column_,
              :for_input_at_offset, column_for_path,
              :do_this, :CountTheNonEmptyStrings,
            )

            defn.add_field_observer(
              :_observer_for_count_column_,
              :for_input_at_offset, column_for_count,
              :do_this, :SumTheNumerics,
            )

            defn.add_summary_row do |o|

              _d = o.read_observer :_observer_for_path_column_
              o << "Total: #{ _d }"  # (hurts from lack of formatting)

              _d = o.read_observer :_observer_for_count_column_
              o << _d  # ok as integer
            end

            defn.target_final_width _target_final_width
          end

          _out_st = _design.line_stream_via_mixed_tuple_stream(
            _mixed_tuple_stream )

          Flush_stream_into_[ out, _out_st ]

          ACHIEVED_
        end
      end

      class Actions::Ext < Action_Adapter

        _mutate_properties do | sess |
          sess.add_additional_properties(
            :property_object, COMMON_PROPERTIES.fetch( :verbose ),
          )
        end

        def _express_totals_when_nonzero_children totes

          # (no need to `finish` the node here, it is done by back)

          __express_totals_as_table @resources.sout, totes
        end

        def __express_totals_as_table out, totes

          # TABLE 2

          # 1. declare these pseudo constants

          column_for_extension = 0
          column_for_count = 1
          column_for_total_share = 2
          column_for_normal_share = 3
          number_of_columns = 4

          # 2. map each "totaller" object into a plain old array, lined up

          _mixed_tuple_stream = totes.to_value_stream.map_by do |subnode|
            a = ::Array.new number_of_columns
            a[ column_for_extension ] = subnode.slug
            a[ column_for_count ] = subnode.count
            a[ column_for_total_share ] = subnode.total_share * 100  # e.g 0.25
            a[ column_for_normal_share ] = subnode.normal_share * 100  # e.g 0.5
            a
          end

          # 3. "design" the table (lining up the fields with above)

          _target_final_width = _lookup_expression_width

          _design = Zerk_lib_[]::CLI::Table::Design.define do |defn|

            defn.separator_glyphs '| ', ' | ', ' |'

            defn.add_field(  # `slug`, column 0
              :label, "Extension",
            )

            defn.add_field(  # `count`, column 1
              :label, "Num Files",
            )

            defn.add_field(  # `total_share`, column 2
              :label, "Total share",
              :sprintf_format_string_for_nonzero_floats, PERCENT_FORMAT__,
            )

            defn.add_field(  # `normal_share`, column 3
              :label, "Normal share",
              :sprintf_format_string_for_nonzero_floats, PERCENT_FORMAT__,
            )

            Add_lipstick_field_[ defn, column_for_count ]

            defn.add_field_observer(
              :_observer_for_extension_column_,
              :for_input_at_offset, column_for_extension,
              :do_this, :CountTheNonEmptyStrings,
            )

            defn.add_field_observer(
              :_observer_for_count_column_,
              :for_input_at_offset, column_for_count,
              :do_this, :SumTheNumerics,
            )

            defn.add_summary_row do |o|

              _d = o.read_observer :_observer_for_extension_column_
              o << "Total: #{ _d }"  # (hurts from lack of formatting)

              _d = o.read_observer :_observer_for_count_column_
              o << _d  # ok as integer
            end

            defn.target_final_width _target_final_width
          end

          _out_st = _design.line_stream_via_mixed_tuple_stream(
            _mixed_tuple_stream )

          Flush_stream_into_[ out, _out_st ]

          ACHIEVED_  # important - don't result in the output context
        end
      end

      class Actions::Dirs < Action_Adapter

        _mutate_properties do | sess |
          sess.add_additional_properties(
            :property_object, COMMON_PROPERTIES.fetch( :verbose ),
          )
        end

        def _express_totals_when_nonzero_children totes

          # (no need to `finish` the node here, it is done by back)

          __express_totals_as_table @resources.sout, totes
        end

        def __express_totals_as_table out, totes

          # TABLE 3

          # 1. declare these pseudo constants

          column_for_directory = 0
          column_for_num_files = 1
          column_for_num_lines = 2
          column_for_total_share = 3
          column_for_normal_share = 4
          number_of_columns = 5

          # 2. map each "totaller" object into a plain old array, lined up

          _mixed_tuple_stream = totes.to_value_stream.map_by do |subnode|
            a = ::Array.new number_of_columns
            a[ column_for_directory ] = subnode.slug
            a[ column_for_num_files ] = subnode.num_files
            a[ column_for_num_lines ] = subnode.num_lines
            a[ column_for_total_share ] = subnode.total_share * 100  # e.g 0.25
            a[ column_for_normal_share ] = subnode.normal_share * 100  # e.g 0.5
            a
          end

          # 3. "design" the table (lining up the fields with above)

          _target_final_width = _lookup_expression_width

          _design = Zerk_lib_[]::CLI::Table::Design.define do |defn|

            defn.separator_glyphs '| ', ' | ', ' |'

            defn.add_field(  # `slug`, column 0
              :label, "Directory",
            )

            defn.add_field(  # `num_files`, column 1
              :label, "Num Files",
            )

            defn.add_field(  # `num_lines`, column 2
              :label, "Num Lines",
            )

            defn.add_field(  # `total_share`, column 3
              :label, "Total share",
              :sprintf_format_string_for_nonzero_floats, PERCENT_FORMAT__,
            )

            defn.add_field(  # `normal_share`, column 4
              :label, "Normal share",
              :sprintf_format_string_for_nonzero_floats, PERCENT_FORMAT__,
            )

            Add_lipstick_field_[ defn, column_for_num_files ]

            defn.add_field_observer(
              :_observer_for_dir_column_,
              :for_input_at_offset, column_for_directory,
              :do_this, :CountTheNonEmptyStrings,
            )

            defn.add_field_observer(
              :_observer_for_num_files_column_,
              :for_input_at_offset, column_for_num_files,
              :do_this, :SumTheNumerics,
            )

            defn.add_field_observer(
              :_observer_for_num_lines_column_,
              :for_input_at_offset, column_for_num_lines,
              :do_this, :SumTheNumerics,
            )

            defn.add_summary_row do |o|

              _d = o.read_observer :_observer_for_dir_column_
              o << "Total: #{ _d }"  # (hurts from lack of formatting)

              _d = o.read_observer :_observer_for_num_files_column_
              o << _d  # ok as integer

              _d = o.read_observer :_observer_for_num_lines_column_
              o << _d  # ok as integer
            end

            defn.target_final_width _target_final_width
          end

          _out_st = _design.line_stream_via_mixed_tuple_stream(
            _mixed_tuple_stream )

          Flush_stream_into_[ out, _out_st ]

          ACHIEVED_  # important - don't result in the output context
        end
      end

      class Action_Adapter  # re-open shared base class

        # -- support for table rendering

        def _lookup_expression_width
          Home_::CLI::HARD_CODED_WIDTH_
        end

        # -- a model frontier for verbosities

        # the canonical levels: ( fatal error warning notice info trace )

        def _verbosity_is_at_least_NOTICE

          0 < _the_number_of_Vs
        end

        alias_method :_verbosity_is_at_entry_level,
          :_verbosity_is_at_least_NOTICE

        def _verbosity_is_at_least_INFO

          1 < _the_number_of_Vs
        end

        alias_method :_verbosity_is_at_level_for_commands,
          :_verbosity_is_at_least_INFO

        def _verbosity_is_at_least_TRACE

          2 < _the_number_of_Vs
        end

        alias_method :_verbosity_is_at_level_for_lists,
          :_verbosity_is_at_least_TRACE

        def _the_number_of_Vs
          seen = @seen[ :verbose ]
          if seen
            d = seen.seen_count
            if 3 < d
              @__did_warn_about_too_many_Vs ||= __warn_about_too_many_Vs( d, 3 )
            end
            d
          else
            0
          end
        end

        def __warn_about_too_many_Vs d, d_

          lib = Home_.lib_.basic::Number::EN

          @resources.serr.puts "(verbosity level #{ lib.number d_ } #{
            }is highest (had #{ lib.number d }).)"  # meh

          ACHIEVED_
        end
      end
    # -
  end
end
