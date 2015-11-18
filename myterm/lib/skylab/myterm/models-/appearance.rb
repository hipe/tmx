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
          ACS_[]::For_Interface::Touch[ qkn, self ]
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

    # ~ hook-out's for component change, mutation

    def receive_component__change__ asc, & x_p

      # a 'change' means the component is telling any custodian to swap
      # in the new component for the old (as a result of a UI action or
      # similar). how it is handled is different based on etc:

      send :"__receive__#{ asc.sub_category }__component_change", asc, & x_p
    end

    def __receive__visiting__component_change asc, & new_component

      asc._real_ACS.receive_component_change__ asc, & new_component
    end

    def __receive__common__component_change asc, & new_component

      # one of our own component values has changed. swap in the new value

      _new_component = new_component[]

      _ev_p = ACS_[]::Interpretation::Accept_component_change[
        _new_component, asc, self ]

      _emit_and_persist _ev_p[]
    end

    def receive_component__event_and_mutated__ asc, & event_and_mutated_p

      # this is called when an immediate compound component signals that
      # it has mutated in-place..

      ev_p, cmp = event_and_mutated_p.call

      ___store_possibly_floating_component cmp, asc

      _context = ev_p[]

      _event = ACS_[]::Modalities::Human::Event_via_context[ _context ]

      _emit_and_persist _event
    end

    def ___store_possibly_floating_component cmp, asc

      # setting the ivar where it was not set before makes it serializable

      ivar = asc.name.as_ivar
      x = instance_variable_get ivar  # assume is set *for now*
      if x
        x.object_id == cmp.object_id or self._SANITY
      else
        instance_variable_set ivar, cmp
        _gulp_ivar =
          :"@_read_only__#{ asc.name.as_lowercase_with_underscores_symbol }__"
        x = remove_instance_variable _gulp_ivar
        x.object_id == cmp.object_id or self._SANITY
      end
      NIL_
    end

    def _emit_and_persist ev

      @_oes_p.call( * ev.suggested_event_channel ) do
        ev
      end

      o = ACS_[]::Modalities::JSON::Express.new( & @_oes_p )

      o.downstream_IO_proc = remove_instance_variable :@_produce_writable_IO

      o.upstream_ACS = self

      o.execute  # result is result
    end

    # ~ error and info

    def receive_component__error__ asc, desc_sym, & linked_list_p

      # tricky -

      if asc.model_classifications.looks_entitesque

        # assume that if the immediate component of origin is "entitesque"
        # than it is model-controller-like and we must add one element.

        _LL = linked_list_p[]
        _linked_list = Add_context_[ asc.name, _LL ]

      else

        # otherwise (and this is from perhaps an adpater, but whatever)
        # assume that it is already contextualized to the desired amount.

        _linked_list = linked_list_p[]
      end

      # convert the linked list back into a plain event for the final
      # (top) emission (for now fail early)

      _ev = ACS_[]::Modalities::Human::Event_via_context[ _linked_list ]

      @_oes_p.call :error, desc_sym do
        _ev
      end

      UNABLE_  # (perhaps not important)
    end

    def receive_component__info__expression__ _asc, desc_sym, & y_p

      @_oes_p.call :info, :expression, desc_sym, & y_p
    end

    def receive_component__info__ _asc, desc_sym, & ev_p

      # info's are expected to come from adapters already contextualized

      @_oes_p.call :info, desc_sym do

        ev_p[] # (hi.)
      end
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

      ACS_[]::Interpretation::Build_empty_hot.call _asc, self

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
  end
end
