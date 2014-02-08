module Skylab::Basic

  module Hash  # read [#026] the hash narrative #storypoint-005 introduction

    Loquacious_default_proc = -> moniker, h, k do

      # the loquacious default proc
      # can be used like so:
      #     h = { foo: 'bar', biff: 'baz' }
      #     h.default_proc = Basic::Hash::Loquacious_default_proc.
      #       curry[ 'beefel' ]
      #     h[ :luhrmann ]  # => KeyError: no such beefel 'luhrmann'. did you mean 'foo' or 'biff'?

      _msg = "no such #{ moniker } #{ Basic::FUN::Inspect[ k ] }. #{
        }did you mean #{
          Basic::Lib_::Oxford_or[ h.keys.map( & Lib_::Inspect ) ] }?"
      raise ::KeyError, _msg
    end

    module FUN

      # read [#026] the hash narrative # #storypoint-105
      # but here's the gist of it:
      #
      #     h = { age: 2, name: "me" }
      #     name, age = Basic::Hash::FUN::Unpack_equal[ h, :name, :age ]
      #     name  # => "me"
      #     age  # => 2

      Unpack_equal = -> h, * k_a do
        Validate_superset__[ h, k_a ]
        Unpack_subset[ h, *k_a ]
      end

      Unpack_superset = -> h, * k_a do
        Validate_superset__[ h, k_a ]
        Unpack_intersect[ h, *k_a ]
      end

      Unpack_subset = -> h, * k_a do
        k_a.map { |k| h.fetch k }
      end

      Validate_superset__ = -> h, k_a do
        ( xtra_a = h.keys - k_a ).length.zero? or raise ::KeyError,
          "unrecognized key(s) - (#{ xtra_a.map( & :inspect ) * ', ' })"
      end

      Unpack_intersect = -> h, * k_a do
        k_a.map { |k| h.fetch k do end }
      end

      Repack_difference = -> h, * k_a do
        ::Hash[ ( h.keys - k_a ).map { |i| [ i, h.fetch( i ) ] } ]
      end

      # 'pairs_at' is like 'values_at' and 'each_pair' combined
      # and note that it methodizes the names as a rule
      #
      #     fun = Basic::Hash::FUN
      #     _a = fun.pairs_at( :unpack_subset ).to_a
      #     _a  # => [ [ :unpack_subset, fun::Unpack_subset ] ]

      class << self
        def pairs_at * i_a
          if block_given?
            1 == i_a.length and x = ::Array.try_convert( i_a.first ) and i_a = x
            h = index_h
            i_a.each do |i|
              yield i, h.fetch( i )
            end ; nil
          else
            to_enum :pairs_at, * i_a
          end
        end
        def [] i
          index_h.fetch i
        end
      private
        def index_h
          @idx_h ||= bld_idx
        end
        def bld_idx
          ::Hash[ constants.map do |i|
            str = i.id2name
            str[ 0 ] = str[ 0 ].downcase
            [ str.intern, const_get( i ) ]
          end ]
        end
      end
    end
  end
end
