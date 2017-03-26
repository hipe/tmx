module Skylab::Cull

  class Models_::Upstream < Model_

    class First_Edit

      def initialize
        @bx = Common_::Box.new
      end

      def derelativizer x
        @bx.add :derelativizer, x
        nil
      end

      def mutable_qualified_knownness_box bx

        @bx.add :upstream, bx[ :upstream ].value_x
        kn = bx[ :upstream_adapter ]
        if kn
          @bx.add :upstream_adapter, ( kn.value_x if kn.is_known_known )
        end

        nil
      end

      def mutable_value_box bx

        @bx.add :upstream, bx.fetch( :upstream )
        @bx.add :upstream_adapter, bx.fetch( :upstream_adapter )
        @bx.add :table_number, bx.fetch( :table_number )

        nil
      end

      def shell sh
        sh.bx.each_pair do | i, x |
          @bx.set i, x
        end
        nil
      end

      attr_reader :bx
    end

    def subsequent_edit_shell
      first_edit_shell
    end

    def first_edit_shell
      First_Edit.new
    end

    def process_first_edit sh
      _process_edit sh
    end

    def process_subsequent_edit sh
      _process_edit sh
    end

    # what is the ultimate outcome of this? it is an adapter.

    def _process_edit sh

      _ = Here_::Adapter_via_ActionArguments___[ sh.bx, & @on_event_selectively ]
      _store :@_adapter, _ and self
    end

  public

    def to_mutable_marshal_box_for_survey sur
      @_adapter.to_mutable_marshal_box_for_survey_ sur
    end

    def to_event
      @_adapter.to_descriptive_event
    end

    def to_entity_stream
      @_adapter.to_entity_stream
    end

    def entity_stream_at_some_table_number d  # assume fixnum
      @_adapter.entity_stream_at_some_table_number d
    end

    def to_entity_stream_stream
      @_adapter.to_entity_stream_stream
    end

    def event_for_fell_short_of_count needed_number, had_number
      @_adapter.event_for_fell_short_of_count needed_number, had_number
    end

    def _store ivar, x  # DEFINITION_FOR_THE_METHOD_CALLED_STORE_
      if x then instance_variable_set ivar, x ; else x end
    end

    # ==

    module Actions
      Autoloader_[ self, :boxxy ]
    end

    module Adapters__
      Autoloader_[ self, :boxxy ]
    end

    # ==

    Here_ = self
  end
end
