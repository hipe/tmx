module Skylab::Brazen

  class Property::Stack

    Actors_ = ::Module.new

    # ->

      class Actors_::Define_process_method  # rewrite of [#mh-060]

        Callback_::Actor.methodic self, :properties, :sess

        class << self
          def [] * a, & x_p
            call_via_arglist a, & x_p
          end
        end  # >>

        def initialize & edit_p

          @_is_complete = false
          @_is_globbing = false
          instance_exec( & edit_p )
        end

        def execute

          kp = process_polymorphic_stream_passively @sess.upstream

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
          @_method_name = gets_one_polymorphic_value
          STOP_PARSING_
        end

        def __via_parse_context_flush

          ent_class = @sess.client

          do_glob = @_is_globbing
          m = @_method_name

          ent_class.class_exec do

            if do_glob

              define_method m do | * x_a |

                _kp = process_polymorphic_stream_fully(
                  Callback_::Polymorphic_Stream.via_array x_a )

                _kp && normalize
              end

            else

              define_method m do | x_a |

                _kp = process_polymorphic_stream_fully(
                  Callback_::Polymorphic_Stream.via_array x_a )

                _kp && normalize
              end
            end
          end
          ACHIEVED_
        end
      end
      # <-
  end
end
