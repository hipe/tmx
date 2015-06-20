module Skylab::Plugin

  Sessions = ::Module.new

  class Sessions::Shared_Parse

    # for each "head token" ([#pa-001]), determine the N number and
    # constituency of dependencies that can parse this token. if 0,
    # this is an argument error. if more than one, make sure that all
    # such agents agree on the argument arity; if not, this too is an
    # argument error. consume each head token in this manner until
    # none is left.

    # note - this is currently a rough abstraction from one application.
    # the behavior for handling the different argument error cases can
    # be exposed by the API as needed, in which case the below behaviors
    # should be made defauls.

    attr_writer(
      :be_passive,  # when a head token is encountered for which no strategy
                    # is found, parsing ends without failure

      :dispatcher,
      :upstream,
    )

    def initialize
      @be_passive = false
    end

    def execute

      disp = @dispatcher
      up_st = @upstream

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
          kp = __when_no_strategy
          break
        end

        if up_st.no_unparsed_exists
          break
        end
        redo
      end while nil
      kp
    end

    def __when_no_strategy

      if @be_passive
        KEEP_PARSING_
      else
        raise ::ArgumentError, __say_no_strategy( @upstream.current_token )
      end
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

        tok = @upstream.gets_one
        m = :"receive__#{ tok }__argument"
        x = @upstream.gets_one  # might raise

        pu_a.each do | pu |

          kp = pu.send m, x
          if ! kp  # fail hard for now, soft failure sucks here
            raise ::ArgumentError, __say_mono( kp, x, m, tok, pu )
          end
        end

      when :zero

        tok = @upstream.gets_one
        m = :"receive__#{ tok }__"

        pu_a.each do | pu |
          kp = pu.send m
          if ! kp
            raise ::ArgumentError, __say_niladic( kp, m, tok, pu )
          end
        end

      when :custom

        if 1 == pu_a.length

          _tok = @upstream.gets_one
          kp = pu_a.fetch( 0 ).send(
            :"receive_stream_after__#{ _tok }__", @upstream )
        else
          raise ::ArgumentError, __say_multiple( pu_a )
        end
      else
        raise ::ArgumentError, __say_arity( common_arity )
      end
      kp
    end

    def __say_multiple

      "#{ pu_a.length } plugins want to parse #{
        }'#{ @upstream.current_token }' but only one can"
    end

    def __say_arity x

      "no implementation (yet?) for argument arity '#{ x }'"
    end

    def __say_mono kp, x, m, tok, pu

      "#{ __say_niladic kp, m, tok, pu }#{
        }( #{ Brazen_.lib_.basic::String.via_mixed x } )"
    end

    def __say_niladic kp, m, tok, pu

      "failed to process `#{ tok }` - resulted in #{ kp.inspect }: #{
        }#{ pu.class }##{ m }"
    end
  end
end
