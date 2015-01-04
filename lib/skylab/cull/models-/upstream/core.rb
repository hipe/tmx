module Skylab::Cull

  class Models_::Upstream < Model_

    class First_Edit

      def initialize
        @bx = Callback_::Box.new
      end

      def mutable_arg_box bx

        @bx.add :upstream, bx[ :upstream ].value_x

        @bx.add :upstream_adapter, bx[ :upstream_adapter ].value_x

        nil
      end

      def reference_path x
        @bx.set :reference_path, x
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

      x = Upstream_::Actors__::Produce_adapter[
        sh.bx,
        & @on_event_selectively ]

      x and begin
        @_adapter = x
        self
      end
    end

  public

    def marshal_dump_for_survey sur
      @_adapter.marshal_dump_for_survey_ sur
    end

    def to_event
      @_adapter.to_descriptive_event
    end

    def to_entity_collection_stream
      @_adapter.to_entity_collection_stream
    end

    def event_for_fell_short_of_count needed_number, had_number
      @_adapter.event_for_fell_short_of_count needed_number, had_number
    end


    FILE_FTYPE_ = 'file'

    Upstream_ = self

  end
end
