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

        _HACKY_EXPERIMENT = nil

        bx = @_PARAMETERS_.parameter_box  # can be nil

        ok = @_attrs.AS_ATTRIBUTES_NORMALIZE_BY do |o|

          _HACKY_EXPERIMENT = o

          if bx
            o.box_store = bx
          else
            o.WILL_USE_EMPTY_STORE
          end

          o.WILL_CHECK_FOR_MISSING_REQUIREDS_ONLY
          o.listener = @_oes_p
        end

        ok and @_normalization = _HACKY_EXPERIMENT
        ok
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

        o = remove_instance_variable :@_normalization

        ws = Home_.lib_.fields::IvarBasedValueStore.new dep  # "write store" (i think)
        rs = o.value_store  # "read store" (i think)

        df_a = o.non_required_name_symbols
        req_a = o.required_name_symbols

        lu = o.read_association_by  # lookup
        o = nil  # (END)

        if req_a
          req_a.each do |k|
            atr = lu[ k ]
            _x = rs.dereference atr  # you know it's known
            ws.write_via_association _x, atr
          end
        end

        if df_a
          df_a.each do |k|
            atr = lu[ k ]

            if rs.knows atr
              x = rs.dereference atr
            end

            if x.nil?

              if ws.knows( atr ) && ! ws.dereference( atr ).nil?
                # if the value from the parameter value store is effectively
                # unknown and the session has an effectively known value,
                # don't write a default and don't write nil. skip.
                next
              end

              p = atr.default_proc
              if p
                x = p[]
              end
            end

            ws.write_via_association x, atr  # is the PVS value or a default value or nil
          end
        end

        NIL_
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
