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

        pairs_scn = Try_convert_iambic_to_pairs_scan_[ x_a ]

        _I_A = []

        add = -> do
          class << self  # because basic object
            self
          end.class_exec do
            -> i, p do
              _I_A.push i
              define_method i, -> * a, & p_ do
                p[ * a, & p ]  # call the proc in its original context
              end
            end
          end
        end.call

        while pair = pairs_scn.gets
          i, p = pair
          add[ i, p ]
          if :inspect == i
            did_inspect = true
            break
          end
        end

        if did_inspect
          while pair = pairs_scn.gets
            add[ * pair ]
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
