module Skylab::Cull

  class Models_::Survey

    class Models__::Report

      class Actors__::To_stream  # narrative in [#006]:#note-007

        Callback_::Actor.call self, :properties,

          :entity_stream, :call_a

        def execute
          if @call_a.length.zero?
            @entity_stream
          else
            normal
          end
        end

        def normal

          rfstream = Callback_::Polymorphic_Stream.via_array @call_a.reverse
          jogs = []

          begin

            func = rfstream.gets_one
            mapishes = nil

            if :aggregator == func.category_symbol

              while rfstream.unparsed_exists &&
                  :aggregator != rfstream.current_token.category_symbol
                mapishes ||= []
                mapishes.push rfstream.gets_one
              end

              if mapishes
                mapishes.reverse!
              end

              jogs.push Jog__.new( mapishes, func )

            else

              mapishes = [ func ]

              while rfstream.unparsed_exists &&
                  :aggregator != rfstream.current_token.category_symbol
                mapishes.push rfstream.gets_one
              end

              mapishes.reverse!

              jogs.push Jog__.new mapishes

            end
          end while rfstream.unparsed_exists

          if 1 < jogs.length
            estream_via_estream_and_multiple_jogs @entity_stream, jogs
          else
            estream_via_estream_and_jog @entity_stream, jogs.first
          end
        end

        Jog__ = ::Struct.new :mapishes, :agg

        def estream_via_estream_and_multiple_jogs estream, jogs

          jog = jogs.pop
          begin

            estream = estream_via_estream_and_jog estream, jog
            jog = jogs.pop

          end while jog
          estream
        end

        def estream_via_estream_and_jog estream, jog

          mapishes, agg = jog.to_a

          if agg
            if mapishes
              estream_via_agg_and_estream( agg,
                estream_via_estream_and_mapishes( estream, mapishes ) )
            else
              estream_via_agg_and_estream agg, estream
            end
          elsif mapishes
            estream_via_estream_and_mapishes estream, mapishes
          else
            estream
          end
        end

        def estream_via_estream_and_mapishes estream, mapishes
          case 1 <=> mapishes.length
          when  0
            func = mapishes.first
            if :mutator == func.category_symbol
              Callback_.stream do
                ent = estream.gets
                if ent
                  func[ ent, & @on_event_selectively ]
                end
                ent
              end
            else
              Callback_.stream do
                ent = estream.gets
                if ent
                  ent = func[ ent, & @on_event_selectively ]
                end
                ent
              end
            end
          when -1
            Callback_.stream do
              ent = estream.gets
              if ent
                mapishes.each do | func_ |
                  if :mutator == func_.category_symbol
                    func_[ ent, & @on_event_selectively ]
                  else
                    ent = func_[ ent, & @on_event_selectively ]
                    ent or break
                  end
                end
              end
              ent
            end
          when  1
            estream
          end
        end

        def estream_via_agg_and_estream agg, estream
          agg[ estream, & @on_event_selectively ]
        end
      end
    end
  end
end
