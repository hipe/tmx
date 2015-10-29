module Skylab::TMX

  class Models_::Reactive_Model_Dispatcher

    def initialize & oes_p
      @on_event_selectively = oes_p
    end

    # ~ modality adaptation

    def to_kernel_adapter

      As_Kernel___.new self
    end

    # ~ direct call & support

    def call * x_a, & oes_p

      otr = dup
      otr.__receive_call x_a, & oes_p
      bc = otr.__execute
      if bc
        bc.receiver.send bc.method_name, * bc.args, & bc.block
      else
        bc
      end
    end

  protected

    def __receive_call x_a, & oes_p

      @_in_st = Callback_::Polymorphic_Stream.via_array x_a
      if oes_p
        @on_event_selectively = oes_p
      end
      NIL_
    end

    def __execute

      if @_in_st.no_unparsed_exists
        __when_no_arguments
      else
        __when_some_arguments
      end
    end

  public  # (methods named with bounding underscores are effectively private)

    def __when_no_arguments

      _emit :error, :missing_required_properties, :missing_first_argument do
        _build_event :Missing_First_Argument
      end
    end

    def __when_some_arguments

      @first_argument = @_in_st.gets_one

      @unbound = @fast_lookup[ @first_argument ]

      if @unbound

        __when_unbound

      else

        _emit :error, :no_such_reactive_node do
          _build_event :No_Such_Reactive_Node
        end
      end
    end

    attr_reader :first_argument

    attr_accessor(
      :fast_lookup,
      :unbound_stream_builder,
    )

    def __when_unbound

      if @unbound.respond_to? :module_exec  # for now

        @unbound::API.application_kernel_.bound_call_via_polymorphic_stream(
          remove_instance_variable( :@_in_st ),
          & @on_event_selectively )
      else
        self._COVER_ME
      end
    end

    # ~ support

    def _emit * i_a, & ev_p

      @on_event_selectively.call( * i_a, & ev_p )
    end

    def _build_event sym

      Me_::Events_.const_get( sym, false )[ self ]
    end

    class As_Kernel___

      def initialize front
        @_client = front
      end

      def fast_lookup
        @_client.fast_lookup
      end

      def build_unordered_selection_stream & x_p
        @_client.unbound_stream_builder.call( & x_p )
      end

      def module
        :__no_module__
      end

      def source_for_unbounds
        self._ONLY_for_respond_to
      end
    end

    Me_ = self
  end
end
