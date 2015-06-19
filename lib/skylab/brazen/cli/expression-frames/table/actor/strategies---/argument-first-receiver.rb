module Skylab::Brazen

  class CLI::Expression_Frames::Table::Actor

    class Strategies___::Argument_First_Receiver < Simple_strategy_class_[]

      SUBSCRIPTIONS = [
        :receive_unclassified_argument_stream,
      ]

      def initialize_dup _

        # (clear all ivars across the dup boundary)

        super
      end

      def receive_unclassified_argument_stream up_st
        __process_unclassified_argument_stream up_st
      end

      def __process_unclassified_argument_stream up_st

        disp = @resources.dispatcher
        @_up_st = up_st

        kp = KEEP_PARSING_
        pu_a = []
        begin

          common_arity = nil
          kp = KEEP_PARSING_
          tok = up_st.current_token

          disp.accept :arity_for do | pu |

            arity = pu.arity_for tok
            if arity
              if common_arity
                if common_arity == arity
                  pu_a.push pu
                else
                  kp = UNABLE_
                  __when_no arity, pu, pu_a, common_arity
                end
              else
                common_arity = arity
                pu_a.clear.push pu
              end
            end
            kp
          end
          kp or break

          if common_arity
            kp = __process_single_term pu_a, common_arity  # might raise
            kp or break
          else
            raise ::ArgumentError, __say_no_strategy( tok )
          end

          if up_st.no_unparsed_exists
            break
          end
          redo
        end while nil
        kp
      end

      def __say_no_strategy tok
        "no strategy for handling argument '#{ tok }'"
      end

      def __when_no bad_arity, bad_pu, pu_a, common_arity
        self._COVER_AND_WRITE_ME_FUN_AND_EASY
      end

      def __process_single_term pu_a, common_arity

        kp = KEEP_PARSING_
        case common_arity

        when :one

          tok = @_up_st.gets_one
          m = :"receive__#{ tok }__argument"
          x = @_up_st.gets_one  # might raise

          pu_a.each do | pu |

            kp = pu.send m, x
            if ! kp  # fail hard for now, soft failure sucks here
              raise ::ArgumentError, __say_mono( kp, x, m, tok, pu )
            end
            # kp or break
          end

        when :custom

          if 1 == pu_a.length

            _tok = @_up_st.gets_one
            kp = pu_a.fetch( 0 ).send(
              :"receive_stream_after__#{ _tok }__", @_up_st )
          else
            raise ::ArgumentError, __say_cannot( pu_a )
          end
        else
          raise ::ArgumentError, "cover me? '#{ common_arity }'"
        end
        kp
      end

      def __say_cannot

        "#{ pu_a.length } plugins want to parse #{
          }'#{ @_up_st.current_token }' but only one can"
      end

      def __say_mono kp, x, m, tok, pu

        "failed to process `#{ tok }` - resulted in #{ kp.inspect }: #{
          }#{ pu.class }##{ m }( #{
           }#{ Brazen_.lib_.basic::String.via_mixed x } )"
      end

      Me_the_Strategy_ = self
    end
  end
end
