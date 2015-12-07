module Skylab::MyTerm

  class Image_Output_Adapters_::Imagemagick

    class Build_command_

      def initialize & p
        @_oes_p = p
      end

      attr_writer(
        :image_output_path,
        :snapshot,
      )

      def execute

        @_a = [ 'convert' ]
        ok = __add_options
        ok &&= __add_label
        ok &&= __add_output_file
        ok && __finish
      end

      def __add_options

        bx = remove_instance_variable :@snapshot

        @_label_qkn = bx.remove :label do  # special handling syntactically
          NIL_
        end

        ok = true
        st = bx.to_value_stream
        begin
          qkn = st.gets
          qkn or break
          if ! qkn.is_effectively_known
            redo
          end
          _ = qkn.association.model_classifications.category_symbol
          ok = send :"__add__#{ _ }__", qkn
          ok or break
          redo
        end while nil

        bx.a_.clear ; bx.h_.clear  # for sanity, consume all of the snapshot

        ok
      end

      def __add__entitesque__ qkn  # assume effectively known

        _x = qkn.value_x.to_primitive_for_component_serialization

        _add_prepared_value _x, qkn
      end

      def __add__primitivesque__ qkn  # assume effectively known

        x = qkn.value_x
        if ACS_[]::Interpretation::Looks_primitive[ x ]
          _add_prepared_value x, qkn
        else
          self._COVER_ME_primitive_not_primitive
        end
      end

      def _add_prepared_value x, qkn

        _s = qkn.association.get_internal_name_string__

        @_a.push "-#{ _s }"  # ..
        @_a.push "#{ x }"  # hypothetically there is no need to escape here

        ACHIEVED_
      end

      def __add_label

        qkn = remove_instance_variable :@_label_qkn
        s = ( qkn.value_x if qkn.is_known_known )
        if s
          @_a.push "label:#{ s }"  # works without escaping because how we call it
          ACHIEVED_
        else
          x
        end
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
        path = remove_instance_variable :@image_output_path
        s_a = remove_instance_variable :@_a

        instance_variables.length.nonzero? and self._FORGOT_THESE

        @image_path = path.freeze
        @string_array = s_a.freeze

        freeze
      end

      attr_reader(
        :image_path,
        :string_array,
      )
    end
  end
end
