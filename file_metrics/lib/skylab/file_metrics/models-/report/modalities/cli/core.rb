module Skylab::FileMetrics

  class Models_::Report

    Modalities = ::Module.new

    module Modalities::CLI  # (notes in [#005])

      Actions = ::Module.new

      # ~ the mutable front properties API frontier

      class Action_Adapter__ < Home_::CLI::Action_Adapter

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

            sess = Modz_CLI_::Sessions_::Property_Mutation_Session.new
            sess.extmod = EXTMOD__
            sess.mutable_front_props = mutable_front_properties
            sess.mutable_back_props = mutable_back_properties
            p[ sess ]
          end
          NIL_
        end
      end

      # ~ our common properties

      bz = Home_.lib_.brazen
      EXTMOD__ = bz::Model::Entity

      Common_properties__ = bz::Model.common_properties_class.new(
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

      # ~ misc support for our action adapters

      fmt = "%0.2f%%"
      Common_percent_formatting__ = -> f do
        fmt % ( f * 100 )
      end

      # ~ our default hook-in behavior for particular shared events

      class Action_Adapter__

        # ~ most of our events ore on the "data" channel but see #note-075

        def receive_conventional_emission i_a, & ev_p

          if :info == i_a.first
            send :"receive__#{ i_a.fetch 1 }__data", i_a, & ev_p
          else
            super
          end
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
            y.each do | s |
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
      end

      # ~ our universal customization to achieve final custom rendering

      class Action_Adapter__

        def bound_call_via_bound_call_from_back bc

          Callback_::Bound_Call.by do

            totes = bc.receiver.send bc.method_name, * bc.args
            if totes
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
      end

      # ~ our action adapters

      class Actions::Line_Count < Action_Adapter__

        _mutate_properties do | sess |
          sess.add_additional_properties(
            :property_object, Common_properties__.fetch( :verbose ),
          )
        end

        def _express_totals_when_nonzero_children totes

          totes.finish
          __express_totals_as_table @resources.sout, totes
        end

        def __express_totals_as_table out, totes

          percent = Common_percent_formatting__

          tbl = _begin_table

          tbl.edit_table(

            :field, :named, :slug,
              :label, 'File',
              :summary, -> totes_ do
                "Total: #{ totes_.children_count }"
              end,

            :field, :named, :count,
              :label, 'Lines',
              :summary, -> totes_ do
                "%d" % totes_.sum_of( :count )
              end,

            :field, :named, :total_share, :map, percent,

            :field, :named, :normal_share, :map, percent,

            :field, :named, :_lipstick_,
              :label, EMPTY_S_,
              :edit, Home_::CLI::Build_custom_lipstick_field )

          tbl.expression_width = _lookup_expression_width

          tbl.express_into_IO_data_tree out, totes

          NIL_  # important - don't result in the output context
        end
      end

      class Actions::Ext < Action_Adapter__

        _mutate_properties do | sess |
          sess.add_additional_properties(
            :property_object, Common_properties__.fetch( :verbose ),
          )
        end

        def _express_totals_when_nonzero_children totes

          # (no need to `finish` the node here, it is done by back)

          __express_totals_as_table @resources.sout, totes
        end

        def __express_totals_as_table out, totes

          percent = Common_percent_formatting__

          tbl = _begin_table

          tbl.edit_table(

            :field, :named, :slug,
              :label, 'Extension',
              :summary, -> totes_ do
                "Total: #{ totes_.children_count }"
              end,

            :field, :named, :count,
              :label, 'Num Files',
              :summary, -> totes_ do
                "%d" % totes_.sum_of( :count )
              end,

            :field, :named, :total_share,
              :map, percent,

            :field, :named, :normal_share,
              :map, percent,

            :field, :named, :_lipstick_,
              :label, EMPTY_S_,
              :edit, Home_::CLI::Build_custom_lipstick_field )

          tbl.expression_width = _lookup_expression_width

          y = tbl.express_into_IO_data_tree out, totes

          y && ACHIEVED_  # important - don't result in the output context
        end
      end

      class Actions::Dirs < Action_Adapter__

        _mutate_properties do | sess |
          sess.add_additional_properties(
            :property_object, Common_properties__.fetch( :verbose ),
          )
        end

        def _express_totals_when_nonzero_children totes

          # (no need to `finish` the node here, it is done by back)

          __express_totals_as_table @resources.sout, totes
        end

        def __express_totals_as_table out, totes

          integer_format = '%d'
          integer = -> x do
            integer_format % x
          end

          percent = Common_percent_formatting__

          tbl = _begin_table

          tbl.edit_table(

            :field, :named, :slug,
              :label, 'Directory',
              :summary, -> totes_ do
                'Total: '
              end,

            :field, :named, :num_files,
              :map, integer,
              :summary, -> totes_ do
                integer_format % totes_.sum_of( :num_files )
              end,

            :field, :named, :num_lines,
              :map, integer,
              :summary, -> totes_ do
                integer_format % totes_.sum_of( :num_lines )
              end,

            :field, :named, :total_share,
              :map, percent,

            :field, :named, :normal_share,
              :map, percent,

            :field, :named, :_lipstick_,
              :label, EMPTY_S_,
              :edit, Home_::CLI::Build_custom_lipstick_field
          )

          tbl.expression_width = _lookup_expression_width

          y = tbl.express_into_IO_data_tree out, totes

          y && ACHIEVED_  # important - don't result in the output context
        end
      end

      # ~ support for table rendering

      class Action_Adapter__

        def _begin_table
          Home_.lib_.brazen::CLI::Expression_Frames::Table::Structured.new
        end

        def _lookup_expression_width
          Home_::CLI::Lipsticker::EXPRESSION_WIDTH_PROC[]
        end
      end

      # ~ a model frontier for verbosities

      class Action_Adapter__

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

      Modz_CLI_ = self
    end
  end
end
