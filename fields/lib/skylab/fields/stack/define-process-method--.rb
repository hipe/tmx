module Skylab::Fields

  class Stack

    class Define_process_method__   # near (marked for removal) [#008]..
      # -
        Attributes::Actor.call( self,
          globbing: :custom_interpreter_method,
          # processor: :custom_interpreter_method, for now, can't because stop parsing
          sess: nil,
        )

        class << self

          def _call sess, & x_p
            via :sess, sess, & x_p
          end

          alias_method :[], :_call

          private :new
        end  # >>

        def initialize
          @_is_complete = false
          @_is_globbing = false
        end

        def execute

          kp = process_argument_scanner_passively @sess.upstream

          if @_is_complete

            __via_parse_context_flush

          elsif kp

            self._DESIGN_ME__when_incomplete

          else
            kp
          end
        end

      private

        def globbing=

          @_is_globbing = true
          KEEP_PARSING_
        end

        def processor=

          @_is_complete = true
          @_method_name = gets_one
          STOP_PARSING_
        end

        def __via_parse_context_flush

          ent_class = @sess.client

          do_glob = @_is_globbing
          m = @_method_name

          ent_class.class_exec do

            if do_glob

              define_method m do | * x_a |

                _kp = process_argument_scanner_fully(
                  Common_::Scanner.via_array x_a )

                _kp && normalize
              end

            else

              define_method m do | x_a |

                _kp = process_argument_scanner_fully(
                  Common_::Scanner.via_array x_a )

                _kp && normalize
              end
            end
          end
          ACHIEVED_
        end
      # -
    end
  end
end
