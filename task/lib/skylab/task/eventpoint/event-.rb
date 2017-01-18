class Skylab::Task
  # ->
    class Eventpoint

      module Expressions___

        o = Here_::Expression_.method :new

        Agents = -> do
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
          }.freeze

          o[ -> inclusion_i, a do
            p = h.fetch inclusion_i
            n = a.length
            "#{ p[ n ] } active agent#{ 's' if 1 != n }"
          end ]
        end.call

        Ambiguity = o[ -> ep, pred_a do
          "express transitions of the same strength from #{
            }#{ The_state_[ ep ] }"
        end ]

        Bring = o[ -> ep, a, inclusion_i do
          excl = :exclusive == inclusion_i
          v = case a.length
              when 1 ; excl ? "does not bring" : "brings"
              else   ; "bring"
              end
          "#{ v } the system to #{ The_state_[ ep ] }"
        end ]

        Client__ = -> client_x do
          "#{ client_x.intern }"
        end

        Client = o[ Client__ ]

        Ep__ = -> ep do
          ep.node_symbol
        end

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

        The_state_ = -> ep do
          "the #{ Ep__[ ep ] } state"
        end

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
      end
    end
  # -
end
