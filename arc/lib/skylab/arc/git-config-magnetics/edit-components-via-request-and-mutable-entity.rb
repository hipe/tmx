module Skylab::Arc

  class GitConfigMagnetics::EditComponents_via_Request_and_MutableEntity < Common_::MagneticBySimpleModel

    # -

      # a lot of what happens here is explained in detail at [#024.XXX2].

      def mutable_entity= ent

        @_associations_operator_branch = ent._associations_operator_branch_
        @_models_operator_branch_ = ent._models_operator_branch_
        @mutable_entity = ent
      end

      attr_writer(
        :listener,
        :parameter_value_store,
      )

      def execute
        __init
        if __process_order_INsensitive_parameters
          ok = true
          while __next_pluralton_group
            ok = __process_current_pluralton_group
            ok || break
          end
          ok
        end
      end

      # -- C. pluralton groups

      def __process_current_pluralton_group

        a = @parameter_value_store._simplified_read_ @_current_pluralton_group_symbol
        if a
          __do_process_order_sensitive_parameters a
        else
          ACHIEVED_
        end
      end

      def __do_process_order_sensitive_parameters a

        _against_this_qualified_component_stream Stream_[ a ]

        while _next_set_qualified_component
          __this_must_look_like_a_pluralton_verb
          ok = __do_verb
          ok || break
        end

        ok && ACHIEVED_  # (hide the particular last entity that was added, eg.)
      end

      # ~

      def __do_verb
        _sym = remove_instance_variable :@__verb_symbol
        send METHOD_NAME_VIA_VERB___.fetch _sym
      end

      METHOD_NAME_VIA_VERB___ = {
        add: :__add,
        remove: :__remove,
      }

      def __add

        # along #spot2.1, get from the model suggested by the parameter name
        # to the model module. currently we do this here and not in the
        # remote performer because pluralton associtions are so experimental
        # and we are already assuming a lot..

        _item = @_models_operator_branch_.dereference @_current_MODEL_symbol
        _model_mod = _item.value

        _ent = @mutable_entity.define_and_assign_component_by do |o|

          o.will_be_add

          o.MODEL_MODULE = _model_mod

          o.association_symbol = @_current_pluralton_group_symbol
            # (parameter name EQUALS group name here. (contrast #here1))

          _define_definition_of_new_entity o
        end

        _ent  # hi. #todo on success, the entity that was added
      end

      def __remove
        ::Kernel._OKAY
      end

      def __WAS  # `__when_add`, `__when_remove`

        _el = @survey.touch em[ :stem ].intern
        _ok = _el.send _add_or_remove, @_arg, @parameter_value_store, & @listener
        _ok  # hi. #todo
      end

      # ~

      def __this_must_look_like_a_pluralton_verb

        md = PLURALTON_VERBS_RX___.match @_current_parameter_symbol
        md or fail __say_etc

        @__verb_symbol = %i( add remove ).detect do |sym|
          md.offset( sym ).first  # ocd
        end

        @_current_MODEL_symbol = md[ :stem ].intern  # #here2
        NIL
      end

      def __say_etc
        "this must look like `add_foo_bar` or `remove_foo_bar` - `#{ @_current_parameter_symbol }`"
      end

      PLURALTON_VERBS_RX___ = %r(\A
        (?:
          (?<add> add ) |
          (?<remove> remove ) |
        )
        _
        (?<stem>.+)
      \z)x

      # ~

      def __next_pluralton_group
        send( @_next_pluralton_group ||= :__first_pluralton_group )
      end

      def __first_pluralton_group  # (a longwindeg `each_pair`)

        @_next_pluralton_group = :__next_pluralton_group_normally
        h = @formal_parameters_index.parameters_via_group_symbol
        scn = Scanner_[ h.keys ]

        @_next_pluralton_group_stream = Common_.stream do
          if scn.no_unparsed_exists
            remove_instance_variable :@_current_pluralton_group_symbol
            scn = nil
            STOP_PARSING_
          else
            @_current_pluralton_group_symbol = scn.gets_one
            KEEP_PARSING_
          end
        end
        send @_next_pluralton_group
      end

      def __next_pluralton_group_normally
        @_next_pluralton_group_stream.gets
      end

      # -- B. process order insensitive parameters

      def __process_order_INsensitive_parameters

        ok = true

        _against_those_that_are_set_of_these_parameters @formal_parameters_index.singletons

        while _next_set_qualified_component
          ok = if __looks_like_unset
            __when_unset
          else
            __when_set
          end
          ok || break
        end
        ok
      end

      # --- set a singleton association

      def __when_set

        # ~( whoopie: if the following operation is going to to result in
        # a clobber (replacement) of an existing component, for now we have
        # to sign off on it here. to determine if it's going to be a clobber,
        # we have to know if the component is set already. to know if it's
        # already set, we need a name (function). "EK parameters" (which
        # is what actions deal in) don't speak "name", they just use simple
        # symbols (which is fine). we don't want to create a shortlived name
        # function here when one already exists in the association, so we
        # sort of peek into the associations just to get the name:

        __init_association_via_parameter_symbol

        _yes = @mutable_entity._knows_value_for_association_ @_association

        # ~)

        @mutable_entity.define_and_assign_component_by do |o|

          if _yes
            o.will_be_clobber
          else
            o.will_not_be_clobber
          end

          o.association_symbol = @_current_parameter_symbol
            # (parameter name EQUALS model association here. (contrast #here1))

          _define_definition_of_new_entity o
        end
      end

      # --- unset

      def __when_unset

        @_current_association = @_models_operator_branch_.dereference @_current_MODEL_symbol

        if @mutable_entity._knows_value_for_association_ @_current_association
          __do_unset
        else
          __when_already_not_set
        end
      end

      def __when_already_not_set  # #cov1.4 (has legacy behavior)

        asc_sym = @_current_MODEL_symbol  # (association of entity not action)

        term_sym = :"no_#{ asc_sym }_set"  # `no_upstream_set`..

        @listener.call :error, :expression, term_sym do |y|

          y << "cannot unset #{ humanize asc_sym } - #{ humanize term_sym }"
        end

        UNABLE_
      end

      def __do_unset  # #cov1.5

        asc = @_current_association

        _cfg = @mutable_entity.config_for_write_

        _sects = _cfg.sections

        _sects.dereference_and_unset @_current_MODEL_symbol
        # (result is section - discarded)
        # (we remove the section now but this is (in theory) redundant with
        # #spot1.3, which removes extra sections in a general way. we do it
        # now to be explicit and to make more contact and to future-proof it.)

        ent = @mutable_entity._unset_via_association_ asc  # (result is value - discarded)

        @listener.call :info, :expression, :removed_entity do |y|

          _desc = ent.describe_entity_under_ self
          y << "removed #{ asc.name.as_human } (#{ _desc })"
        end

        ACHIEVED_
      end

      def __looks_like_unset

        md = SINGLETON_VERBS_RX___.match @_current_parameter_symbol
        if md
          @_current_MODEL_symbol = md[ :stem ].intern  # #here2
          ACHIEVED_
        end
      end

      SINGLETON_VERBS_RX___ = %r(\A
        (?:
          (?<unset> unset )
        )
        _
        (?<stem>.+)
      \z)x

      # -- A (support)

      def _define_definition_of_new_entity o

        o.listener = @listener  # (experimental. never for failures only info)

        o.define_entity_by do |oo|

          oo.component_as_primitive_value = @_current_set_qualified_component.value

          oo.primitive_resources = @mutable_entity  # ..

          oo.invocation_resources = @parameter_value_store._invocation_resources_  # meh

          oo.listener = @listener
        end
        NIL
      end

      def __init_association_via_parameter_symbol
        @_association = @_associations_operator_branch.dereference @_current_parameter_symbol
        NIL
      end

      def _next_set_qualified_component

        qc = @_current_set_qualified_component_stream.gets
        if qc
          @_current_parameter_symbol = qc.association.name_symbol
          @_current_set_qualified_component = qc
          true
        else
          @_current_parameter_symbol = nil
          @_current_set_qualified_component = nil
          @_current_set_qualified_component_stream = nil
          remove_instance_variable :@_current_parameter_symbol
          remove_instance_variable :@_current_set_qualified_component
          remove_instance_variable :@_current_set_qualified_component_stream
          false
        end
      end

      def _against_those_that_are_set_of_these_parameters par_a

        pvs = @parameter_value_store

        _qc_st = Stream_[ par_a ].map_reduce_by do |par|
          x = pvs[ par.name_symbol ]
          if x
            Common_::QualifiedKnownKnown.via_value_and_association x, par
          end
        end

        _against_this_qualified_component_stream _qc_st
      end

      def _against_this_qualified_component_stream qc_st

        @_current_set_qualified_component_stream = qc_st

        NIL
      end

      def __init

        _assocs = @mutable_entity._THESE_ASSOCIATIONS_
        @formal_parameters_index = Freaky_cache_thing___.call(
          _assocs,
          @mutable_entity.class,
        )
        NIL
      end

      def _current_association
        @_current_set_qualified_component.association
      end
    # -

    # ==

    Freaky_cache_thing___ = -> do

      cache = {}

      -> parameters, mod do
        x = cache[ mod ]
        if x
          x.parameters_object_id == parameters.object_id || fail
        else
          x = Build_index___[ parameters ]
          cache[ mod ] = x
        end
        x
      end
    end.call

    Build_index___ = -> parameters do

      # a painful about of detail about indexing at [#011.D.6]

      sings = []  # we know there are some

      parameters_via_group_symbol = {}  # we know there are some.

      parameters.each do |par|
        group_sym = par.pluralton_group_symbol
        if group_sym
          ( parameters_via_group_symbol[ group_sym ] ||= [] ).push par
        else
          sings.push par
        end
      end

      MyIndex___.new(
        parameters_via_group_symbol,
        sings,
        parameters.object_id,
      )
    end

    MyIndex___ = ::Struct.new(
      :parameters_via_group_symbol,
      :singletons,
      :parameters_object_id,  # (just used for sanity check)
    )

    # ==

    KEEP_PARSING_ = true
    STOP_PARSING_ = nil

    # ==
    # ==
  end
end
# #history-A.1: rewrote when "singleton"/"pluralton" became the dominant metaphor
