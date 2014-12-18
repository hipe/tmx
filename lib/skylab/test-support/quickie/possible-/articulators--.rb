module Skylab::TestSupport

  module Quickie

    self::Front__.class  # #open :+[#028]

    module Possible_

      module Articulators__

        o = Possible_::Articulator_.method :new

        Agents_ = -> do
          h = {
            inclusive: -> n do
              case n
              when 0 ; 'no'
              when 1 ; 'the only'
              when 2 ; 'both of the'
              else   ; "all #{ QuicLib_::EN_number[ n ] } of"
              end
            end,
            exclusive: -> n do
              case n
              when 0 ; 'no'
              when 1 ; 'the only'
              else   ; "none of the #{ QuicLib_::EN_number[ n ] }"
              end
            end
          }.freeze

          o[ -> inclusion_i, a do
            p = h.fetch inclusion_i
            n = a.length
            "#{ p[ n ] } active agent#{ 's' if 1 != n }"
          end ]
        end.call

        Ambiguity_ = o[ -> ep, pred_a do
          "express transitions of the same strength from #{
            }#{ The_state_[ ep ] }"
        end ]

        And_ = QuicLib_::Oxford_and

        Or_ = QuicLib_::Oxford_or

        Bring_ = o[ -> ep, a, inclusion_i do
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

        Client_ = o[ Client__ ]

        Ep_ = -> ep do
          ep.node_i
        end

        Exist_ = -> do
          h = {
            present: -> n { 1 == n ? 'is' : 'are' },
            past: -> n { 1 == n ? 'was' : 'were' }
          }.freeze
          o[ -> tense_i, a do
            "there #{ h.fetch( tense_i )[ a.length ] }"
          end ]
        end.call

        Got_passed_ = o[ -> ep, a do
          if 1 == a.length
            "failed to get passed #{ The_state_[ ep ] }"
          else
            "got passed #{ The_state_[ ep ] }"
          end
        end ]

        Had_no_effect_ = o[ -> ep_a do
          "will have no effect because the system does not reach #{
            Or_[ ep_a.map( & The_state_ ) ] }"
        end ]


        Reach_ = o[ -> ep do
          "cannot reach #{ The_state_[ ep ] }"
        end ]

        Signature_ = o[ -> sig do
          Client__[ sig.client ]
        end ]

        So_ = o[ -> { "so" } ]

        System_ = o[ -> { "the system" } ]

        The_state_ = -> ep do
          "the #{ Ep_[ ep ] } state"
        end

        Transition_ = o[ -> fep, tep do
          x = if (( a = fep.to_a ))
            " (#{ Ep_[ fep ] } goes to #{ And_[ a.map( & :node_i ) ] })"
              else
            " (#{ Ep_[ fep ] } does not transition to any other nodes)"
              end
          "expresses an invalid transition from #{ Ep_[ fep ] } to #{
            }#{ Ep_[ tep ] }#{ x }"
        end ]

        Unmet_Reliance_ = o[ -> ep do
          "cannot operate without reaching #{ The_state_[ ep ] }"
        end ]
      end
    end
  end
end
