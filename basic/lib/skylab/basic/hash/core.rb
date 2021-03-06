module Skylab::Basic

  module Hash  # doc: [#026] the hash narrative

    class << self

      def pairs_at * i_a, & p
        METHODS__.pairs_at_via_names i_a, & p
      end

      def pair_stream h
        a = h.keys
        Common_::Stream.via_times( a.length ).map_by do |d|
          k = a.fetch d
          Common_::QualifiedKnownKnown.via_value_and_symbol h.fetch( k ), k
        end
      end
    end

    Loquacious_default_proc__ = -> moniker, h, k do

      # the loquacious default proc tries to generate sexy helpful messages:
      #
      #     h = { foo: 'bar', biff: 'baz' }
      #     h.default_proc = Subject_[].loquacious_default_proc.curry[ 'beefel' ]
      #     h[ :luhrmann ]  # => KeyError: no such beefel 'luhrmann'. did you mean 'foo' or 'biff'?

      o = Home_.lib_

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
      # but read [#026.2] "the unpack_* methods"

      Unpack_equal__ = -> h, * k_a do
        Validate_superset[ h, k_a ]
        Unpack_subset__[ h, *k_a ]
      end

      Unpack_superset__ = -> h, * k_a do
        Validate_superset[ h, k_a ]
        Unpack_intersect__[ h, *k_a ]
      end

      Unpack_subset__ = -> h, * k_a do
        k_a.map { |k| h.fetch k }
      end

      say_extra = nil
      Validate_superset = -> h, k_a do

        xtra_a = h.keys - k_a
        if xtra_a.length.nonzero?
          raise ::KeyError, say_extra[ xtra_a ]
        end
      end

      say_extra = -> xtra_a do
        "unrecognized key(s) - (#{ xtra_a.map( & :inspect ) * ', ' })"
      end

      Unpack_intersect__ = -> h, * k_a do
        k_a.map { |k| h.fetch k do end }
      end

      Repack_difference__ = -> h, * k_a do
        ::Hash[ ( h.keys - k_a ).map { |i| [ i, h.fetch( i ) ] } ]
      end

      Write_even_iambic_subset_into_via___ = -> h, x_a do

        x_a.each_slice 2 do | k, x |
          if h.key? k
            h[ k ] = x
          end
        end
        h
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
      o[ :unpack_subset ] = Unpack_subset__

      o[ :write_even_iambic_subset_into_via ] = Write_even_iambic_subset_into_via___

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
