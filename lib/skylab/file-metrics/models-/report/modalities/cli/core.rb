module Skylab::FileMetrics

  class Models_::Report

    Modalities = ::Module.new

    module Modalities::CLI

      if false  # (tmp)

      Actions = ::Module.new

      Action_Adapter__ = ::Class.new FM_::CLI::Action_Adapter

      Common_percent_formatting__ = -> f do
        if d
          "%0.2f%%" % ( d * 100 )
        end
      end

        # e.g - fatal error warning notice info debug trace

        ( volume_a = [ :info_volume, :debug_volume, :trace_volume ].freeze ).

          each { |k| req[k] = nil }  # so we can fetch them

        op.on('-v', '--verbose',
          'e.g. show the generated {find|wc} commands we (would) use, etc',
          '(try using multiple -v for more detail)') do
          not_yet_set = volume_a.detect { |k| ! req[ k ] }
          if not_yet_set then req[ not_yet_set ] = true else
            @did_emit_verbose_max_volume_notice ||= begin

              _s = FM_.lib_.human::NLP::EN::Number.number volume_a.length

              @err.puts "(#{ _s } is the max number of -v.)"
              true
            end
          end
        end
      end

      if false  # (tmp)

      class Actions::Line_Count < Action_Adapter__

        self._EG(

          :description, -> y do
            y << 'list the resulting files that match the query (before running reports)'
          end,
          :default, false,
          :flag,
          :property, :show_file_list,
        )

        def _WHAT

          if c.zero_children?  # (linecount)
            @ui.err.puts "(no files)"
          else
            c.mutate_by_common_sort
            render_table c, @ui.err
          end
        end

        define_method :render_table, -> do

          percent = Common_percent_formatting__

          -> count, out do

            rndr_tbl out, count, -> do

              fields [
                [ :label,               header: 'File' ],
                [ :count,               header: 'Lines' ],
                [ :rest,                :rest ],  # if we forgot any fields, glob them here
                [ :total_share,         prerender: percent ],
                [ :normal_share,        prerender: percent ],
                [ :lipstick_float,      :noop ],
                [ :lipstick,            FM_::CLI::Build_custom_lipstick_field[] ]
              ]

              field[:label].summary -> do
                  "Total: #{ count.child_count }"
                end, -> do
                  fail "helf"
                end
              field[:count].summary -> do
                  "%d" % count.sum_of( :count )
                end
              field[:lipstick].summary nil
            end
          end
        end.call
      end

      class Actions::Dirs < Action_Adapter__

        define_method :render_table, -> do

          percent = Common_percent_formatting__

          -> count, out do

            rndr_tbl out, count, -> do
              fields [
                [ :label,               header: 'Directory' ],
                [ :count,               :noop ],
                [ :num_files,           prerender: -> x { x.to_s } ],
                [ :num_lines,           prerender: -> x { x.to_s } ],
                [ :rest,                :rest ],  # any fields not stated here, glob them
                [ :total_share,         prerender: percent ],
                [ :normal_share,        prerender: percent ],
                [ :lipstick_float,      :noop ],
                [ :lipstick,            FM_::CLI::Build_custom_lipstick_field[] ]
              ]
              field[:label].summary -> do
                'Total: '
              end, -> do
                fail 'me'
              end
              field[:num_files].summary -> do
                "%d" % count.sum_of( :num_files )
              end
              field[:num_lines].summary -> do
                "%d" % count.sum_of( :num_lines )
              end
              field[:lipstick].summary nil
            end
          end
        end.call
      end

      class Actions::Ext < Action_Adapter__

        define_method :render_table, -> do

          percent = Common_percent_formatting__

          define_method :render_table do | count, out |
            rndr_tbl out, count, -> do
              fields [
                [ :label,               header: 'Extension' ],
                [ :count,               header: 'Num Files' ],
                [ :rest,                :rest ],  # if we forgot any fields, glob them here
                [ :total_share,         prerender: percent ],
                [ :normal_share,        prerender: percent ],
                [ :lipstick_float,      :noop ],
                [ :lipstick,            FM_::CLI::Build_custom_lipstick_field[] ]
              ]
            end
          end

        end.call
      end

      class Action_Adapter__

        def rndr_tbl out, count, design

          if count.zero_children?
            out.puts "(table has no rows)"  # last ditch fallback.
            false
          else

            FM_::Whatever::Table::Render[ out, count.each_child, [ design,
              -> d do  # grease wheels
                d.the_rest count.first_child.class.members  # did we forget any?
                d.hdr do |sym|  # hack a header from the field id as a default
                  sym.to_s.split( '_' ).map(& :capitalize ) * ' '
                end
              end
            ] ]
          end
        end
      end
      end  # (tmp)
    end
  end
end
