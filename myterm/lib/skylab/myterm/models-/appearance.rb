module Skylab::MyTerm

  class Models_::Appearance

    # "appearance" as in the iTerm appearance.

    class Silo_Daemon

      def initialize ke
        @_kernel = ke
      end

      def build_unordered_index_stream & x_p

        app = Here_.new @_kernel, & x_p
        _ok = app.__init
        _ok && app.to_unordered_index_stream
      end
    end

      # ~ initialization as entity

      def initialize ke, & x_p

        @adapter = nil
        @_kernel = ke
        @_oes_p = x_p
      end

      def __init

        inst = @_kernel.silo :Installation

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
        o.context_string_proc_stack = [ -> do
          "in #{ pth io.path }"
        end ]
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

      # ~ adapt to reactive tree & ACS

      def to_unordered_index_stream  # for reactive tree

        o = ACS_[]::Modalities::Reactive_Tree::Children_as_unbound_stream.new(
          & @_oes_p )

        o.ACS = self

        o.node_stream = ___to_node_stream_for_interface

        o.execute
      end

      def ___to_node_stream_for_interface

        st = ACS_[]::Reflection::To_node_stream[ self ]

        if @adapter
          _st_ = @adapter.to_particular_node_stream__
          st = st.concat_by _st_
        end

        st
      end

      def to_association_stream_for_serialization

        # (hi - this is what is default, here for clarity: when serializing/
        #  unserializing, use our methods (index) to define our assocs)

        ACS_[]::Reflection::To_association_stream[ self ]
      end

      def lookup_component_association sym

        cb = ( @___CA_builder ||= ACS_[]::Conventional_CA_Builder.for self )

        if cb.can_build_association_for sym
          cb.build_association_for sym
        else
          self._K
        end
      end

      def __adapter__component_association
        Models_::Adapter
      end

      # ~ receive messages from children, provide services to children

      def __receive__component__change__ & ev_p

        ACS_[]::Interpretation::Accept_component_change[ ev_p, self, & @_oes_p ]

        o = ACS_[]::Modalities::JSON::Express.new( & @_oes_p )

        o.downstream_IO_proc = remove_instance_variable :@_produce_writable_IO

        o.upstream_ACS = self

        o.execute
      end

      def kernel_
        @_kernel
      end

    Here_ = self
  end
end
