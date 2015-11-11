module Skylab::MyTerm

  class Models_::Appearance

    # "appearance" as in the iTerm appearance.

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

      # ~ initialization as entity

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
          self.__init_retrieved_via_IO io
        else
          __init_created inst
        end
      end

      def __init_retrieved_via_IO io

        o = ACS_[]::Modalities::JSON::Interpret.new( & @_oes_p )

        o.ACS = self

        o.prepend_more_specific_context_by do
          "in #{ pth io.path }"
        end

        o.JSON = io.read

        ok = o.execute

        if ok

          @_is_created = false
          @_is_modified = false

          @_produce_writable_IO = -> do
            io.rewind
            io.truncate 0
            io
          end
          ACHIEVED_
        else
          io.close
          ok
        end
      end

      def __init_created inst

        @_is_created = true
        @_is_modified = false

        @_produce_writable_IO = inst.method :writable_IO

        ACHIEVED_
      end

      # -- adapt to reactive tree & ACS --

      # ~ reactive tree hook-in's

      def __to_unordered_index_stream_for_reactive_tree

        o = ACS_[]::Modalities::Reactive_Tree::Children_as_unbound_stream.new(
          & @_oes_p )

        o.ACS = self

        o.stream_for_interface = ___to_stream_for_reactive_tree

        o.execute
      end

      def ___to_stream_for_reactive_tree

        st = ACS_[]::For_Interface::Infer_stream[ self ]

        if @adapter

          # this is the crux of our adapter mechanic:
          #
          # 1) an adapter is selected IFF the above ivar is set. per the
          # component association that defines it, the ivar holds not the
          # adapter itself but a "selected adapter" controller. this ivar is
          # set *only* thru a signal handler in this file or underialization.
          #
          # 2) if an an adapter is selected, it can add nodes ("qualified
          # knownnesses") to our interface stream as if they were our own.
          # somewhere else we manage delegating requests to the correct
          # component (the real adapter) by using the proxy class "visiting
          # association" to unwrap this

          ada = @adapter.selected_adapter__

          va = Models_::Adapter::Visiting_Association.new_prototype ada

          _st_ = ACS_[]::For_Interface::To_stream[ ada ]

          _st__ = _st_.map_by do | qkn |

            asc = qkn.association
            if :association == asc.category
              qkn.new_with_association va.new qkn.association
            else
              self._DESIGN_ME_write_me
            end
          end

          st = st.concat_by _st__
        end

        st
      end

      def component_value_reader_for_reactive_tree  # [#003]:storypoint-2

        # here is where we undo the truncating cleverness above: for any
        # association that we were pretending was ours but actually wasn't,
        # let the real parent build it; and let that component signal up to
        # the real parent, not to us.

        h = {
          common: -> asc do

            ACS_[]::For_Interface::Touch[ asc, self, & @_oes_p ]
          end,

          visiting: -> vasc do
            vasc.adapter_.read_for_component_interface__ vasc
          end
        }

        -> asc do

          h.fetch( asc.sub_category )[ asc ]
        end
      end

      # ~ [un]serialization hook-in's

      def to_stream_for_component_serialization

        # (this is what is default, here for clarity - when serializing/
        #  unserializing, use our methods (index) to define our assocs)

        ACS_[]::For_Serialization::Infer_stream[ self ]
      end

      # -- Component Associations --

      # ~ "adapter" (to put this before next looks better in JSON payloads)

      def __adapter__component_association

        Models_::Adapter
      end

      # ~ "adapters" & related

      def adapters

        # breaking autonomy, some components need this component as a
        # service. other times, the below is reconstructed from
        # serialization. (use of a silo daemon might be cleaner.)

        @adapters ||= ___build_adapters
      end

      def ___build_adapters

        # to accomodate the above we must sometimes build
        # the component association structure explicitly

        ca = @_real_assoc[ :adapters ]

        _p = ACS_[]::Interpretation::Component_handler[ ca, self, & @_oes_p ]

        ca.component_model.interpret_compound_component(
          IDENTITY_,
          self,
          & _p )
      end

      def __adapters__component_association

        # this has no interface expression but serialization expression

        yield :intent, :serialization

        Models_::Adapters
      end

      # ~ receive messages from children, provide services to children

      def receive__component__change__ asc, & change

        # • one of our own component values has changed. swap in the new value

        _ = ACS_[]::Interpretation::Accept_component_change[ self, asc, change ]

        _receive_mutation_as_top _[]
      end

      def receive__component__mutation__ asc, & mutation_p

        # • this is a signal that a component *changed* (past tense)
        #   somewhere "down deep". we don't have to change our own state.

        # • we don't push an item to the context chain because for whatever
        #   reason stating the box node explicitly sounds too verbose

        _mutation = mutation_p[]

        _receive_mutation_as_top _mutation
      end

      def _receive_mutation_as_top mutation

        # • here is where we must act like a top: convert signal to emission

        @_oes_p.call( * mutation.info_channel ) do
          mutation.to_event
        end

        o = ACS_[]::Modalities::JSON::Express.new( & @_oes_p )

        o.downstream_IO_proc = remove_instance_variable :@_produce_writable_IO

        o.upstream_ACS = self

        o.execute  # result is result
      end

      # -- more ACS hook-ins (when also in support of above) --

      # ~ general ACS hook-in's (alter default ACS behavior)

      def component_association_reader

        @_real_assoc = ACS_[]::Component_Association.method_based_reader_for self
        -> sym do
          @_real_assoc.call sym do
            self._K_now_you_have_to_read_a_visiting_component_association
          end
        end
      end

      # --

      attr_reader(
        :adapter,
        :kernel_,
      )

    # -

    Here_ = self
  end
end
