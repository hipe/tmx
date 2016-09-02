module Skylab::DocTest

    class Operations_::Synchronize

      PARAMETERS = Attributes_.call(
        output_adapter: nil,
        asset_line_stream: nil,
        original_test_line_stream: :optional,
      )
      attr_writer( * PARAMETERS.symbols )

      class << self
        def prototype_for_recurse__ p, output_adapter_sym
          new( & p ).__finish_prototype_for_recurse output_adapter_sym
        end
      end  # >>

      def initialize & p
        @on_event_selectively = p
        @original_test_line_stream = nil
      end

      def __finish_prototype_for_recurse sym
        self.output_adapter = sym
        _ok = _prepare_common
        _ok && freeze
      end

      def execute
        ok = _prepare_common
        ok &&= to_line_stream
      end

      def _prepare_common
        ok = __resolve_output_adapter_module
        ok && __init_choices
        ok
      end

      def to_line_stream
        ok = true
        ok && __init_original_line_stream_if_necessary
        ok && __synthesize_result_line_stream
      end

      def __synthesize_result_line_stream

        o = Magnetics_::TestDoc_via_NodeStream_and_TestDoc_and_Choices::Session.begin

        o.asset_line_stream = @asset_line_stream
        o.choices = @_choices
        o.original_test_line_stream = @original_test_line_stream

        _document = o.to_test_document
        _document.to_line_stream
      end

      def __init_original_line_stream_if_necessary

        if ! @original_test_line_stream
          @original_test_line_stream = @_choices.some_original_test_line_stream
        end
        NIL_
      end

      def __init_choices

        _OAM = remove_instance_variable :@_output_adapter_module
        cx = _OAM.begin_choices
        cx.init_default_choices
        # (etc something or other would go here)
        @_choices = cx
        NIL_
      end

      _hi = -> y do

            a = Home_.get_output_adapter_slug_array_

            a.map!( & method( :highlight ) )

            y << "available adapter#{ s a }: {#{ a * ' | ' }}. when used in"
            y << "conjunction with help, more options may appear."
      end

        def __resolve_output_adapter_module

          mod = Autoloader_.const_reduce(
            [ @output_adapter ],  # nil ok
            Home_::OutputAdapters_,
            & @on_event_selectively )

          if mod
            @_output_adapter_module = mod
            ACHIEVED_
          else
            mod
          end
        end
    end
end
# #tombstone: lots of old code and compatible comment examples
