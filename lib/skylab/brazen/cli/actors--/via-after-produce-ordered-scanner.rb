module Skylab::Brazen

  class CLI

    class Actors__::Via_after_produce_ordered_scanner

      Actor_[ self, :properties, :scan ]

      def execute

        after_h = ::Hash.new { |h, k| h[k] = [] }
        seen_h = {} ; queue = nil

        see = nil
        p = -> do
          while true
            x = @scan.gets
            x or break
            after_i = x.action.class.after_i
            after_i or break
            seen_h[ after_i ] and break
            after_h[ after_i ].push x
          end
          x and see[ x ]
          x
        end

        build_flushing_p = nil
        see = -> x do
          i = x.name.as_lowercase_with_underscores_symbol
          seen_h[ i ] = true
          if after_h.key? i
            a = after_h.delete i
            ( queue ||= [] ).push p
            p = build_flushing_p[ a ]
          end ; nil
        end

        pop = nil
        build_flushing_p = -> a do
          d = 0 ; last = a.length - 1
          -> do
            x = a.fetch d
            if last == d
              pop[]
            end
            x and see[ x ]
            x
          end
        end

        pop = -> do
          if queue && queue.length.nonzero?
            p = queue.shift
          else
            p = EMPTY_P_
          end ; nil
        end

        @scan.class.new do
          p[]
        end
      end
    end
  end
end
