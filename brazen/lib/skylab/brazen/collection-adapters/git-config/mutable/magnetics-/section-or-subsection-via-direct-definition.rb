module Skylab::Brazen

  module CollectionAdapters::GitConfig

    module Mutable

      class Magnetics_::Section_or_Subsection_via_DirectDefinition < Common_::MagneticBySimpleModel

        # even though we are not parsing lines from an input file, we still
        # have to ensure that names are valid or we'll corrupt the document
        # (more at [#008.C])

        def initialize
          @_mutex_for_etc = nil
          super
        end

        def unsanitized_section_name_string= s
          remove_instance_variable :@_mutex_for_etc
          @_validate_section_name = :_validate_section_name_via_string
          @unsanitized_section_name_string = s
        end

        def unsanitized_section_name_symbol= s
          remove_instance_variable :@_mutex_for_etc
          @_validate_section_name = :__validate_section_name_via_symbol
          @unsanitized_section_name_symbol = s
        end

        attr_writer(
          :listener,
          :unsanitized_subsection_name_string,
        )

        def execute
          ok = send remove_instance_variable :@_validate_section_name
          ok &&= __validate_subsection_name
          ok && __flush
        end

        # -- D

        def __flush

          This_::Models_::MutableSectionOrSubsection.define do |o|

            o.accept_sanitized_name_strings_directly__(
              remove_instance_variable( :@_sanitized_subsection_name_string ),
              remove_instance_variable( :@_sanitized_section_name_string ),
            )
          end
        end

        # -- C

        def __validate_subsection_name
          s = @unsanitized_subsection_name_string
          if s
            if s.include? NEWLINE_
              _listener.call :error, :invalid_subsection_name do
                __build_invalid_subsection_name_event
              end
              UNABLE_
            else
              @_sanitized_subsection_name_string =
                remove_instance_variable(
                  :@unsanitized_subsection_name_string ).freeze
              ACHIEVED_
            end
          else
            remove_instance_variable :@unsanitized_subsection_name_string
            @_sanitized_subsection_name_string = nil
            ACHIEVED_
          end
        end

        def __build_invalid_subsection_name_event

          _ev = Common_::Event.inline_not_OK_with(
            :invalid_subsection_name,
            :invalid_subsection_name, @unsanitized_subsection_name_string,
            :error_category, :argument_error,

          ) do |y, o|

            s = o.invalid_subsection_name
            d = s.index NEWLINE_
            d_ = d - 4

            _excerpt = case 0 <=> d_
            when -1 ; "[..]#{ s[ d_ .. d ] }"
            when  0 ; s[ d_ .. d ]
            when  1 ; s[ 0 .. d ]
            end

            y << "subsection names #{
              }can contain any characters except newline (#{ ick _excerpt })"
          end

          _ev   # hi. #todo
        end

        # -- B

        def __validate_section_name_via_symbol

          # (do the work of converting from symbols with their native
          # conventions to the convetions described in [#028.B])

          sym = @unsanitized_section_name_symbol
          s = sym.id2name
          if s.include? DASH_
            _when_invalid_section_name sym
          else
            s.gsub! UNDERSCORE_, DASH_
            @unsanitized_section_name_string = s
            _validate_section_name_via_string
          end
        end

        def _validate_section_name_via_string

          if RX_SECTION_NAME_ANCHORED___ =~ @unsanitized_section_name_string
            @_sanitized_section_name_string =
              remove_instance_variable :@unsanitized_section_name_string
            ACHIEVED_
          else
            _when_invalid_section_name @unsanitized_section_name_string
          end
        end

        def _when_invalid_section_name name_x
          _listener.call :error, :invalid_section_name do
            __build_invalid_section_name_event name_x
          end
          UNABLE_
        end

        def __build_invalid_section_name_event name_x

          Common_::Event.inline_not_OK_with(
            :invalid_section_name,
            :invalid_section_name, name_x,
            :error_category, :argument_error,
          )
        end

        def _listener
          @listener || LISTENER_THAT_RAISES_ALL_NON_INFO_EMISSIONS_
        end

        RX_SECTION_NAME_ANCHORED___ = /\A#{ RX_SECTION_NAME_.source }\z/

        # ==
        # ==
      end
    end
  end
end
# #history-A: broke out of central "mutable" node (spiritually) during heavy refactor
