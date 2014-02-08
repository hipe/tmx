module Skylab::Basic

  module List::Aggregated::Articulation

    # [#it-002]

    def self.[] enum=nil, def_blk
     f = build_proc def_blk
     if enum
       f.call enum
     else
       f
     end
    end

    def self.build_proc def_blk
      o = St_.new
      Conduit_.new(
        -> str { o.template = str },
        -> ozi { o.on_zero_items = ozi },
        -> &agg { o.aggregate = agg },
        -> &ofm { o.on_first_mention = ofm },
        -> &osm { o.on_subsequent_mentions = osm }
      ).instance_exec( & def_blk )
      # o.on_subsequent_mentions ||= ( o.aggregate || o.on_first_mention )
      # o.on_first_mention ||= o.on_subsequent_mentions
      miss_a = nil
      Req_.each do |i|
        if ! o[ i ]
          ( miss_a ||= [] ) << i
        end
      end
      miss_a and raise ::ArgumentError, "missing required parameter(s) - #{
        } #{ miss_a * ', ' }"
      Flusher_.new( * o.to_a ).flush
    end

    A_ = %i| template on_zero_items aggregate on_first_mention
               on_subsequent_mentions |

    # Req_ = %i| aggregate on_first_mention on_subsequent_mentions |
    Req_ = [ ]

    St_ = ::Struct.new( * A_ )

    Conduit_ = Basic::Lib_::Enhance_Conduit[ A_ ]

    Flusher_ = Basic::Lib_::Functional_methods[ :flush ]
    class Flusher_

      def initialize template_str, on_zero_items_p, aggregate_p,
                         on_first_mention_p, on_subsequent_mentions_p
        tmpl = Basic::String::Template.from_string template_str
        whn = build_whens tmpl, aggregate_p, on_first_mention_p,
          on_subsequent_mentions_p

        @flush = -> do
          -> ea_x do
            scn = Basic::List::Scanner[ ea_x ]
            x = scn.gets
            if ! x
              on_zero_items_p.call if on_zero_items_p
            else
              sio = Basic::Lib_::String_IO[]
              yld = ::Enumerator::Yielder.new do |data|
                sio.write data
              end
              run yld, x, scn, tmpl, whn
              sio.rewind ; sio.read
            end
          end
        end
      end

      def build_whens tmpl, aggregate_p, on_first_mention_p,
          on_subsequent_mentions_p

        flusher = Mention_::Flusher_.new(
          nn_a = tmpl.get_formal_parameters.map( & :local_normal_name ) )
        whn = When_[ flusher.flush( on_first_mention_p ),
          flusher.flush( on_subsequent_mentions_p ),
          flusher.flush( aggregate_p ), nn_a ]
        normalize_aggregation whn
        whn
      end
      private :build_whens

      def normalize_aggregation whn
        if false
          a = trueish_members whn.aggregate
          case a.length
          when 0 ; fail "must aggregate on one channel"
          when 1 ;
          else   ; fail "for now we can't aggregate one more than one channel #{
            }(had: #{ a * ', ' })"
          end
          k = a.fetch( 0 )
          whn.aggregate = [ k, whn.aggregate[ k ] ]
        end
        nil
      end
      private :normalize_aggregation

      When_ = ::Struct.new :first, :subsequent, :aggregate, :names

      def trueish_members st
        st.to_h.reduce [] do |m, (k, v)|
          m << k if v
          m
        end
      end
      private :trueish_members

      def run yld, x, scn, tmpl, whn
        frame_a_a = ( trueish_members( whn.first ) |
          trueish_members( whn.subsequent ) ) & x.members
        frame_a_ = frame_a_a.map { |i| x[ i ] }
        frame_a__ = nil
        count = 0
        flush2 = nil
        aggo = Aggo_.new whn.aggregate
        aggo.add x
        flush = -> do
          count += 1
          h = whn.names.reduce( {} ) do |m, i|
            if (( idx = frame_a_a.index i ))
              x = frame_a_[ idx ]
              if ! frame_a__ || frame_a__[ idx ] != frame_a_[ idx ]
                m[ i ] = whn.first[ i ].call( x )
              else
                m[ i ] = whn.subsequent[ i ].call  # for now but etc..
              end
            elsif (( f = whn.aggregate[ i ] ))
              m[ i ] = f.call aggo.value.map( & i )
            else
              f_or_s = whn[ 1 == count ? :first : :subsequent ]
              m[ i ] = ( if (( x = f_or_s[ i ] ))
                x.call
              end )
            end
            m
          end
          frame_a__ = frame_a_
          flush2[ tmpl.call h ]
          nil
        end
        flush2 = -> str do
          yld << ( if 1 == count
            if whn.first._flush
              whn.first._flush.call str
            else
              str
            end
          else
            if whn.subsequent._flush
              whn.subsequent._flush.call str
            else
              str
            end
          end )
        end
        while (( xx = scn.gets ))
          frame_a = frame_a_a.map { |i| xx[ i ] }
          if frame_a == frame_a_
            aggo.add xx
          else
            flush[ ]
            frame_a_ = frame_a
            aggo.clear.add xx
          end
        end
        if aggo.nonempty?
          flush[ ]
        end
        nil
      end
      private :run
    end

    class Aggo_
      def initialize f
        a = [ ]
        @add = -> x do
          a << x
          nil
        end
        @nonempty = -> { a.length.nonzero? }
        @value = -> { a.dup }
        @clear = -> { a.clear ; self }
      end
      def add x ; @add[ x ] end
      def nonempty? ; @nonempty[ ] end
      def value ; @value[ ] end
      def clear ; @clear[] end
    end

    module Mention_

    end

    class Mention_::Flusher_

      def initialize nn_a
        nn_a << :_flush
        @conduit_class = Basic::Lib_::Enhance_Conduit[ nn_a ]
        @conduit_class.const_set :FUNC_STRUCT_,
          ::Struct.new( * @conduit_class::A_ )
      end

      def flush func
        fs = @conduit_class::FUNC_STRUCT_.new
        if func
          store = -> k, f do
            fs[ k ] and raise ::ArgumentError, "won't clobber existing #{ k }"
            fs[ k ] = f
            nil
          end
          kls = @conduit_class ; a = kls::A_
          kls.new( *
            a.length.times.map do |x|
              -> f do
                store[ a.fetch( x ), f ]
                f  # important - chaining
              end
            end
          ).instance_exec( & func )
        end
        fs
      end
    end
  end
end
