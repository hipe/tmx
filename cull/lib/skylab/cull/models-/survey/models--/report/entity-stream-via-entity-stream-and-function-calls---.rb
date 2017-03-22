module Skylab::Cull

  class Models_::Survey

    class Models__::Report

      class Actors__::To_stream < Common_::Dyadic

        # narrative in [#006]:#note-007

        def initialize es, a, & p
          @call_a = a
          @entity_stream = es
          @_emit = p
        end

        def execute
          if @call_a.length.zero?
            @entity_stream
          else
            normal
          end
        end

        def normal

          rfstream = Common_::Scanner.via_array @call_a.reverse
          jogs = []

          begin

            func = rfstream.gets_one
            mapishes = nil

            if :aggregator == func.category_symbol

              while rfstream.unparsed_exists &&
                  :aggregator != rfstream.head_as_is.category_symbol
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
                  :aggregator != rfstream.head_as_is.category_symbol
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
              Common_.stream do
                ent = estream.gets
                if ent
                  func[ ent, & @_emit ]
                end
                ent
              end
            else
              Common_.stream do
                ent = estream.gets
                if ent
                  ent = func[ ent, & @_emit ]
                end
                ent
              end
            end
          when -1
            Common_.stream do
              ent = estream.gets
              if ent
                mapishes.each do | func_ |
                  if :mutator == func_.category_symbol
                    func_[ ent, & @_emit ]
                  else
                    ent = func_[ ent, & @_emit ]
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
          agg[ estream, & @_emit ]
        end
      end
    end
  end
end
