# the formal box narrative :[#061]

## obviation path

(being kept for posterity now, this was the conversion table)

                feature name | orig | new
                      length | same | length
                       count | same
                   get_keys | same | same
                        has? | same | has_key
                         if? | same | [algorithms]
                        each | same | each_pair
                   each_pair | same |
                      detect |
                    defectch |
                      filter |
                         map |
                      reduce |
                      select |
                       which |
                          at |
                at_with_name |
                to_pair_scan | same | to_pair_stream
            get_value_stream |
                       fetch |
           fetch_at_position |
                       first |
                 fuzzy_fetch |
                      invert |
                     to_hash |
                   to_struct |
                      accept |
                         add |
                      change | same | replace
               sort_name_by! |
                       clear |
                  partition! |
                      delete |
             delete_multiple |
     partition_where_name_in |
                        `[]` |
                        to_a |
                      values |
                 around_hash | hack


## introduction

"box" is an implementation of an ordered dictionary, and our favorite
general purpose (Associative container)

    http://en.wikipedia.org/wiki/Container_(abstract_data_type)  # #todo

its primary purpose is to give you an interface that feels something
like a hash, but one that forces you to be more explicit about your
presuppositions when mutating it: there is no `[]=` method, rather, you
must indicate that the operation is either an `add`, a `replace` (or if
you don't care whether or not you clobber an existing value) a `set`.




## :#storypoint-480

given the first proc and an optional second proc (with the block
counting as a proc), retrieve an entry that matches using the
first proc, and call the second proc if not found.

if the first proc has an arity of 2, it will receive each key and
value. otherwise it will be passed just each value. based on this
same criteria; if an entry is found, the result of the topic method
will be either the key and value (in an array of length 2) or just
the value.

the second proc (when present, and called) is always called with
no arguments. if the second proc is not provided and an entry is
not found, a key error is raised. whew.
