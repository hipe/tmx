module Skylab::SubTree

  module API

    module Home_::Models_::Files

      Magnetics_ = ::Module.new

      class Magnetics_::Find_via_Paths_and_Pattern

        Attributes_actor_.call( self,
          :paths,
          :pattern,
        )

        def initialize & p
          @listener = p
        end

        def execute
          _ok = __resolve_command
          _ok && __upstream_via_command
        end

        def __resolve_command

          if @pattern
            _pattern_part = [ :filename, @pattern ]
          end

          _ = Home_.lib_.system.find(
            :paths, @paths,
            * _pattern_part,
            :freeform_query_infix_words, %w'-type f',
            # (at #history-B.1, above wasn't portable as `-type file`)
            :when_command, IDENTITY_,
            & @listener )

          _store :@__command, _
        end

        def __upstream_via_command

          i, o, e, @thread = Home_::Library_::Open3.popen3( * @__command.args )
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

          @listener.call :error, :find_error do

            Common_::Event.inline_not_OK_with :find_error,

                :msg, s,
                :exitstatus, @thread.value.exitstatus do | y, o |

              y << "#{ o.msg } (exitstatus: #{ o.exitstatus })"
            end
          end

          UNABLE_
        end

        define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
      end

      # ==
      # ==
    end
  end
end
# #history-B.1: target Unbuntu not OS X
