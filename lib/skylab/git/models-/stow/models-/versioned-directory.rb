module Skylab::Git

  class Models_::Stow

    class Models_::Versioned_Directory

      # model any one directory within a versioned project

      class << self
        alias_method :__new, :new
        private :new
      end

      def initialize dir, sc, k, & oes_p

        @directory = dir
        @_sc = sc
        @_k = k
        @on_event_selectively = oes_p
      end

      def to_entity_stream

        cmd = COMMAND___

        __maybe_say_command cmd

        _, o, e, w = @_sc.popen3( * cmd, chdir: @directory )

        p = -> do

          s = e.gets
          if s
            @on_event_selectively.call :error, :expression, :unexpected do | y |
              y << "unexpected errput: #{ s }"
            end
            p = EMPTY_P_
            UNABLE_
          else

            p = -> do
              s = o.gets
              if s
                s.strip!
                s  # ok for now, not to be entity ..
              else
                d = w.value.exitstatus
                if d.zero?
                  p = EMPTY_P_
                  NIL_
                else
                  self._COVER_ME
                end
              end
            end
            p[]
          end
        end

        Callback_.stream do
          p[]
        end
      end

      COMMAND___ = %w( git ls-files --others --exclude-standard ).freeze

      def __maybe_say_command cmd

        @on_event_selectively.call :info, :expression, :command do | y |

          p = Home_.lib_.shellwords.method :shellescape
          y << "command: #{ cmd.map( & p ).join( SPACE_ ) }"
        end
        NIL_
      end

    end
  end
end
