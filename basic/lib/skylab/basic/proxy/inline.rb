module Skylab::Basic

  # ->

    class Proxy::Inline < ::BasicObject

      # produce a proxy "inline" from a hash-like whose values are procs:
      #
      # self._REDO_DOCTEST
      #
      #     pxy = Subject_.call(
      #       :foo, -> x { "bar: #{ x }" },
      #       :biz, -> { :baz } )
      #
      #     pxy.foo( :wee )  # => "bar: wee"
      #
      #     pxy.biz  # => :baz
      #
      # (this is essentially a convenience wrapper around
      # `define_singelton_method`.)
      #
      # (past names for this include:
      #   `generic`, `plastic`, `dynamic`, `ad_hoc`)

      def initialize * x_a, & convenience_p

        pair_st = Try_convert_iambic_to_pair_stream_[ x_a ]

        _I_A = []

        add = -> do
          class << self  # because basic object
            self
          end.class_exec do
            -> sym, p do
              _I_A.push sym
              define_method sym, -> * a, & p_ do
                p[ * a, & p ]  # call the proc in its original context
              end
            end
          end
        end.call

        while pair = pair_st.gets

          sym = pair.name_symbol
          add[ sym, pair.value_x ]
          if :inspect == sym
            did_inspect = true
            break
          end
        end

        if did_inspect
          while pair = pair_st.gets
            add[ pair.name_symbol, pair.value_x ]
          end
        else
          add[ :inspect, -> do
            "<##{ Inline__ }:(#{ _I_A * ', ' })>"
          end ]
        end

        if convenience_p
          instance_exec( & convenience_p )
        end
      end
    end
  # <-
end
