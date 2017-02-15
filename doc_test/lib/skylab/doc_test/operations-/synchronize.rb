module Skylab::DocTest

  class Operations_::Synchronize

      PARAMETERS = Attributes_.call(
        output_adapter: nil,
        asset_line_stream: nil,
        original_test_path: :optional,  # used only for [#010]:C
        original_test_line_stream: :optional,  # separate concern from above
      )
      attr_writer( * PARAMETERS.symbols )

      class << self
        def prototype_for_recurse__ p, output_adapter_sym
          new( & p ).__finish_prototype_for_recurse output_adapter_sym
        end
      end  # >>

    def initialize & p
      @listener = p
        @original_test_line_stream = nil
        @original_test_path = nil
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
      ok = _ok :@_output_adapter_module, __output_adapter_module
      ok && __init_choices_via_output_adapter_module
      ok
    end

    def to_line_stream
      __init_original_line_stream_if_necessary
      # exactly [#035]
      ok = true
      ok &&= __resolve_test_document_via_original_test_line_stream
      ok &&= __resolve_test_document_index_via_test_document
      ok &&= __resolve_asset_nodes_via_asset_line_stream
      ok &&= __resolve_plan_via_asset_nodes_and_test_document_index
      ok &&= __resolve_modified_test_document_via_plan_and_test_document_index
      ok && @__modified_test_document.to_line_stream
    end

    def __resolve_modified_test_document_via_plan_and_test_document_index
      _plan = remove_instance_variable :@__plan
      _tdi = remove_instance_variable :@test_document_index
      _ = Home_::TestDocumentMutationMagnetics_::
          TestDocument_via_Plan_and_TestDocumentIndex.new(
        _plan, _tdi, @choices, & @listener ).execute
      _ok :@__modified_test_document, _
    end

    def __resolve_plan_via_asset_nodes_and_test_document_index
      _st = remove_instance_variable :@__asset_nodes
      _ = Home_::TestDocumentMutationMagnetics_::
          Plan_via_AssetNodes_and_TestDocumentIndex.new(
        _st, @test_document_index, & @listener ).execute
      _ok :@__plan, _
    end

    def __resolve_asset_nodes_via_asset_line_stream
      _tfcp = method :__test_file_context
      _ = remove_instance_variable :@asset_line_stream
      o = Home_::AssetDocumentReadMagnetics_  # (near [#ta-005])
      _bs = o::BlockStream_via_LineStream_and_Single_Line_Comment_Hack[ _ ]
      _ = o::NodeStream_via_BlockStream_and_Choices[ _bs, _tfcp, @choices ]
      _ok :@__asset_nodes, _
    end

    def __test_file_context
      @__TFC ||= __some_test_file_context
    end

    def __some_test_file_context

      path = @original_test_path
      if path
        if Home_.lib_.system.filesystem.path_looks_absolute path
          path = path[ 1..-1 ]   # awful - see #spot-8
        end
        Home_::Models_::TestFileContext.via_path_and_choices__(
          path, @choices )
      else
        Home_::Models_::TestFileContext.default_instance__
      end
    end

    def __resolve_test_document_index_via_test_document

      _test_doc = remove_instance_variable :@__test_document
      _ = Home_::TestDocumentReadMagnetics_::
          TestDocumentIndex_via_Choices_and_TestDocument.
        new( _test_doc, @choices, & @listener ).execute
      _ok :@test_document_index, _
    end

    def __resolve_test_document_via_original_test_line_stream

      io = remove_instance_variable :@original_test_line_stream

      test_doc = @choices.test_document_parser.parse_line_stream io

      if io.respond_to? :close
        io.close
      end

      _ok :@__test_document, test_doc  # probably always fine
    end

    def __init_original_line_stream_if_necessary

      if ! @original_test_line_stream
        @original_test_line_stream = @choices.some_original_test_line_stream
      end
      NIL
    end

    def __init_choices_via_output_adapter_module

        _OAM = remove_instance_variable :@_output_adapter_module
        cx = _OAM.begin_choices
        cx.init_default_choices
        # (etc something or other would go here)
      @choices = cx
      NIL
    end

      _hi = -> y do

            a = Home_.get_output_adapter_slug_array_

            a.map!( & method( :highlight ) )

            y << "available adapter#{ s a }: {#{ a * ' | ' }}. when used in"
            y << "conjunction with help, more options may appear."
      end

    -> do
      cache = {}
      define_method :__output_adapter_module do
        cache.fetch @output_adapter do
          x = __lookup_output_adapter_module
          if x
            cache[ @output_adapter ] = x
          else
            NOTHING_  # #covered
          end
          x
        end
      end
    end.call

    def __lookup_output_adapter_module

      Autoloader_.const_reduce_by do |o|
        o.from_module = Home_::OutputAdapters_
        o.const_path = [ @output_adapter ]
        o.autoloaderize
        o.receive_name_error_by = @listener
      end
    end

    def _ok ivar, x
      if x
        instance_variable_set ivar, x ; ACHIEVED_
      else
        x
      end
    end
  end
end
# #tombstone: lots of old code and compatible comment examples
