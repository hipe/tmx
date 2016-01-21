module Skylab::MyTerm

  class Models_::Appearance  # notes in [#003]

    # (by "appearance" we mean the iTerm appearance.)

    # -- Construction methods

    class Silo_Daemon

      def initialize ke
        @_ke = ke
      end

      def build_unordered_index_stream & x_p

        app = Here_.new @_ke, & x_p
        _ok = app.__init
        _ok && app.__to_unordered_index_stream_for_reactive_tree
      end
    end

    # -- Initializers

    def initialize ke, & x_p

      @adapter = nil
      @adapters = nil
      @kernel_ = ke
      @_oes_p = x_p
    end

    def __init

      inst = @kernel_.silo :Installation

      io = inst.any_existing_read_writable_IO
      if io
        __init_retrieved_via_IO io
      else
        __init_created inst
      end
    end

    def __init_retrieved_via_IO io

      _ok = ___unserialize io
      _ok and __post_unserialize io
    end

    def ___unserialize io

      o = ACS_[]::Modalities::JSON::Interpret.new( & @_oes_p )

      o.ACS = self

      o.prepend_more_specific_context_by do
        "in #{ pth io.path }"
      end

      o.JSON = io.read

      o.execute
    end

    def __post_unserialize io

      # (yes we could automate the de-referencing of references in our
      # graph that is freshly unserialized, but that is not something
      # we want to undertake at the moment..)

      ok = if @adapter
        x = @adapter.unserialize_
        if x
          @adapter = x
          ACHIEVED_
        else
          x
        end
      else
        true
      end

      if ok

        @_is_created = false
        @_is_modified = false

        @_produce_writable_IO = -> do
          io.rewind
          io.truncate 0
          io
        end
      else
        io.close
      end
      ok
    end

    def __init_created inst

      @_is_created = true
      @_is_modified = false

      @_produce_writable_IO = inst.method :writable_IO

      ACHIEVED_
    end

    # -- Expressive event & modality hook-ins/hook-outs

    def __to_unordered_index_stream_for_reactive_tree

      o = ACS_[]::Modalities::Reactive_Tree::Children_as_unbound_stream.new(
      ) do | * i_a, & ev_p |
        self._K
      end

      o.ACS = self

      o.stream_for_interface = ___to_stream_for_reactive_tree

      o.execute
    end

    def ___to_stream_for_reactive_tree

      st = ACS_[]::For_Interface::Infer_stream[ self ]

      if @adapter
        st = ___concatenate_adapter_specific_items st
      end

      st
    end

    def ___concatenate_adapter_specific_items st

      # see [#]:how-component-injection-is-currently-implemented

      ada = @adapter.selected_adapter__

      hacky_mutator = nil

      _adapter_stream = ACS_[]::For_Interface::To_stream[ ada ]

      _st_ = _adapter_stream.map_by do | qkn |

        # (works whether qkn is an effective known or not)

        asc = qkn.association
        :association == asc.category or self._DESIGN_ME_write_me

        hacky_mutator ||= Make_hacky_mutator___[ ada ]

        hacky_mutator[ qkn.association ]

        qkn
      end

      st.concat_by _st_
    end

    # -- ACS hook-in

    def component_association_reader
      @___comp_assoc_reader ||= ___build_comp_assoc_reader
    end

    def ___build_comp_assoc_reader

      real_assoc = ACS_[]::Component_Association.method_based_reader_for self
      -> sym do
        real_assoc.call sym do
          self._K_now_you_have_to_read_a_visiting_component_association
        end
      end
    end

    def component_value_reader_for_reactive_tree

      # :#here is where we pay back what we borrowed above when we reported
      # a visiting association as one of our own: when the time comes to
      # build such a component, we delegate this to the real custodian
      # through a special method. this is actually three "hops" we are
      # going down (e.g):
      #
      #     "appearance" <-> "adapters" <-> "imagemagick" <-> "font"

      h = {
        common: -> qkn do
          ACS_[]::For_Interface::Touch[ qkn, self ].value_x
        end,
        visiting: -> qkn do
          qkn.association._real_ACS.read_for_interface__ qkn
        end
      }

      -> qkn do
        h.fetch( qkn.association.sub_category )[ qkn ]
      end
    end

    def accept_component_qualified_knownness qkn  # write component value
      @___value_writer ||= ___build_writer
      @___value_writer[ qkn ]
    end

    def ___build_writer
      hi = ACS_[]::Reflection::Ivar_based_value_writer[ self ]
      h = {
        common: -> qkn do
          hi[ qkn ]
        end,
        visiting: -> qkn do
          qkn.association._real_ACS.accept_component_qualified_knownness qkn
        end,
      }
      -> qkn do
        h.fetch( qkn.association.sub_category )[ qkn ]
      end
    end

    def component_wrapped_value asc

      @___value_reader ||= ___build_reader
      @___value_reader[ asc ]
    end

    def ___build_reader

      hi = ACS_[]::Reflection::Ivar_based_value_reader[ self ]
      h = {
        common: -> asc do
          hi[ asc ]
        end,
        visiting: -> asc do
          asc._real_ACS.component_wrapped_value asc
        end,
      }
      -> asc do
        h.fetch( asc.sub_category )[ asc ]
      end
    end

    # ~ [un]serialization hook-ins

    def to_stream_for_component_serialization

      # (this is what is default, here for clarity - when serializing/
      #  unserializing, use our methods (index) to define our assocs)

      ACS_[]::For_Serialization::Infer_stream[ self ]
    end

    # -- Components

    # ~ "adapter" (to put this before next looks better in JSON payloads)

    def __adapter__component_association

      Models_::Adapter
    end

    def __adapters__component_association

      yield :intent, :serialization  # no UI expression, only s11n

      Models_::Adapters
    end

    # -- ACS signal handling

    def component_event_model
      :hot  # for now, un-s11n needs to know this [#ac-006]:#Event-models
    end

    def receive_component_event qkn, i_a, & ev_p  # mutates channel!

      # we do our own routing with more specific logic than [#ac-CHB]

      if :info == i_a.first

        # our info's are never contextualized, so whatever else this
        # emission has going on the mode client should can handle it

        @_oes_p[ * i_a, & ev_p ]

      else
        _cx = ___mutate_channel_by_classifying i_a
        __receive_classified_event _cx, qkn, i_a, & ev_p
      end
    end

    def ___mutate_channel_by_classifying i_a

      # what we're doing here is conceptually similar to [#ac-CHB], but
      # whereas that one shifts elements from the channel on to the method
      # name as long as there is a matching method, we shift elements from
      # the channel into a tuple as long as elements have special meaning.

      cat = i_a.shift

      if :contextualized == i_a.first  # include this magic ..
        i_a.shift
        ctx = true
      end

      if :expression == i_a.first
        i_a.shift
        exp = true
      end

      if :is_not == i_a.first
        i_a.shift
        isn = true
      end

      Event_Classifications___[ cat, ctx, exp, isn ]
    end

    Event_Classifications___ = ::Struct.new(
      :event_category,  # X
      :is_contextualized,  # X
      :is_expression,  # X
      :is_is_not,  # X
    )

    def __receive_classified_event o, qkn, i_a, & x_p

      # scope soup while we figure out what we want ..

      hu = ACS_[]::Modalities::Human

      is_contextualized = o.is_contextualized
      can_add_subject = true

      case o.event_category
      when :mutation

        # if a node mutated (which is to say "in-place"), then *it* changed
        # (not us), and *it* should have built the potential event already..

        can_add_subject = false

      when :change
        can_add_subject = false  # awful -  see #note-2 below
        is_contextualized = true

        ll = ___accept_change qkn, & x_p
      end

      if is_contextualized

        ll ||= x_p[]
        x_p = nil
        if can_add_subject && ll.next.next.nil?  # see #note-1 below
          ll = Linked_list_[][ ll, qkn.name ]
        end

        tc = hu::Traverse_context[ ll ]
        stack = tc.stack
        x_p = tc.end_value  # LOOK
      end

      if o.is_is_not

        if ! o.is_expression
          self._COVER_ME
        end

        ev = hu::Event_via_is_not[ * i_a, & x_p ]

      elsif o.is_expression

        # e.g system call errorr

        if is_contextualized

          ev = hu::Event_via_expression[ * i_a, o.event_category, & x_p ]

        else
          self._COVER_ME_expressions_must_be_contextualized_at_this_point
        end
      else
        ev = x_p[]
      end

      if stack
        ev = hu::Map_event_against_stack[ ev, stack ]
      end

      send :"__receive__#{ o.event_category }__", qkn, * i_a, ev
    end

    def ___accept_change qkn, & x_p

      _new_component = x_p[]

      _ev_p = ACS_[]::Interpretation::Accept_component_change[
        _new_component, qkn.association, self ]

      o = Linked_list_[]
      _end = o[ nil, _ev_p ]
      o[ _end, qkn.name ]
    end

    def __receive__error__ qkn, desc_sym, ev

      @_oes_p.call :error, desc_sym do
        ev
      end

      UNABLE_
    end

    # :#note-1 - do we add the association name of the immediate component
    # to the context stack? IFF this signal came from somewhere under the
    # "adapters" node we don't want to add the name "adapters" to the context
    # (nor is that node supposed to have added the name of the particular
    # adapter to the stack, but that's none of our business here!).
    # but the adapters node is the only one that gets this special treatment.
    # otherwise, we *must* add the association name of the immediate
    # component to the context, or some verbs won't have their subjects.
    # the way we test for this is a shotgun hack: simply look to see if the
    # list is deeper than some threshold. this approach won't "scale".

    # :#note-2 - awful - in some cases the event intrinsically expresses
    # the verb

    def __receive__mutation__ qkn, ev

      # whereas "change" means "definitely swap this new value in",
      # a "mutation" is at present a bit more involved:

      # a "floating" component is one that is not yet stored as a member
      # (in this case an ivar). if the component that mutated is floating,
      # we want to un-float it (that is, store it) because that is how
      # serialization decides what to serialize.

      @_oes_p.call( * ev.suggested_event_channel ) do
        ev
      end

      __shuffle_ivars_because_mutation qkn

      _persist
    end

    def __receive__change__ _qkn, ev

      # we have already accepted the component.

      @_oes_p.call( * ev.suggested_event_channel ) do
        ev
      end

      _persist
    end

    def __shuffle_ivars_because_mutation qkn  # ..

      new_x = qkn.value_x

      nf = qkn.name
      ivar = nf.as_ivar

      existing_x = instance_variable_get ivar

      existing_must_be_same_as_new = -> do
        if existing_x.object_id != new_x.object_id
          self._SANITY_is_not_mutation
        end
      end

      if existing_x.nil?

        _ = nf.as_lowercase_with_underscores_symbol
        _rd_only_ivar = :"@_read_only__#{ _ }__"
        existing_x = remove_instance_variable _rd_only_ivar
        existing_must_be_same_as_new[]
        instance_variable_set ivar, existing_x
      else
        existing_must_be_same_as_new[]
      end
      NIL_
    end

    #   ev.prefixed_conjunctive_phrase_context_stack.length

    def _persist

      # ~ serious business

      o = ACS_[]::Modalities::JSON::Express.new( & @_oes_p )

      o.downstream_IO_proc = remove_instance_variable :@_produce_writable_IO

      o.upstream_ACS = self

      _ok = o.execute  # result is result

      _ok
    end

    # -- Project hook-outs

    def adapters_

      # because one component serves as the cache and another component
      # wants to touch items in the cache, we need to expose it.

      if @adapters  # if persisted
        @adapters
      else
        @_read_only__adapters__ ||= ___build_read_only_adapters_model
      end
    end

    def ___build_read_only_adapters_model

      _asc = component_association_reader[ :adapters ]

      ACS_[]::Interpretation::Build_empty_hot[ _asc, self ].value_x

    end

    attr_reader(
      :kernel_,
    )

    # -- ACS hook-in (and related) NODES

    Make_hacky_mutator___ = -> ada do

      -> asc do
        if asc.respond_to? :__accept_real_ACS
          self._BOY_HOWDY
        end
        asc.singleton_class.send :prepend, Hackland___  # [#]:somewhat-nasty
        asc.__accept_real_ACS ada
        NIL_
      end
    end

    module Hackland___

      def __accept_real_ACS real_ACS
        @_real_ACS = real_ACS
        NIL_
      end

      def sub_category
        :visiting
      end

      attr_reader(
        :_real_ACS,
      )
    end

    Here_ = self
    UNDER__ = "__"
  end
end
