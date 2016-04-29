module Skylab::MyTerm

  class Models_::Appearance

    # this toplevel component of the ACS tree implements the
    # experimental plugin architecture described in [#003]

    def initialize ke

      @adapter = nil
      @adapters = nil

      @kernel_ = ke
    end

    def filesystem_knownness= kn
      @kernel_.silo( :Installation ).filesystem_knownness = kn
    end

    def system_conduit_knownness= kn
      @kernel_.silo( :Installation ).system_conduit_knownness = kn
    end

    def __adapters__component_association

      Models_::Adapters
    end

    def __adapter__component_association

      Models_::Adapter
    end

    # -- inject assets from the adapter by hook-in to [ac]. more at [#003]

    def component_association_reader

      Require_ACS_[]

      my_asc_p = ACS_::Component_Association.  # (b.c we have no custom class)
        reader_of_component_associations_by_method_in self

      -> token_x do

        if @adapter
          asc = @adapter.association_if_associated__ token_x
        end
        if asc
          asc
        else
          my_asc_p[ token_x ]
        end
      end
    end

    def component_operation_reader

      mine = ACS_::Operation::Formal.reader_of_formal_operations_by_method_in self

      -> sym do

        if @adapter
          fo_p = @adapter.read_formal_operation__ sym
        end
        if fo_p
          -> ss do
            _ss_ = Crazy_swap___[ ss, @adapter ]
            fo_p[ _ss_ ]
          end
        else
          mine[ sym ]
        end
      end
    end

    def to_component_node_ticket_streamer

      Require_ACS_[]

      if @adapter

        ACS_::Reflection::Node_Ticket_Streamer.via_ACS @adapter.implementation_
      else

        _rw = ACS_::ReaderWriter.for_componentesque self  # just reads ivar

        _hi = ACS_::Reflection::Node_Ticket_Streamer.via_reader__ _rw  # #todo - change method name

        _hi
      end
    end

    class Temp_Proxy___ < ::Proc
      alias_method :execute, :call
    end

    def component_value_reader

      mine = ACS_::By_Ivars::Value_reader_in[ self ]

      -> asc do
        if @adapter
          kn = @adapter.read_value__ asc
        end
        if kn
          kn
        else
          mine[ asc ]
        end
      end
    end

    def component_value_writer

      mine = ACS_::By_Ivars::Value_writer_in[ self ]

      -> qk do
        if @adapter
          did = @adapter.write_value_if_associated__ qk
        end
        if ! did
          mine[ qk ]
        end
      end
    end

    Crazy_swap___ = -> orig_ss, adapter do

      # so that when the operation expresses its qualified name it uses
      # the particular adapter name and not whatever it would be otherwise

      new_ss = orig_ss.dup

      new_ss[ -2 ] = Simplified_Frame_for_Experiment___.new adapter

      new_ss
    end

    class Simplified_Frame_for_Experiment___

      def initialize ada
        @_ada_wrapper = ada
      end

      def name
        @_ada_wrapper.name
      end

      def ACS
        @_ada_wrapper.implementation_
      end
    end

    # -- let children violate [#ac-002]#DT1 autonomy:

    attr_reader(
      :adapter,
      :kernel_,
    )
  end
end
# #tombstone: (un)serialization
