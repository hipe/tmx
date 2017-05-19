module Skylab::Cull

  class Models_::Survey

    class Magnetics_::EditEntities_via_Request_and_Survey < Common_::MagneticBySimpleModel

      attr_writer(
        :listener,
        :parameter_value_store,
        :survey,
      )

      def execute
        ok = true
        while __next_relevant_provided_argument
          ok = if __looks_verby
            __when_verby
          elsif __has_model
            __when_model
          else
            self._COVER_ME__wat__
          end
          ok || break
        end
        ok
      end

      def __looks_verby

        md = RX___.match @_arg.name_symbol
        if md
          @__matchdata = md
          ACHIEVED_
        end
      end

      def __when_verby

        md = remove_instance_variable :@__matchdata

        _add_or_remove = md[ :add ] ? :add : :remove

        _el = @survey.touch em[ :stem ].intern
        _ok = _el.send _add_or_remove, @_arg, @parameter_value_store, & @listener
        _ok  # hi. #todo
      end

      def __has_model

        Models__.boxxy_module_as_operator_branch.has_reference @_arg.name_symbol
      end

      def __when_model

        @survey.define_and_assign_component__ @_arg.name_symbol do |o|

          o.component_as_primitive_value = @_arg.value

          o.primitive_resources = @survey

          o.invocation_resources = @parameter_value_store._invocation_resources_  # meh

          o.listener = @listener
        end
      end

      RX___ = /\A(?:(?<add>add_)|(?<remove>remove_))(?<stem>.+)/

      # -- B.

      def __next_relevant_provided_argument
        send( @_next ||= :__next_etc_initially )
      end

      def __next_etc_initially

        pvs = @parameter_value_store
        st = Stream_[ Common_associations_[] ].map_reduce_by do |asc|
          x = pvs[ asc.name_symbol ]
          if x
            Common_::QualifiedKnownKnown.via_value_and_association x, asc
          end
        end

        @__proc_for_next = -> do
          qk = st.gets
          if qk
            @_arg = qk ; ACHIEVED_
          end
        end

        send( @_next = :__next_etc_normally )
      end

      def __next_etc_normally
        @__proc_for_next.call
      end

      # ==

      Stream_ = -> a, & p do
        Common_::Stream.via_nonsparse_array a, & p
      end

      # ==
      # ==
    end
  end
end
