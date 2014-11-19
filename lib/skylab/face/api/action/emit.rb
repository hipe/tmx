module Skylab::Face

  module API::Action::Emit

    # `self.[]` - fulfill [#026]. unlike its bretheren it does
    # *not* assume it is behind a mutex because it can get vivified from
    # multiple entrypoints, namely `listeners_digraph` *and/or* `taxonomic_streams`
    # (just as two examples)

    -> do  # `self.[]`
      emits = nil
      define_singleton_method :[] do |kls, meth_i, a, b|
        kls.class_exec do
          if ! respond_to? :is_callback_digraph_module or
              ! is_callback_digraph_module  # unlikely
            Callback_[ self, :employ_DSL_for_digraph_emitter ]
            public :on, :with_specificity  # per the way we wire API actions.
            define_singleton_method :listeners_digraph, & emits[ self ]
          end
        end
        kls.send meth_i, *a, &b
      end

      emits = -> kls do
        orig_emits = kls.method( :listeners_digraph ).unbind

        LIB_.module_lib.mutex( :listeners_digraph, -> * a, & b do
          orig_emits.bind( self ).call( *a, &b )
          @event_stream_graph.names.each do |i|
            define_method i do |x|
              call_digraph_listeners i, x
              nil
            end
          end
          nil
        end )
      end
    end.call

    # EXPERIMENTAL - the above does a filthy nasty trick - for *every* event
    # stream that we declare in our `listeners_digraph` statement, we define a
    # corresponding instance method *of the same name* that emits a probably
    # universal event.
    #
    # (we know when you are done declaring events because you can only call
    # `listeners_digraph` zero or one times per class!)
    #
    # this is probably fine for most applications because a) it is sort of
    # like what we always did anyway (but we cluttered the codespace with
    # noisy little dumb methods) and b) you can always override these default
    # emitter methods.
    #
    # *one* corollary of this is that you have to watch your method namespace
    # for collisions, but as long as you take that into account, we *might*
    # be ok.. #experimental!
  end
end
