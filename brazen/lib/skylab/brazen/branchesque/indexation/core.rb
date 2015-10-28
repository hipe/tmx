module Skylab::Brazen

  class Branchesque::Indexation  # tracked by [#013]

    # this is a "cacheing indexation". it is for a non-dynamic branch only.
    # it caches traversals of the branch's children lazily. we call it an
    # "indexation" as opposed to an "index" because it has state (as opposed
    # to being immutable) and effects behavior as it used.

    def initialize source, unbound=nil

      @_source = source
      @_subject_unbound = unbound

      @_did_cache_promos = false
      @_did_cache_UBS = false
    end

    # ~ wheter "unbound via" is promotion aware is currently undefined!

    def unbound_via_arglist x_a, & x_p

      ( @___LU ||= Here_::Unbound_Via___.new self ).__send__(
        x_a.first,
        * x_a[ 1 .. -1 ],
        & x_p )
    end

    # ~ the below *are* aware of [document] algorithm

    def build_unordered_selection_stream & x_p

      # your "selection stream" is for when you *are* selected and you
      # are letting your real children expand your ("apparent") stream.

      # it's "selection stream" because it can be used to both resolve a
      # selected node and to index/display the selection of available nodes.

      build_unordered_real_stream( & x_p ).expand_by do | unb |

        unb.build_unordered_index_stream( & x_p )
      end
    end

    def build_unordered_index_stream & x_p

      # your "index stream" is for when you are being indexed by a parent
      # by the above described process, and you are given a chance to expand
      # your presence in the stream beyond just yourself.

      # because of the algorithm described in the document, no matter what we
      # have to traverse the whole list once to know its shape, hence there
      # is no true streaming for this sort of stream.

      if ! @_did_cache_promos
        @_did_cache_promos = true
        @_cached_promos = __build_promos_array( & x_p )
      end

      if @_cached_promos
        Callback_::Stream.via_nonsparse_array @_cached_promos
      end
    end

    # ~ support

    def __build_promos_array & x_p

      pr_a = nil
      np_y = false

      st = build_unordered_real_stream( & x_p )
      begin
        unb = st.gets
        unb or break
        if unb.is_promoted
          ( pr_a ||= [] ).push unb
        else
          np_y = true
        end
        redo
      end while nil

      # if you have any non-promoteds (normal), you must add yourself
      # to the promoteds so that these children have a selection path.
      # otherwise, (and none of your children are non-promoted), it must
      # be that you are not selectable at all.

      if np_y && @_subject_unbound
        ( pr_a ||= [] ).push @_subject_unbound
      end

      pr_a
    end

    # ~ the below is *not* aware of promotionality.

    def build_unordered_real_stream & x_p

      # if we have ever reached the end of this same stream before, we use
      # the cached (array) means of creating the stream. otherwise..

      if @_did_cache_UBS

        Callback_::Stream.via_nonsparse_array @_cached_UBS

      else

        __build_and_possibly_cache_unbound_stream
      end
    end

    def __build_and_possibly_cache_unbound_stream

      # any time we reach the end of the stream, this means we had a chance
      # to cache its extent so we would not have to build it subsequently
      # again in the future. however, we do *not* want to cache partially
      # traversed streams. we store the array IFF we reach the end.
      #
      # this caching of course assumes non-dynamic trees. and dynamic trees
      # will certainly become a thing..


      _st = Callback_::Stream.via_nonsparse_array @_source.constants

      _st = _st.map_reduce_by do | const |

        if UNDERSCORE_ != const[ -1 ]  # implement #API-point-A

          any_unbound_via_const const
        end
      end

      a  = []

      _st.map_by do | unb |

        if unb
          a.push unb
          unb
        else
          @_did_cache_UBS = true
          @_cached_UBS = a
          NIL_
        end
      end
    end

    def any_unbound_via_const const

      x = @_source.const_get const, false

      # build out the below IN THE RIGHT ORDER as necessary

      if x.respond_to? :build_unordered_index_stream

        x

      elsif x.respond_to? :call

        __unbound_via_proc x, const

      elsif x.respond_to? :name

        # assume module-like

        __any_unbound_via_module x

      else
        self._COVER_ME_unrecognized_shape_for_reactive_tree_node
      end
    end

    def __unbound_via_proc x, const

      Home_.lib_.basic::Function::As::Unbound.new(
        x,
        const,
        @_source,
        @_subject_unbound,
      )
    end

    def __any_unbound_via_module mod

      source = mod.const_get Home_::ACTIONS_CONST, false

      if source

        Home_.lib_.basic::Module::As::Unbound.new(
          source,
          mod,
        )
      end
    end

    Here_ = self
  end
end
