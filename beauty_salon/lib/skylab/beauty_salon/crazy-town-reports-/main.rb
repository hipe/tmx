module Skylab::BeautySalon

  class CrazyTownReports_::Main < Common_::MagneticBySimpleModel

    # -

      # this is the "glue" magnetic. stay close to the [#025] algorithm

      def self.describe_into_under y, expag
        y << 'the main thing. result is a stream of lines of a patch'
        y << 'created by having applied the changes to each file as'
        y << 'suggesed by the replacement function against the occurrences'
        y << 'of the pattern seletected by the code selector'
      end

      def initialize
        super
      end

      attr_writer(
        :code_selector,
        :file_path_upstream_resources,
        :listener,
        :replacement_function,
      )

      def execute
        if __resolve_dynamic_hook_definition
          __flush_definition
        end
      end

      def __flush_definition

        _dhd = remove_instance_variable :@__dynamic_hook_definition

        _rsx = remove_instance_variable :@file_path_upstream_resources
        _rsx.line_stream_via_file_chunked_functional_definition do |y, oo|

          oo.define_document_processor :_main_ do |o|

            _dhd.flush_definition__ y, o  # hi.
          end

          oo.on_each_file_path do |path, o|
            o.execute_document_processor :_main_
          end
        end
      end

      def __resolve_dynamic_hook_definition

        _ = Home_::CrazyTownMagneticsForMainReport_::ChangedFile_via_HooksDefinition_via_Functions_and_Selector.call_by do |o|

          o.receive_changed_file = method :__receive_changed_file

          o.replacement_function = remove_instance_variable :@replacement_function
          o.code_selector = remove_instance_variable :@code_selector
          o.listener = @listener
        end

        _store :@__dynamic_hook_definition, _
      end

      def __receive_changed_file y, io, sb

        _ = Home_::CrazyTownMagneticsForMainReport_::DiffLineStream_via_ChangedFile.call_by do |o|
          o.line_yielder = y
          o.changed_file_IO = io
          o.source_buffer = sb
          o.listener = @listener
        end

        _  # hi #todo
      end

      # -- A.

      define_method :_exception, DEFINITION_FOR_THE_METHOD_CALLED_EXCEPTION_

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

    # -


    # ==
    # ==
  end
end
# #born.
