module Skylab::Brazen

  class Models_::Workspace

    class Magnetics::ProcureComponent_via_ComponentPath < Common_::MagneticBySimpleModel

      def initialize
        @_resolve_final_etc = :__resolve_final_value_as_is
        super
      end

      def assigment sym, sym_
        @assignment_name_symbol = sym
        @section_symbol = sym_ ; nil
      end

      def will_be_asset_path
        @_resolve_final_etc = :__resolve_final_value_via_assignment_value_when_its_an_asset_path
      end

      def would_invite_by & p
        @_invite_by = p
      end

      attr_writer(
        :listener,
        :workspace,
      )

      def execute
        ok = true
        ok &&= __resolve_section
        ok &&= __resolve_assignment
        ok &&= __resolve_final_value_via_assignment_value
        ok && remove_instance_variable( :@_final_value )
      end

      def __resolve_final_value_via_assignment_value
        send remove_instance_variable :@_resolve_final_etc
      end

      def __resolve_final_value_via_assignment_value_when_its_an_asset_path

        path = remove_instance_variable :@_assignment_value
        if Home_.lib_.system.filesystem.path_looks_relative path
          dir = @workspace.asset_directory @listener
          if dir
            @_final_value = ::File.join dir, path ; true
          end
        else
          path
        end
      end

      def __resolve_final_value_as_is
        @_final_value = remove_instance_variable :@_assignment_value ; true
      end

      def __resolve_assignment

        _sect = remove_instance_variable :@__section
        _asmts = _sect.assignments
        x = _asmts.lookup_softly @assignment_name_symbol
        if x
          @_assignment_value = x ; true
        else
          __when_assignment_not_found
        end
      end

      def __resolve_section
        _sects = _document.sections
        sect = _sects.lookup_softly @section_symbol
        if sect
          @__section = sect ; true
        else
          __when_section_not_found
        end
      end

      # -- events

      def __when_section_not_found
        @_component_name_symbol = :@section_symbol
        @_reason_symbol = :section_not_found
        _when_not_found
      end

      def __when_assignment_not_found
        @_component_name_symbol = :@assignment_name_symbol
        @_reason_symbol = :assignment_not_found
        _when_not_found
      end

      def _when_not_found

        @listener.call :error, :config_component_not_found do
          __flush_build_event
        end
        UNABLE_
      end

      def __flush_build_event

        _sym = instance_variable_get remove_instance_variable :@_component_name_symbol
        _sym_a = remove_instance_variable( :@_invite_by ).call
        sect_sym = @section_symbol

        _ev = Common_::Event.inline_not_OK_with(
          :config_component_not_found,
          :component_name_symbol, _sym,
          :reason_symbol, remove_instance_variable( :@_reason_symbol ),
          :document_byte_upstream_reference, _document.document_byte_upstream_reference,
          :invite_to_action, _sym_a,
        ) do |y, o|

          sect_s = sect_sym.id2name.gsub( UNDERSCORE_, DASH_ ).inspect

          case o.reason_symbol
          when :assignment_not_found
            _ = o.component_name_symbol.id2name.gsub( UNDERSCORE_, DASH_ ).inspect
            buffer = "#{ _ } assignment not found in #{ sect_s } section"
          when :section_not_found
            buffer = "section #{ sect_s } not found"
          end

          ref = o.document_byte_upstream_reference
          if ref
            if ref.respond_to? :path
              path = ref.path
            end
          end

          if path
            buffer << " in #{ pth path }"
          else
            buffer << " in config"
          end

          y << buffer
        end
        _ev  # hi. #todo
      end

      # -- support

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      def _document
        @workspace.immutable_document
      end

      # ==
      # ==
    end
  end
end
# #history-A: abstracted from somewhere in [tm]
