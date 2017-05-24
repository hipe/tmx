module Skylab::Cull

  class Models_::Survey

    class Here_::Magnetics_::WriteComponent_via_Primitives_and_Survey < Common_::MagneticBySimpleModel

      attr_writer(
        :association_name_symbol,
        :listener,
        :primitive_name_value_stream_recursive,
        :survey,
      )

      def execute

        if __the_stream_is_empty
          self._OMG_FREAKOUT__maybe_use_this_to_remove__
        else
          __procede_normally
        end
      end

      def __procede_normally

        if __the_first_thing_is_the_same_name_as_the_general_thing
          __will_write_the_first_thing_on_the_same_line_as_the_section_line
        else
          __will_not_write_the_first_thing_on_the_same_line_as_the_section_line
        end

        while __next_thing
          if __thing_will_recurse
            self._OMG_FREAKOUT__recurse__
          else
            __will_do_an_assignment_line_out_of_this
          end
        end

        __flush_things  # result is a custom struct
      end

      def __flush_things

        _config = @survey.config_for_write_

        @_sections = _config.sections

        sym = @association_name_symbol
        a = @_sections.to_stream_of_sections.reduce_by do |sect|
          sym == sect.external_normal_name_symbol
        end.to_a

        case a.length <=> 1
        when -1
          __when_no_existing_sections
        when 0
          @_section = a.first
          __when_one_relevant_section
        when 1
          __when_multiple_relevant_sections a
        end
      end

      def __when_multiple_relevant_sections a

        self._COVER_ME__probably_never_hits__readme__

        # this once provided #cov1.6 but that has changed now that (in
        # effect) we validate the document on unmarshal rather than on
        # marshal (seems to make more sense) so the language production
        # that was once here moved to the new referent codepoint. #history-A.2

        UNABLE_
      end

      def __when_one_relevant_section

        s = remove_instance_variable :@_new_sub_section_string
        if s
          # (we won't check if it's changed, for contact)
          _ok = @_section.SET_SUBSECTION_NAME s
          _ok || self._COVER_ME
        end

        _replace_assignments
      end

      def __when_no_existing_sections

        _sect_s = _to_section_name_string

        _s = remove_instance_variable :@_new_sub_section_string

        @_section = @_sections.touch_section _s, _sect_s

        _replace_assignments
      end

      def _replace_assignments

        _a = remove_instance_variable :@_these
        _st = Stream_[ _a ]
        _ok = @_section.assignments.REPLACE_ASSIGNMENTS _st, & @listener
        _ok  # hi. #todo
      end

      def _to_section_name_string
        @association_name_symbol.id2name.gsub UNDERSCORE_, DASH_
      end

      # --

      def __will_do_an_assignment_line_out_of_this

        # `OMNI_TYPE_CLASSIFICATION_HOOK_MESH_PROTOTYPE`
        @_these.push remove_instance_variable :@_current ; nil
      end

      def __thing_will_recurse
        @_current.value.respond_to? :gets
      end

      # --

      def __will_write_the_first_thing_on_the_same_line_as_the_section_line

        s = @_current.value
        if ! s.respond_to? :ascii_only?
          self._COVER_ME__not_string__
        end
        @_new_sub_section_string = s
        remove_instance_variable :@_current
        @_next_thing = :_next_thing_normally ; nil
      end

      def __will_not_write_the_first_thing_on_the_same_line_as_the_section_line
        self._CODE_SKETCH
        @_new_sub_section_string = nil
        @_next_thing = :__use_current_thing_once
      end

      # --

      def __next_thing
        send @_next_thing
      end

      def __use_current_thing_once
        @_next_thing = :_next_thing_normally ; true
      end

      def __the_first_thing_is_the_same_name_as_the_general_thing
        @_these = []  # snuck
        @association_name_symbol == @_current.name_symbol
      end

      def __the_stream_is_empty
        ! _next_thing_normally
      end

      def _next_thing_normally
        qk = @primitive_name_value_stream_recursive.gets
        if qk
          @_current = qk ; true
        else
          @_current = nil
          remove_instance_variable :@_current
          remove_instance_variable :@primitive_name_value_stream_recursive
          remove_instance_variable :@_next_thing
          false
        end
      end
    end
  end
end
# :#history-A.2 (can be temporary) (as referenced)
# #history-A.1: abstracted from two methods in main survey file #spot1.2
