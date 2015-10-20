module Skylab::SubTree

  module API

    module Home_::Models_::Files

      class Extensions_::Line_Count

        def initialize qualified_knownness, & oes_p
          @on_event_selectively = oes_p
          @qualified_knownness = qualified_knownness
        end

        def is_collection_operation
          true  # see [#006]:#collection-operations. execute this extension
          # post-pass, processing all the items at once which a) lets us take
          # only one trip to the system instead of N and b) may allow us to
          # line up our results nicely into columns for some modalities.
        end

        def local_normal_name
          @qualified_knownness.name_symbol
        end

        def receive_collection_of_mutable_items row_a

          _ok = __resolve_command_string_array row_a
          _ok && __execute_command
        end

        def __resolve_command_string_array row_a

          @leaf_a = row_a.reduce [] do | m, row |
            lf = row.any_leaf
            lf or next m
            lf.input_line or next  # safeguard
            m.push lf
            m
          end

          if @leaf_a.length.zero?
            __TODO_when_no_leafs
          else

            cmd_s_a = [ 'wc', '-l', * ( @leaf_a.map do | lf |
              lf.input_line  # you must not shellescape: no shell used
            end ) ]

            @on_event_selectively.call :info, :wordcount_command do
              __build_wordcount_command_event cmd_s_a
            end

            @cmd_s_a = cmd_s_a
            ACHIEVED_
          end
        end

        def __build_wordcount_command_event s_a

          Callback_::Event.inline_neutral_with :wordcount_command,

              :s_a, s_a do | y, o |

            _s_a = o.s_a.map( &
              Home_::Library_::Shellwords.method( :shellescape ) )

            y << "wordcount command: #{ _s_a * SPACE_ }"
          end
        end

        def __execute_command

          _, o, e, t = Home_::Library_::Open3.popen3( * @cmd_s_a )

          s = e.read
          if s && s.length.nonzero?
            __when_command_in_system_error s, o, e, t
          else
            __mutate_leaves_with_find_results o, t
          end
        end

        def __when_command_in_system_error s, o, e, t

          o.read  # toss
          d = t.value.exitstatus

          @on_event_selectively.call :error, :expression, :find do | y |
            y << "(find (exitstatus #{ d }) wrote to errstream - #{ s })"
          end
          UNABLE_
        end

      private

        def __mutate_leaves_with_find_results  o, t

          h = __build_find_results o, t

          @leaf_a.each do | lf |

            d = h.fetch lf.input_line

            lf.add_attribute :line_count, d

            lf.add_subcel "#{ d } line#{ 's' if 1 != d }"  # etc
          end

          ACHIEVED_
        end

        def __build_find_results o, t

          h = {}
          prev_line = o.gets  # edge cases: there might be
            # a file caled `total`, there might be only one file

          begin

            line = o.gets
            if ! line
              h.length.zero? or break
              stop = true
            end

            md = RX___.match prev_line

            h[ md[ :file ] ] = md[ :num_lines ].to_i

            stop and break
            prev_line = line
            redo
          end while nil

          d = t.value.exitstatus
          if d.zero?

            @on_event_selectively.call :info, :expression, :find_exitstatus do | y |
              y << "(find exitstatus #{ d })"
            end
          else
            @on_event_selectively.call :error, :expression, :find_exitstatus do | y |
              y << "(find exitstatus #{ d })"
            end
          end

          h
        end

        RX___ = /\A[ ]*(?<num_lines>\d+)[ ]+(?<file>[^ \n].*[^\n])\n?\z/

      end
    end
  end
end
