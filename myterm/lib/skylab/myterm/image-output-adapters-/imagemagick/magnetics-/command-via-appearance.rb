module Skylab::MyTerm

  class Image_Output_Adapters_::Imagemagick

    class Imagemagick_Command_via_Appearance___

      def initialize & p
        @_oes_p = p
      end

      attr_writer(
        :appearance,
        :image_output_path,
      )

      def execute

        @_a = [ 'convert' ]
        ok = __populate_options_recursively
        ok &&= __add_label
        ok &&= __add_output_file
        ok && __finish
      end

      def __populate_options_recursively

        @_special = {
          label: :__special_handling_for_label,
        }

        _ACS = remove_instance_variable :@appearance

        _recurse_into _ACS
      end

      def __special_handling_for_label qk

        @_label_qk = qk
        ACHIEVED_
      end

      def _recurse_into acs

        st = ___qkn_stream_via acs

        ok = ACHIEVED_
        begin

          qk = st.gets
          qk or break

          if ! qk.is_effectively_known
            redo
          end

          m = @_special.delete qk.name_symbol

          if m
            ok = send m, qk
          else
            _ = qk.association.model_classifications.category_symbol
            ok = send :"__add__#{ _ }__", qk
          end

          ok or break
          redo
        end while nil
        ok
      end

      def ___qkn_stream_via acs

        _rw = ACS_::ReaderWriter.for_componentesque acs  # meh

        _o = _rw.to_non_operation_node_ticket_streamer

        _st = _o.execute

        _st.map_by do |no|
          no.to_qualified_knownness
        end
      end

      def __add__compound__ qk

        _recurse_into qk.value_x
      end

      def __add__entitesque__ qk  # assume effectively known

        _x = qk.value_x.to_primitive_for_component_serialization
        _add_prepared_value _x, qk
      end

      def __add__primitivesque__ qk  # assume effectively known

        x = qk.value_x
        if ACS_::Reflection::Looks_primitive[ x ]
          _add_prepared_value x, qk
        else
          self._COVER_ME_primitive_not_primitive
        end
      end

      def _add_prepared_value x, qk

        _s = qk.association.get_internal_name_string__

        @_a.push "-#{ _s }"  # ..
        @_a.push "#{ x }"  # hypothetically there is no need to escape here

        ACHIEVED_
      end

      def __add_label

        _qk = remove_instance_variable :@_label_qk
        s = _qk.value_x
        s or self._SANITY  # because normalization, assumed
        @_a.push "label:#{ s }"  # works without escaping because how we call it
        ACHIEVED_
      end

      def __add_output_file
        s = @image_output_path
        if s
          @_a.push s
          ACHIEVED_
        else
          s
        end
      end

      def __finish

        remove_instance_variable :@_oes_p
        remove_instance_variable :@_special

        path = remove_instance_variable :@image_output_path
        s_a = remove_instance_variable :@_a

        instance_variables.length.nonzero? and self._FORGOT_THESE

        @image_path = path.freeze
        @string_array = s_a.freeze

        freeze
      end

      # --

      def send_into_system_conduit_ sycond, & oes_p

        _, o, e, w = sycond.popen3( * @string_array )

        s = e.gets
        if s
          ___when_one_error_line s, w, & oes_p
        else
          __when_no_error_lines o, w
        end
      end

      def ___when_one_error_line s, w, & oes_p

        # (might block if you try to read more now)

        oes_p.call :error, :expression, :system_call_failed do |y|
          y << s
        end

        if w.alive?
          w.exit
        end

        UNABLE_
      end

      def __when_no_error_lines o, w

        x = o.gets
        x and self._COVER_ME  # utility is quiet

        d = w.value.exitstatus
        if d.zero?
          ACHIEVED_
        else
          self._COVER_ME
        end
      end

      def express_into_under y, _expag
        y << thru_shellescape_
      end

      def thru_shellescape_
        _p = Home_.lib_.shellwords.method :shellescape
        @string_array.map( & _p ).join SPACE_
      end

      attr_reader(
        :image_path,
        :string_array,
      )

      SPACE_ = ' '
    end
  end
end
