module Skylab::Autonomous_Component_System
  # ->
    module Modalities::JSON

      class Interpret  # notes in [#003]:on-JSON-interpretation

        def initialize & p

          @_caller_oes_p = p
          @context_linked_list = nil
          @on_empty_JSON_object = nil
        end

        def prepend_more_specific_context_by & desc_p

          _ = Home_.lib_.basic::List::Linked[ @context_linked_list, desc_p ]
          @context_linked_list = _
          NIL_
        end

        attr_writer(
          :ACS,
          :context_linked_list,
          :customization_structure_x,
          :on_empty_JSON_object,
          :JSON,
        )

        def execute

          _rw = Home_::ReaderWriter.for_componentesque(
            remove_instance_variable( :@ACS ) )

          _x = Home_.lib_.JSON.parse(
            remove_instance_variable( :@JSON ),
            symbolize_names: true,
          )

          _rec = Stack_Frame__.new(
            _x,
            remove_instance_variable( :@context_linked_list ),
            remove_instance_variable( :@customization_structure_x ),
            _rw,
            @on_empty_JSON_object,
            & @_caller_oes_p )

          _rec._execute
        end
      end

      class Interpret::Stack_Frame__

        def initialize x, context_x, cust_x, rw, on_empty, & top_oes_p

          @context_linked_list = context_x
          @customization_structure_x = cust_x
          @on_empty_JSON_object = on_empty
          @_original_caller_oes_p = top_oes_p
          @_rw = rw
          @_x = x
        end

        def _execute

          ok = __resolve_pair_stream
          ok && __prepare_to_accept_values
          ok &&= __lineup
          ok &&= __go_deep
          ok &&= __go_shallow
          ok && __flush
        end

        def __prepare_to_accept_values

          @_did_any_assignments = false

          write_value = @_rw.value_writer_

          @_write_value = -> qk do

            @_did_any_assignments = true
            @_write_value = write_value
            write_value[ qk ]
          end

          NIL_
        end

        def __resolve_pair_stream

          x = remove_instance_variable :@_x
          if x.respond_to? :each_pair
             @_pair_stream = Home_.lib_.basic::Hash.pair_stream x
             ACHIEVED_
          else
            Modalities::JSON::When_[ x, self, :Shape ]
          end
        end

        def __lineup

          deeps = nil
          shallows = nil

          bxish = ___build_boxish
          st = remove_instance_variable :@_pair_stream

          begin

            pair = st.gets
            pair or break
            sym = pair.name_symbol
            x = pair.value_x

            had = true
            qk = bxish.fetch sym do
              had = false
            end

            if ! had
              has_extra = true
              break
            end

            _is = qk.association.model_classifications.looks_compound

            _category = if _is
              ( deeps ||= [] )
            else
              ( shallows ||= [] )
            end

            _category.push qk.new_with_value x

            redo
          end while nil

          if has_extra
            __when_extra sym, st
          else
            @_boxish = bxish
            @_unorderd_deeps = deeps
            @_unorderd_shallows = shallows
            ACHIEVED_
          end
        end

        def ___build_boxish

          _st = ACS_::For_Serialization::Stream.via_customization_and_rw_(
            @customization_structure_x, @_rw )

          Common_::Stream::Magnetics::RandomAccessImmutable_via_Stream.define do |o|
            o.upstream = _st
            o.key_method_name = :name_symbol
          end
        end

        def __when_extra sym, st

          extra_a = []
          begin
            extra_a.push sym
            pair = st.gets
            pair or break
            extra_a.push pair.name_symbol
            redo
          end while nil

          Modalities::JSON::When_[ extra_a, self, :Extra ]

          UNABLE_
        end

        def __go_deep

          if @_unorderd_deeps
             ___do_go_deep
          else
            ACHIEVED_
          end
        end

        def ___do_go_deep

          a = remove_instance_variable :@_unorderd_deeps
          _sort a
          ok = true
          a.each do |qk|
            ok = ___go_deep_on qk
            ok or break
          end
          ok
        end

        def ___go_deep_on qk

          qk = ___resolve_branch_component_recursively qk
          if qk
            @_write_value[ qk ]
            ACHIEVED_
          else
            qk
          end
        end

        def ___resolve_branch_component_recursively qk

          # (eventually, fall back on using the normal constructors)

          _on_component = if qk.is_effectively_known

            -> acs do

              # the model itself does the actual contsruction, and once we
              # get this "empty" component, we can populate it by recursing

              ___recurse_into acs, qk
            end
          else

            # experimentally, the model can build from null if it
            # accepts `nil` for the proc

            NIL_
          end

          asc = qk.association

          _oes_p_p = _reinit_handlers_for asc

          o = ACS_::Interpretation::Build_value.begin(
            _on_component, asc, _ACS, & _oes_p_p )

          o.construction_method = :interpret_compound_component

          o.execute
        end

        def ___recurse_into cmp, qk

          if @customization_structure_x
            self._DING_DONG
            cust_x = NIL_
          end

          _desc_p = -> do

            _nf = qk.association.name

            "in #{ ick _nf.as_lowercase_with_underscores_symbol.id2name }"
          end

          _ctx_ = ::Skylab::Basic::List::Linked[ @context_linked_list, _desc_p ]

          _json_as_h = qk.value_x

          _rw = Home_::ReaderWriter.for_componentesque cmp

          o = Interpret::Stack_Frame__.new(
            _json_as_h,
            _ctx_,
            cust_x,
            _rw,
            @on_empty_JSON_object,
            & @_original_caller_oes_p )

          _xx_ = o._execute

          # (hi.)

          _xx_
        end

        def __go_shallow

          if @_unorderd_shallows
            ___do_go_shallow
          else
            ACHIEVED_
          end
        end

        def ___do_go_shallow

          a = remove_instance_variable :@_unorderd_shallows
          _sort a
          ok = true
          a.each do |qk|
            ok = ___go_shallow qk
            ok or break
          end
          ok
        end

        def ___go_shallow qk

          # accept each of these in a batch manner. we don't bother with
          # UOW any more: we are in the middle of a depth-first building
          # of a compound component.

          _arg_st = Home_.lib_.fields::Argument_stream_via_value[ qk.value_x ]

          # using the "value popper" (a shortlived proxy that looks like
          # a stream but only wraps one value) is our way of leveraging
          # the same validation & normalization used in "edit sessions"
          # for unserialization.. (interface experimental)

          asc = qk.association

          _reinit_handlers_for asc

          qk = ACS_::Interpretation::Build_value.call(
            _arg_st, asc, _ACS, & @_CURRENT_component_handler_builder )

          if qk
            @_write_value[ qk ]
            ACHIEVED_
          else
            qk
          end
        end

        def _reinit_handlers_for asc

          # read [#006]:#Event-models. this is the first codepoint where we
          # must know which event-model is being used, because it determines
          # how the component is built - do we pass the construction method
          # a handler builder that builds a "special" handler or one that
          # produces the raw "modality" handler that was passed to us? the
          # ACS (not the component) decides whether/how to bind the component.

          @_eventmodel_symbol ||= ___determine_eventmodel_symbol

          send WHEN_EVENTMODEL_IS___.fetch( @_eventmodel_symbol ), asc

          NIL_
        end

        WHEN_EVENTMODEL_IS___ = {
          cold: :__reinit_handlers_when_cold_for,
          hot: :__reinit_handlers_when_hot_for,  # gone in this commit
        }

        def ___determine_eventmodel_symbol

          # this used to be a hook-out, now it's a hook-in

          if _ACS.respond_to? :component_event_model
            _ACS.component_event_model
          else
            :cold
          end
        end

        def __reinit_handlers_when_cold_for asc

          # if cold, whenever an emission is emitted during unserialization,
          # emit an emission with the exact same signature but contextualized

          me = self
          orig_oes_p = @_original_caller_oes_p

          oes_p = -> * i_a, & ev_p do
            orig_oes_p.call( * i_a ) do |y=nil|

              if :expression == i_a.fetch( 1 )
                me.__express_contextualized_expression y, asc, self, & ev_p
              else
                self._HAVE_FUN_theres_already_one_such_thing_at_020_
              end
            end
            UNRELIABLE_
          end

          @_CURRENT_component_handler_builder = -> _ do
            oes_p
          end

          @_CURRENT_component_oes_p = oes_p

          NIL_
        end

        def __express_contextualized_expression y, asc, expag, & y_p

          # (this block has a unit test counterpart at [hu] #C15n-test-family-3

          o = Home_.lib_.human::NLP::EN::Contextualization.begin

          o.expression_agent = expag
          o.emission_proc = y_p

          o.to_say_subject_association = -> asc_ do
            code asc_.name.as_variegated_symbol
          end

          o.to_say_selection_stack_item = -> ctxt_p do
            calculate( & ctxt_p )
          end

          o.selection_stack = @context_linked_list
          # (the above is not a proper [#ac-031] selection stack but it's OK)

          o.subject_association = asc


          o.express_into y  # result is y
        end

        def _sort qkn_a

          # processing the assignments in "formal order" as opposed to
          # received order helps us normalize failures: two different JSON
          # payloads with a different ordering of their members but the same
          # underlying structure will in this way be processed identically,
          # making unserialization errors consistent with respect to content,
          # not surface representation.

          bx = @_boxish

          qkn_a.sort_by do |qk|

            bx.offset_of qk.name_symbol
          end
          NIL_
        end

        def __flush

          if @_did_any_assignments
            _ACS
          else
            ___when_empty
          end
        end

        def _ACS
          @_rw.ACS_
        end

        def ___when_empty

          p = @on_empty_JSON_object

          if p

            p.call do

              Modalities::JSON::When_::Empty.with(
                :context_linked_list, @context_linked_list,
                :ok, nil,  # neutralize its semantic gravity
              )
            end
          else
            Modalities::JSON::When_[ self, :Empty ]
          end
        end

        # ~ for "when"s

        def context_linked_list
          @context_linked_list
        end

        def caller_emission_handler_  # assume it's about to be used
          @_original_caller_oes_p
        end
      end

      UNRELIABLE_ = :_unreliable_
    end
  # -
end
