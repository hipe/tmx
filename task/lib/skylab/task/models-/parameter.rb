class Skylab::Task

  module Models_::Parameter

    Parse = -> a do

      # for now, we prefer the universality of [fi] attributes structure
      # but we don't incur it as a dependency until it is needed.
      # the DSL method could have been called multiple times, and at each
      # call it could have been called with a glob of symbols or with a
      # single hash. by merging all of these arguments into one box we
      # a) normalize their shape while b) sanity checking the uniqueness
      # of each name symbol.

      intermediate_box = Common_::Box.new  # catch name collisions

      a.each do |args|

        if 1 == args.length and ! args.fetch( 0 ).respond_to? :id2name
          args.fetch( 0 ).each_pair do |k, x_|
            intermediate_box.add k, x_
          end
        else
          args.each do |sym|
            intermediate_box.add sym, nil
          end
        end
      end

      Home_.lib_.fields::Attributes[ intermediate_box.h_ ]
    end

    class Collection_as_Dependency

      # when de-referencing its sole custodian, this is the result: it
      # represents all the parameters that a particular node requires/
      # honors.

      def initialize sym, attrs, & oes_p
        @_attrs = attrs
        @_name_symbol = sym
        @_oes_p = oes_p
      end

      def accept index, & visit

        # in effect tell the index that we have this one dependency,
        # which is shared throughout the graph..

        visit.call self do

          _one = index.cache_box.touch MAGIC_SYMBOL__ do
            Parameters_Source_Proxy___.new
          end

          Common_::Stream.via_item _one
        end
      end

      def receive_dependency_completion o
        instance_variable_set o.name_for_storing.as_ivar, o.task  # near [#fi-027] store
        NIL_
      end

      # ..then..

      def execute

        # there is only one parameter box to be shared by the whole graph
        # (as there is only one set of parameters provided by the user at
        # the front). but each individual parameter-involved node may have
        # its own set of formal parameters that are required, allowed,
        # **and particular defaultings**.
        #
        # as such we must not write the defaultings back into the original
        # shared parameter value source because for any given formal
        # parameter these defaultings can vary from node to node; i.e, one
        # node might default it to one value while another might another
        # while a third might not default it at all.
        #
        # SO we check if requireds are satisfied first, and then ..

        bx = @_PARAMETERS_.parameter_box  # can be nil

        _n11n = @_attrs.association_index.AS_ASSOCIATION_INDEX_NORMALIZE_BY do |o|

          if bx
            o.box_store = bx
          else
            o.WILL_USE_EMPTY_STORE
          end

          is_req = Home_.lib_.fields::Is_required

          o.is_required_by = -> asc do

            if asc.parameter_arity_is_known
              is_req[ asc ]
            else
              TRUE  # (the default used to be `required` [#fi-002.4])
            end
          end

          o.WILL_CHECK_FOR_MISSING_REQUIREDS_ONLY
          o.WILL_RESULT_IN_SELF_ON_SUCCESS
          o.listener = @_oes_p
        end

        _store :@_normalization, _n11n
      end

      # ..then..

      def visit_dependant_as_completed_ dep, _dep_completion

        # assume the normalization has passed its requireds check. but note
        # we have done nothing to the "session" (the node, the task) yet - it
        # needs to be able to access the requisite parameter values somehow.
        #
        # for now we accomplish this by A) writing values to the session's
        # ivar space, and B) writing something for *every* associated formal
        # parameter (nil when unknown), i.e we "nilify".
        #
        # as a reminder, all formal attributes under this normalization model
        # are either required or effectively "defaultant".
        #
        # SO: for each of the requireds, write the value that is in the box
        # to the session.
        #
        # then, for every of the effectively defaultants, write values as
        # appropriate..

        # (BEGIN near #lends-coverage to [#fi-008.7])

        n11n = remove_instance_variable :@_normalization

        fi = Home_.lib_.fields

        dst = fi::IvarBasedSimplifiedValidValueStore.new dep
        src = n11n.valid_value_store

        ai = n11n.association_source  # association index
        st = ai.to_native_association_stream
        is_req = ai.to_is_required_by
        ai = nil

        st = n11n.association_source.to_native_association_stream
        begin

          asc = st.gets
          asc || break

          if is_req[ asc ]
            # since the source passed the requireds check, the value is not nil
            _xfer = src.dereference_association asc
            dst._write_via_association_ _xfer, asc
            redo
          end

          x = src._read_softly_via_association_ asc
          if x.nil?
            if ! dst._read_softly_via_association_( asc ).nil?
              # if the parameter value store's value is effectively unknown
              # and the destination's value is effectively known, leave the
              # existing value as-is. (don't use default, don't write nil.)
              redo
            end

            # both source and destination are effectively nil so:
            p = asc.default_proc
            if p
              x = p[]
            end
          end
          dst._write_via_association_ x, asc  # write the PVS value or default value or nil
          redo
        end while above

        NIL_
      end

      def _store ivar, x  # DEFINITION_FOR_THE_METHOD_CALLED_STORE_
        if x
          instance_variable_set ivar, x ; true
        else
          x
        end
      end

      def name_symbol
        @_name_symbol
      end

      def synthies_
        NOTHING_
      end
    end

    class Parameters_Source_Proxy___

      # to the one type of node hard-coded to depend it, this node will
      # appear in that node under the magic name _PARAMETERS_, and gives
      # access to whatever parameters (an open-ended set) the user passed.

      def name_symbol
        MAGIC_SYMBOL__
      end

      def accept index, & visit
        visit[ self ]
      end

      def accept_execution_graph__ eg

        @parameter_box = eg.parameter_box
        NIL_
      end

      def execute
        # (it is our immediate downstream that does the work)
        ACHIEVED_
      end

      attr_reader(
        :parameter_box,
      )

      def name_symbol_for_storage_
        MAGIC_SYMBOL__
      end

      def synthies_
        NOTHING_
      end
    end

    MAGIC_SYMBOL__ = :_PARAMETERS_
  end
end
