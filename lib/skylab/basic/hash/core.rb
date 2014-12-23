module Skylab::Basic

  module Hash  # read [#026] the hash narrative #storypoint-005 introduction

    class << self

      def determine_hotstrings s_a
        Hash_::Actors__::Determine_hotstrings[ s_a ]
      end

      def pairs_at * i_a, & p
        METHODS__.pairs_at_via_names i_a, & p
      end

      def pairs_scan h
        a = h.keys
        Callback_.scan.via_times( a.length ).map_by do |d|
          [ a.fetch( d ), h.fetch( a.fetch d ) ]
        end
      end
    end

    Loquacious_default_proc__ = -> moniker, h, k do

      # the loquacious default proc tries to generate sexy helpful messages:
      #
      #     h = { foo: 'bar', biff: 'baz' }
      #     h.default_proc = Subject_[].loquacious_default_proc.curry[ 'beefel' ]
      #     h[ :luhrmann ]  # => KeyError: no such beefel 'luhrmann'. did you mean 'foo' or 'biff'?

      o = Basic_._lib

      _msg = "no such #{ moniker } #{ o.strange k }. #{
        }did you mean #{ o.oxford_or h.keys.map( & Lib_::Strange ) }?"

      raise ::KeyError, _msg
    end

      # `unpack_equal` flattens a hash's values into an array
      #
      #     h = { age: 2, name: "me" }
      #     name, age = Subject_[].unpack_equal h, :name, :age
      #     name  # => "me"
      #     age  # => 2
      #
      # but read [#026] the hash narrative # #storypoint-105

      Unpack_equal__ = -> h, * k_a do
        Validate_superset__[ h, k_a ]
        Unpack_subset__[ h, *k_a ]
      end

      Unpack_superset__ = -> h, * k_a do
        Validate_superset__[ h, k_a ]
        Unpack_intersect__[ h, *k_a ]
      end

      Unpack_subset__ = -> h, * k_a do
        k_a.map { |k| h.fetch k }
      end

      Validate_superset__ = -> h, k_a do
        ( xtra_a = h.keys - k_a ).length.zero? or raise ::KeyError,
          "unrecognized key(s) - (#{ xtra_a.map( & :inspect ) * ', ' })"
      end

      Unpack_intersect__ = -> h, * k_a do
        k_a.map { |k| h.fetch k do end }
      end

      Repack_difference__ = -> h, * k_a do
        ::Hash[ ( h.keys - k_a ).map { |i| [ i, h.fetch( i ) ] } ]
      end

    -> do  # ~ singleton methods

      o = -> i, p do
        define_singleton_method i, p
      end
      o.singleton_class.send :alias_method, :[]=, :call

      o[ :loquacious_default_proc ] = -> do
        Loquacious_default_proc__
      end

      o[ :unpack_equal ] = Unpack_equal__

    end.call

    METHODS__ = -> do  # ~ #+:cherry-pickable method definitions

      i_a = [] ; p_a = []
      o = -> i, p do
        i_a.push i ; p_a.push p
      end
      o.singleton_class.send :alias_method, :[]=, :call

      o[ :repack_difference ] = Repack_difference__

      o[ :unpack_equal ] = Unpack_equal__

      o[ :unpack_subset ] = Unpack_subset__

      o[ :unpack_superset ] = Unpack_superset__

      ::Struct.new( * i_a ).new( * p_a )

    end.call

    def METHODS__.pairs_at_via_names i_a
      if block_given?
        i_a.each do |i|
          yield i, self[ i ]
        end ; nil
      else
        enum_for :pairs_at_via_names, i_a
      end
    end

    Hash_ = self
  end
end
