class Skylab::Task

  module Eventpoint::Event_

    # #NOTE: these guys are ANCIENT and shoehorned into a newer paradigm.
    # they aren't getting a deeper refactor because emissions are an
    # auxiliary side to our central function

    # as they are the look to be like a dictionary (alphabetical, once)
    # of phrase-specific expression micro-agents

    o = Common_::Event::StructuredExpressive.method :new  # old way

    new = -> & p do  # new way
      o[ p ]
    end

    Pending_execution = -> do

          h = {
            inclusive: -> n do
              case n
              when 0 ; 'no'
              when 1 ; 'the only'
              when 2 ; 'both of the'
              else   ; "all #{ Home_.lib_.basic::Number::EN.number n } of"
              end
            end,
            exclusive: -> n do
              case n
              when 0 ; 'no'
              when 1 ; 'the only'
              else   ; "none of the #{ Home_.lib_.basic::Number::EN.number n }"
              end
            end
          }

      new.call do |inclusive_or_exclusive, pending_executions|
        _p = h.fetch inclusive_or_exclusive
        num = pending_executions.length
        "#{ _p[ num ] } pending execution#{ 's' if 1 != num }"
      end
    end.call

        Ambiguity = o[ -> ep, pred_a do
          "express transitions of the same strength from #{
            }#{ The_state_[ ep ] }"
        end ]

    Bring_the_system_to_a_finished_state = new.call do |
      current_state_symbol,
      inclusive_or_exclusive,
      pending_executions
    |

      excl = :exclusive == inclusive_or_exclusive
      _v = case pending_executions.length

              when 1 ; excl ? "does not bring" : "brings"
              else   ; "bring"
              end

      "#{ _v } the system from #{ The_state__[ current_state_symbol ] }#{
        } to a finished state"
    end

        Client__ = -> client_x do
          "#{ client_x.intern }"
        end

        Client = o[ Client__ ]

        Exist = -> do
          h = {
            present: -> n { 1 == n ? 'is' : 'are' },
            past: -> n { 1 == n ? 'was' : 'were' }
          }.freeze
          o[ -> tense_i, a do
            "there #{ h.fetch( tense_i )[ a.length ] }"
          end ]
        end.call

        Got_passed = o[ -> ep, a do
          if 1 == a.length
            "failed to get passed #{ The_state_[ ep ] }"
          else
            "got passed #{ The_state_[ ep ] }"
          end
        end ]

        Had_no_effect = o[ -> ep_a do

          _ = Common_::Oxford_or[ ep_a.map( & The_state_ ) ]

          "will have no effect because the system does not reach #{ _ }"
        end ]

        Reach = o[ -> ep do
          "cannot reach #{ The_state_[ ep ] }"
        end ]

        Signature = o[ -> sig do
          Client__[ sig.client ]
        end ]

        So = o[ -> { "so" } ]

        System = o[ -> { "the system" } ]

        Transition = o[ -> fep, tep do

          a = fep.to_a
          x = if a

            _ = Common_::Oxford_and[ a.map( & :node_symbol ) ]

            " (#{ Ep__[ fep ] } goes to #{ _ })"
              else
            " (#{ Ep__[ fep ] } does not transition to any other nodes)"
              end

          "expresses an invalid transition from #{ Ep__[ fep ] } to #{
            }#{ Ep__[ tep ] }#{ x }"
        end ]

        Unmet_Reliance = o[ -> ep do
          "cannot operate without reaching #{ The_state_[ ep ] }"
        end ]

    The_state__ = -> ep do
      "the #{ Ep__[ ep ] } state"
    end

    Ep__ = -> sym do

      s = sym.id2name
      if s.include? SPACE_
        %("#{ s }")
      else
        s
      end
    end

    # ==

    class ThisOneBuffer

      # xx
      # compare the much more complicated [#hu-046] "phrase assmebly"

      def initialize expag
        @_receive = :__receive_initially
        @_expag = expag
        @string = ""
      end

      def << phrase
        send @_receive, phrase
      end

      def __receive_initially ph
        _write_phrase ph
        @_receive = :__receive_normally ; nil
      end

      def __receive_normally ph
        @string << SPACE_
        _write_phrase ph
      end

      def _write_phrase ph
        ph.express_into_under @string, @_expag
        NIL
      end

      attr_reader :string
    end
    # ==
  end
end
# #history: begin massive rewrite (used to be "expressions")
