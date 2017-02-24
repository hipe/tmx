module Skylab::Autonomous_Component_System

  module Operation

    class NormalRepresentation_for_ACS___ < Normal_Representation_

      def initialize obj_p, fo

        @_ACS_proc = obj_p
        @_has_own_default_proc = false
        @_did = false
        @formal_ = fo
      end

      def desc_proc_

        # (we don't want to ask the autonamaton because its methodspace
        # should be for associations only. but maybe ..

        p = @formal_.description_proc

        if ! p
          @_did || _do
          if @_ACS.class.respond_to? :describe_into_under  # eew
            cls = @_ACS.class
            p = -> y do
              cls.describe_into_under y, self
            end
          end
        end
        p
      end

      def to_defined_formal_parameter_stream_to_be_cached_

        @_did || _do

        nt_st = @_reader.to_non_operation_node_reference_stream

        bx = @formal_.parameter_box
        h = if bx
          bx.h_
        else
          MONADIC_EMPTINESS_
        end

        Common_.stream do
          nt = nt_st.gets
          if nt
            Association_as_Parameter___.new h[ nt.name_symbol ], nt
          end
        end
      end

      def begin_parameter_store_ & call_handler
        @_did || _do
        Store___.new @_ACS, & call_handler
      end

      def _do
        @_did = true
        @_ACS = remove_instance_variable( :@_ACS_proc ).call
        @_reader = Home_::ReaderWriter.for_componentesque @_ACS
        NIL_
      end

      def __reader_writer
        @_reader
      end

      # ==

      class Preparation < Preparation_

        def to_bound_call

          ok = check_availability_
          ok &&= normalize_
          ok &&= ___second_normalize
          ok && Common_::BoundCall[ NOTHING_, @__ACS, :execute, & @call_handler_ ]
        end

        def ___second_normalize

          # now that we've verified things like required parameters,
          # we leverage the FULL POWER of the ACS to etc

          rw = @nr_.__reader_writer
          acs = rw.ACS
          @__ACS = acs  # for later

          store = @parameter_store.real_store_
          bx = store._bx

          p = store._call_handler  # early for sanity
          pp = -> _ do
            p
          end

          ok = true
          st = bx.to_value_stream
          begin
            pair = st.gets
            pair || break

            _asc = pair.name_x._defined_association

            _st = Field_::Argument_stream_via_value[ pair.value_x ]  # MODALITY user value

            ok = ACS_::Interpretation::Build_value.call _st, _asc, acs, & pp
            ok || break  # qk
            rw.write_value ok

            redo
          end while nil

          ok
        end
      end

      # ==

      class Store___

        def initialize acs, & call_handler
          @_bx = Common_::Box.new
          @_call_handler = call_handler
          @ACS = acs
        end

        def accept_parameter_value x, par
          @_bx.add par.name_symbol, Common_::Pair.via_value_and_name( x, par )
          NIL_
        end

        def evaluation_proc
          method :evaluation_of
        end

        def evaluation_of par
          pair = @_bx[ par.name_symbol ]
          if pair
            Common_::Known_Known[ pair.value_x ]
          else
            Common_::KNOWN_UNKNOWN
          end
        end

        attr_reader(
          :_bx,
          :_call_handler,
        )
      end

      # ==

      class Association_as_Parameter___

        def initialize fopa, nt
          :association == nt.node_reference_category || Home_._EEK
          @_has_own_default_proc = false
          @_node_reference = nt
          @name = nt.name
          @name_symbol = nt.name_symbol

          if fopa
            @_fopa = fopa
            @_has = true
            @argument_arity = fopa.argument_arity
            @parameter_arity = fopa.parameter_arity
          else
            @_has = false
            @argument_arity = :one

            # this is all VERY experimental - generally (and unlike elsewhere)
            # we want the default parameter arity to end up as "required".
            # if you want to tamp this down you have to do it explicitly
            # (for now in the higher-level definition space, not the lower)

            sym = nt.association.singplur_category
            @parameter_arity = if sym
              # tricky - what we don't want is the plural counterpart of a
              # singplur pair to be reported as required (to any client?)
              THESE___.fetch sym
            else
              :one  # .. (if we were truly autonomous we would recurse)
            end
          end
        end

        THESE___ = {
          plural_of: :zero_or_one,
          singular_of: :one,
        }

        def prepend_normalization_by & p
          nt = @_node_reference
          _asc_ = nt.association.prepend_normalization__ p
          _nt_ = nt.new_with_association__ _asc_
          otr = dup
          otr.instance_variable_set :@_node_reference, _nt_
          otr
        end

        # --

        def dup_by  # [ze]
          otr = dup
          yield otr
          otr
        end

        attr_writer(  # only for above
          :argument_arity,
          :parameter_arity,
        )

        # --

        def description_proc  # wild ride..

          if @_has
            p = @_fopa.description_proc
          end

          p_ = _defined_association.description_proc

          if p
            if p_
              -> y do
                instance_exec y, & p_  # more general first
                instance_exec y, & p  # more specific second
              end
            else
              p
            end
          else
            p_
          end
        end

        def argument_argument_moniker
          if @_has
            @_fopa.argument_argument_moniker
          end
        end

        def be_provisioned__
          @is_provisioned = true ; nil
        end

        def default_proc= p
          @_has_own_default_proc = true
          @__default_proc = p
        end

        def default_proc
          if @_has_own_default_proc
            @__default_proc
          elsif @_has
            @_fopa.default_proc
          end
        end

        # --

        # see #note-1 and #note-2 in [#026]

        def singplur_category_of_association
          _defined_association.singplur_category
        end

        def _defined_association
          @_node_reference.association
        end

        attr_reader(
          :argument_arity,
          :is_provisioned,
          :name,
          :name_symbol,
          :parameter_arity,
        )
      end

      # ==

    end
  end
end
# #history: born.
