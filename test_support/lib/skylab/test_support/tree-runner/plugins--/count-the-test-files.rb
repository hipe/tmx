module Skylab::TestSupport

  class Tree_Runner

    class Plugins__::Count_The_Test_Files < Plugin_

      does :flush_the_test_files do | tr |

        tr.transition_is_effected_by do | o |

          o.on '--counts', 'show a report of the number of tests per subproduct'

        end

        tr.if_transition_is_effected do | o |

          o.on '-v', '--verbose', 'show max share meter (experimental)' do
            @verbosity_level += 1
          end

          o.on '-V', 'reduce verbosity level' do
            @verbosity_level -= 1
          end

          o.on '-z', '--zero', 'display the zero values' do
            @do_zero = true
          end
        end
      end

      def initialize( * )
        @verbosity_level = 1
        @do_zero = nil
        super
      end

      def do__flush_the_test_files__

        tall = Tallier____.new(
          @on_event_selectively.call( :for_plugin, :test_file_stream ),
          @on_event_selectively.call( :for_plugin, :sidesystem_box ),
          @do_zero )

        if 1 < @verbosity_level

          field_extra = __build_max_share_meter_args

          p = -> do
            rec = tall.gets_record
            if rec
              [ rec.moniker, rec.count, rec.count ]
            else
              p = EMPTY_P_
              [ '(total)', tall.upstream_item_count, nil ]
            end
          end

        else

          p = -> do
            rec = tall.gets_record
            if rec
              [ rec.moniker, rec.count ]
            else
              p = EMPTY_P_
              [ '(total)', tall.upstream_item_count ]
            end
          end
        end

        _st = Common_.stream do
          p[]
        end

        Home_.lib_.brazen::CLI_Support::Table::Actor.call(

          :field, 'subproduct',
          :field, 'num test files',
          * field_extra,
          :write_lines_to, @resources.sout,
          :read_rows_from, _st,
        )

        if 1 == @verbosity_level
          @resources.serr.puts '("-v" for visualization, "-V" hides this message)'
        end

        nil
      end

      def __build_max_share_meter_args

        _width = Home_.lib_.brazen::CLI.some_screen_width

        [ :target_width, _width, :field, :fill,
          :cel_renderer_builder, :max_share_meter ]
      end

      class Tallier____

        def initialize st, bx, do_zero

          box_d = 0

          path = nil
          p2 = nil
          p = -> do
            path = st.gets
            if path
              p = p2
              p2[]
            else
              p = EMPTY_P_
              nil
            end
          end

          p2 = -> do
            # makes at least two big assumptions

            count = nil
            begin
              ss = bx.at_position box_d
              box_d += 1
              s = "#{ ss.path_to_gem }#{ ::File::SEPARATOR }"
              len = s.length
              if s == path[ 0, len ]
                break
              elsif do_zero
                count = 0
                break
              else
                redo
              end
            end while nil

            if ! count
              count = 1
              begin
                path = st.gets
                if path
                  if s == path[ 0, len ]
                    count += 1
                    redo
                  else
                    break
                  end
                else
                  p = EMPTY_P_
                  break
                end
              end while nil
            end

            if count
              @upstream_item_count += count
              Record___.new( ss.stem, count )
            else
              p2[]  # recurse
            end
          end

          @upstream_item_count = 0

          @gets_record = -> { p[] }
        end

        attr_reader :upstream_item_count

        def gets_record
          @gets_record[]
        end

        Record___ = ::Struct.new :moniker, :count
      end
    end
  end
end
