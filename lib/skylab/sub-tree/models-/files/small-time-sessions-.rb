module Skylab::SubTree

  module API

    module SubTree_::Models_::Files

      Small_Time_Sessions_ = ::Module.new

      class Small_Time_Sessions_::Perform_aggregate_find

        Callback_::Actor.call self, :properties,
          :paths, :pattern

        class << self
          def new_with * x_a, & oes_p  # :+[#ca-063]
            new do
              @on_event_selectively = oes_p
              process_iambic_fully x_a
            end
          end
        end  # >>

        def produce_upstream
          _ok = __resolve_command
          _ok && __via_command_produce_upstream
        end

        def __resolve_command

          if @pattern
            _pattern_part = [ :filename, @pattern ]
          end

          @cmd_o = SubTree_.lib_.system.filesystem.find(
            :paths, @paths,
            * _pattern_part,
            :freeform_query_infix_words, %w'-type file',
            :as_normal_value, IDENTITY_, & @on_event_selectively )

          @cmd_o && ACHIEVED_
        end

        def __via_command_produce_upstream

          i, o, e, @thread = SubTree_::Library_::Open3.popen3( * @cmd_o.args )
          i.close
          s = e.read
          if s && s.length.nonzero?
            o.close
            __when_errput s
          else
            e.close
            o
          end
        end

        attr_reader :thread

        def __when_errput s

          s.chomp!

          @on_event_selectively.call :error, :find_error do

            Callback_::Event.inline_not_OK_with :find_error,

                :msg, s,
                :exitstatus, @thread.value.exitstatus do | y, o |

              y << "#{ o.msg } (exitstatus: #{ o.exitstatus })"
            end
          end

          UNABLE_
        end
      end
    end
  end
end