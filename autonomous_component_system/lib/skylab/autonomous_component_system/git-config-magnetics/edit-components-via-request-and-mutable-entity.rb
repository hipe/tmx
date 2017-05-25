module Skylab::Cull

  class Models_::Survey

    class Magnetics_::EditEntities_via_Request_and_Survey < Common_::MagneticBySimpleModel

      # (this has potential to be generalized and moved up as a general entity mutator)

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

          @__verb_symbol = %i( add remove unset ).detect do |sym|
            md.offset( sym ).first  # ocd
          end

          @_association_symbol = md[ :stem ].intern

          ACHIEVED_
        end
      end

      RX___ = %r(\A
        (?:
          (?<add> add ) |
          (?<remove> remove ) |
          (?<unset> unset )
        )
        _
        (?<stem>.+)
      \z)x

      def __when_verby
        case remove_instance_variable :@__verb_symbol
        when :add ; __when_add
        when :remove ; __when_remove
        when :unset ; __when_unset
        else no end
      end

      def __WAS  # `__when_add`, `__when_remove`

        _el = @survey.touch em[ :stem ].intern
        _ok = _el.send _add_or_remove, @_arg, @parameter_value_store, & @listener
        _ok  # hi. #todo
      end

      def __when_unset

        asc = Common_::Name.via_lowercase_with_underscores_symbol @_association_symbol
        if @survey._knows_value_for_association_ asc
          __do_unset asc
        else
          __when_already_not_set
        end
      end

      def __when_already_not_set  # #cov1.4 (has legacy behavior)

        term_sym = :"no_#{ @_association_symbol }_set"  # `no_upstream_set`..
        @listener.call :error, term_sym do
          __build_event_for_cannot_unset_because_no_component term_sym
        end
        UNABLE_
      end

      def __build_event_for_cannot_unset_because_no_component term_sym

        asc_sym = @_association_symbol
        Build_not_OK_event_.call term_sym do |y, o|
          y << "cannot unset #{ humanize asc_sym } - #{ humanize term_sym }"
        end
      end

      def __do_unset asc  # #cov1.5

        _cfg = @survey.config_for_write_

        _sects = _cfg.sections

        _sects.dereference_and_unset @_association_symbol
        # (result is section - discarded)
        # (we remove the section now but this is (in theory) redundant with
        # #spot1.3, which removes extra sections in a general way. we do it
        # now to be explicit and to make more contact and to future-proof it.)

        ent = @survey._unset_via_association_ asc  # (result is value - discarded)

        @listener.call :info, :expression, :removed_entity do |y|

          _desc = ent.describe_entity_under_ self
          y << "removed #{ asc.name.as_human } (#{ _desc })"
        end

        ACHIEVED_
      end

      # --

      def __has_model

        Models__.boxxy_module_as_operator_branch.has_reference @_arg.name_symbol
      end

      def __when_model

        ent = @survey

        # ~( whoopie: if the following operation is going to to result in
        # a clobber (replacement) of an existing component, for now we have
        # to sign off on it here. to determine if it's going to be a clobber,
        # we have to know if the component is set already. to know if it's
        # already set, we need a name (function). "EK parameters" (which
        # is what actions deal in) don't speak "name", they just use simple
        # symbols (which is fine). we don't want to create a shortlived name
        # function here when one already exists in the association, so we
        # sort of peek into the associations just to get the name:

        asc_sym = @_arg.association.name_symbol

        _item = @survey._associations_operator_branch_.dereference asc_sym

        _yes = ent._knows_value_for_association_ _item

        # ~)

        ent.define_and_assign_component_by__ do |o|

          if _yes
            o.will_be_clobber
          else
            o.will_not_be_clobber
          end

          o.association_symbol = asc_sym

          o.define_entity_by do |oo|

            oo.component_as_primitive_value = @_arg.value

            oo.primitive_resources = ent

            oo.invocation_resources = @parameter_value_store._invocation_resources_  # meh

            oo.listener = @listener
          end
        end
      end

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
