module Skylab::MyTerm

  class Models_::Appearance

    # "appearance" as in the iTerm appearance.

    class Silo_Daemon

      def initialize ke
        @_kernel = ke
      end

      def build_unordered_index_stream & x_p

        app = Here_.new @_kernel, & x_p
        _ok = app.init
        _ok && app.to_unordered_index_stream
      end
    end

      # ~ initialization as entity

      def initialize ke, & x_p
        @_kernel = ke
        @_oes_p = x_p
      end

      def init

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

        @_CAS = [ :adapter ]  # for now, still only this

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

        @_CAS = [ :adapter ]  # LOOK to start, you only have this one component

        @_is_created = true
        @_is_modified = false

        @_produce_writable_IO = inst.method :writable_IO

        ACHIEVED_
      end

      # ~ adapt to reactive tree, express via ACS

      def to_unordered_index_stream

        ACS_[]::Modalities::Reactive_Tree::Children_as_unbound_stream.call(
          self, & @_oes_p )
      end

      def component_association_symbols
        a = @_CAS  # when freshly initted, no children
        if a
          a
        else
          _ = ACS_[]::Reflection::Method_index_of_class[ self.class ]
          _.association_symbols
        end
      end

      def __adapter__component_association
        Models_::Adapter
      end

      def component_operation_symbols
        NIL_  # LOOK don't bother indexing our methods for operations ever
      end

      # ~ receive messages from children

      def __receive__component__change__ & ev_p

        ACS_[]::Interpretation::Accept_component_change[ ev_p, self, & @_oes_p ]

        o = ACS_[]::Modalities::JSON::Express.new( & @_oes_p )

        o.downstream_IO_proc = remove_instance_variable :@_produce_writable_IO

        o.upstream_ACS = self

        o.execute
      end

    Here_ = self
  end
end
