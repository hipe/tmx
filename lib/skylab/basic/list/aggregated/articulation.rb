module Skylab::Basic

  module List::Aggregated::Articulation

    # [#it-002]

    def self.[] enum=nil, def_blk
     f = build_function def_blk
     if enum
       f.call enum
     else
       f
     end
    end

    def self.build_function def_blk
      tmpl = on_zero_items_f = aggregate_f =
        on_first_mention_f = on_subsequent_mentions_f = nil
      Conduit_.new(
        -> str { tmpl = str },
        -> ozi { on_zero_items_f = ozi },
        -> &agg { aggregate_f = agg },
        -> &ofm { on_first_mention_f = ofm },
        -> &osm { on_subsequent_mentions_f = osm }
      ).instance_exec( & def_blk )
      Flusher_.new(
        tmpl, on_zero_items_f, aggregate_f, on_first_mention_f,
          on_subsequent_mentions_f
      ).flush
    end

    Conduit_ = MetaHell::Enhance::Conduit.new %i|
      template on_zero_items aggregate on_first_mention on_subsequent_mentions
    |

    class Flusher_
      def initialize template_str, on_zero_items_f, aggregate_f,
                         on_first_mention_f, on_subsequent_mentions_f
        tmpl = Basic::String::Template.from_string template_str
        whn = build_whens tmpl, aggregate_f, on_first_mention_f,
          on_subsequent_mentions_f

        @flush = -> do
          -> ea_x do
            scn = Basic::List::Scanner[ ea_x ]
            x = scn.gets
            if ! x
              on_zero_items_f.call if on_zero_items_f
            else
              sio = Basic::Services::StringIO.new
              yld = ::Enumerator::Yielder.new do |data|
                sio.write data
              end
              run yld, x, scn, tmpl, whn
              sio.rewind ; sio.read
            end
          end
        end
      end

      def flush
        @flush.call
      end

      def build_whens tmpl, aggregate_f, on_first_mention_f,
          on_subsequent_mentions_f

        flusher = Mention_::Flusher_.new(
          nn_a = tmpl.formal_parameters.map( & :normalized_name ) )
        whn = When_[ flusher.flush( on_first_mention_f ),
          flusher.flush( on_subsequent_mentions_f ),
          flusher.flush( aggregate_f ), nn_a ]

        a = trueish_members whn.aggregate
        case a.length
        when 0 ; fail "must aggregate on one channel"
        when 1 ;
        else   ; fail "for now we can't aggregate one more than one channel #{
          }(had: #{ a * ', ' })"
        end
        k = a.fetch( 0 )
        whn.aggregate = [ k, whn.aggregate[ k ] ]
        whn
      end
      private :build_whens

      When_ = ::Struct.new :first, :subsequent, :aggregate, :names

      def trueish_members st
        st.to_h.reduce [] do |m, (k, v)|
          m << k if v
          m
        end
      end
      private :trueish_members

      def run yld, x, scn, tmpl, whn
        k, f = whn.aggregate
        frame_a_a = ( trueish_members( whn.first ) |
          trueish_members( whn.subsequent ) ) & x.members
        frame_a_ = frame_a_a.map { |i| x[ i ] }
        frame_a__ = nil
        cache_a = [ x[ k ] ]
        count = 0
        flush2 = nil
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
            elsif k == i
              m[ i ] = f.call cache_a
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
            whn.first._flush.call str
          else
            whn.subsequent._flush.call str
          end )
        end
        while (( xx = scn.gets ))
          frame_a = frame_a_a.map { |i| xx[ i ] }
          if frame_a == frame_a_
            cache_a << xx[ k ]
          else
            flush[ ]
            frame_a_ = frame_a
            cache_a.clear.push xx[ k ]
          end
        end
        if cache_a.length.nonzero?
          flush[ ]
        end
        nil
      end
      private :run
    end

    module Mention_

    end

    class Mention_::Flusher_

      def initialize nn_a
        @conduit_class = MetaHell::Enhance::Conduit.new [ * nn_a , :_flush ]
        @conduit_class.const_set :FUNC_STRUCT_,
          ::Struct.new( * @conduit_class::A_ )
      end

      def flush func
        fs = @conduit_class::FUNC_STRUCT_.new
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
        fs
      end
    end
  end
end
