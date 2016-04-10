module Skylab::MyTerm

  class Models_::Appearance  # notes (were) in [#003]

    def initialize ke

      @adapter = nil
      @adapters = nil

      @kernel_ = ke
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
            _ss_ = Crazy_swap___[ ss, @adapter.implementation__ ]
            fo_p[ _ss_ ]
          end
        else
          mine[ sym ]
        end
      end
    end

    def to_component_node_ticket_streamer

      if @adapter
        self._WEE
      else

        Require_ACS_[]

        _rw = ACS_::ReaderWriter.for_componentesque self  # just reads ivar

        _hi = ACS_::Reflection::Node_Streamer.via_reader__ _rw  # #todo - change method name

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

    Crazy_swap___ = -> ss, impl do

      _receiver_frame = ss.fetch( -2 )

      _qk = _receiver_frame.qualified_knownness
      _qk_ = _qk.new_with_value impl
      _receiver_frame_ = Simplified_Frame_for_Experiment___.new _qk_

      ss_ = ss.dup
      ss_[ -2 ] = _receiver_frame_
      ss_
    end

    class Simplified_Frame_for_Experiment___

      def initialize qk
        @_qk = qk
      end

      def ACS
        @_qk.value_x
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
