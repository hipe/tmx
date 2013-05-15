module Skylab::Basic

  module Hash

  end

  Hash::FUN = -> do

    o = MetaHell::Formal::Box::Open.new

    # the `unpack_*` methods -

    # in other worlds this idea is generally referred to as a "hash slice",
    # but here, we go deep on slice. we use set theory on your slice. instead
    # of one method for this, we give you four functions. FOUR.

    # all `unpack_*` functions below have the same form of result:
    # they all result in an array whose length always corresponds to
    # the length of `k_a` (keys array), which is a globbed parameter
    # of args (2..N) that you pass, e.g:
    #
    #     h = { age: 2, name: "me" }
    #     name, age = FUN.unpack_equal[ h, :name, :age ]
    #     name  # => "me"  etc
    #
    # easy, right? where's the fun in that? let's make it complicated:
    #
    # consider the set of keys you want (`k_a`) and the set of keys that
    # exist in the hash (we might call it `h_k_a`). in total we will herein
    # conceptualize 5 kinds of relationships these sets can have to one
    # another: no intersect, some intersect, containment the one way (we'll
    # call it "superset"), containment the other way ("subset"),
    # and equality.
    #
    # So then, each '*' of the `unpack_*` set of methods below comes from
    # one of the above relationships (in order of "hardest" to "softest"):
    # we have `unpack_equal`, `unpack_superset`, `upack_subset`, and
    # `unpack_intersect` (note they do not line up exactly ..).
    #
    # (to jump ahead, these sets of relationships have set relationships
    # themselves, which i only mention because it manifests itself in the
    # behavior here: "equality" is a subset of "containment", so any (non-
    # exceptional) result that you get from a call to `unpack_equal`,
    # you would always get the same result if you had called `unpack_superset`
    # or `unpack_subset`, but the reverse is certainly not necessarily
    # true - the latter two are "softer", which means they let more things
    # through without raising exceptions.)

    # `unpack_equal` - hash `h` must have all keys in `k_a` and no keys
    # that are not in `k_a`, asserted under penalty of key error exception
    # raisal. raisal is not a word. result is all of the hash's values as
    # an array in the order that its keys appear in in `k_a`.

    validate_superset = unpack_subset = nil
    o[:unpack_equal] = -> h, *k_a do
      validate_superset[ h, k_a ]
      unpack_subset[ h, *k_a ]
    end

    # `unpack_superset` - it is asserted that `k_a` form a superset of
    # all the keys in hash `h`, that is, `h` doesn't need to have all the keys
    # in `k_a` but all keys that it does have must be in `k_a`. this is
    # asserted under penalty of key error exception raisal. raisal is still
    # not a word.

    unpack_intersect = nil
    o[:unpack_superset] = -> h, *k_a do
      validate_superset[ h, k_a ]
      unpack_intersect[ h, *k_a ]
    end

    # `unpack_subset` - (map fetch) `k_a` must be a subset of the keys
    # of hash `h` under penalty of (native) ::KeyError being raised.
    #
    # (hash `h` can have keys other than the keys in `k_a` and this function
    # won't notice.)

    o[:unpack_subset] = unpack_subset = -> h, *k_a do
      k_a.map { |k| h.fetch k }
    end

    # `validate_superset` (private function) validate that `k_a` is
    # a superset of `h_k_a`

    validate_superset = -> h, k_a do
      ( xtra_a = h.keys - k_a ).length.nonzero? and raise ::KeyError,
        "unrecognized key(s) - (#{ xtra_a.map( & :inspect ) * ', ' })"
    end

    # `unpack_intersect` - the softest of them all: result values are any
    # corresponding values from the hash, otherwise nil; will no regard
    # to the composition of keys in the hash. if `h` is a hash this cannot
    # fail, and result (like all functions above) is always an array of
    # same length as `k_a`.

    o[:unpack_intersect] = unpack_intersect = -> h, *k_a do
      k_a.map { |k| h.fetch k do end }
    end

    # `repack_difference` - as long as we're doing it this way..

    o[:repack_difference] = -> h, *k_a do
      ::Hash[ ( h.keys - k_a ).map { |i| [ i, h.fetch( i ) ] } ]
    end

    o.to_struct                   # people just love using `at`
  end.call
end
