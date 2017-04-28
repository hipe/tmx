module Skylab::TanMan

  class Models_::Node  # in [#084]

    module Magnetics_

      CommonMagnetic__ = ::Class.new Common_::MagneticBySimpleModel

      class Create_or_Retrieve_or_Touch_via_NodeName_and_Collection < CommonMagnetic__
        # -

          def initialize
            @_node_ID_is_provided = false
            super
          end

          def name_string= s
            @_unsanitized_label_string = s
          end

          def execute
            super  # hi.
          end

          def _resolve_new_node_id_
            _find_next_available_node_id_programmatically
          end
        # -
      end

      class Create_or_Touch_or_Delete_via_Node_and_Collection < CommonMagnetic__ # 2x
        # -

          def initialize
            super
            __init_ivars_related_to_provided_node_ID
            @_unsanitized_label_string = @entity.unsanitized_label_string___
          end

          attr_writer(
            :entity,
          )

          def execute
            super  # hi.
          end

          def __init_ivars_related_to_provided_node_ID

            provided_ID = @entity.lookup_value_softly_ :id
            if provided_ID
              @provided_ID = provided_ID
              @provided_ID_sym = provided_ID.intern
              @_node_ID_is_provided = true
            else
              @_node_ID_is_provided = false
            end
          end

          def _resolve_new_node_id_

            if @_node_ID_is_provided
              @new_node_ID_sym = @provided_ID.intern
              ACHIEVED_
            else
              _find_next_available_node_id_programmatically
            end
          end
        # -
      end

      # ==

      class CommonMagnetic__  # (re-open)

        def initialize
          @top_channel_for_created_symbol = nil
          super
          __init_ivars_as_CM
        end

        attr_writer(
          :document,
          :entity_via_created_element_by,
          :listener,
          :top_channel_for_created_symbol,
          :verb_lemma_symbol,  # 'create' | 'retrieve' | 'touch'
        )

        def execute
          __find_neighbors
          __via_verb_produce_relevant_sexp
        end

        def __init_ivars_as_CM

          send :"init_ivars_for__#{ @verb_lemma_symbol }__"

          gsp = @document.graph_sexp
          @stmt_list = gsp.stmt_list
          @graph_sexp = gsp

          NIL
        end

        def init_ivars_for__create__
          @can_create = true
          @do_fuzzy = false
          @internal_verb = :touch
        end

        def init_ivars_for__touch__
          @can_create = true
          @do_fuzzy = false
          @internal_verb = :touch
        end

        def init_ivars_for__retrieve__
          @can_create = false
          @do_fuzzy = false
          @internal_verb = @verb_lemma_symbol
        end

        def init_ivars_for__delete__
          @can_create = false
          @do_fuzzy = false
          @internal_verb = @verb_lemma_symbol
        end

        def __find_neighbors
          if @stmt_list
            __find_neighbors_when_stmt_list
          else
            __find_neighbors_when_empty_list
          end
        end

        def __find_neighbors_when_empty_list
          @has_neighbors = false ; nil
        end

        def __find_neighbors_when_stmt_list

          __init_ivars_for_find_neighbors

          while @still_looking
            node = @node_stream.gets
            node or break
            __process_node_for_neighbors node
          end
          NIL
        end

        def __init_ivars_for_find_neighbors
          @catch_the_first_non_node_stmt = nil
          @exact_match_found = nil
          @first_edge_stmt = nil
          @first_lexically_greater_node_stmt = nil
          @first_non_node_stmt = nil
          @fuzzy_matches_found = nil
          @has_neighbors = true
          @num_nodes_seen = 0
          @node_stream = @stmt_list.to_element_stream_
          @still_looking = @node_stream && true
          @still_looking_for_lexically_greater = @can_create  # || @can_create.nil?
          __init_matchers
        end

        def __init_matchers

          if @_node_ID_is_provided
            __init_matcher_using_node_IDs
          else
            __init_matcher_using_labels
          end
        end

        def __init_matcher_using_node_IDs
          sym = @provided_ID_sym
          @match_p = -> stmt do
            sym == stmt.node_ID_symbol_
          end ; nil
        end

        def __init_matcher_using_labels

          s = @_unsanitized_label_string

          @exact_match_p = -> stmt do
            s == stmt.label_or_node_id_normalized_string
          end

          if @do_fuzzy
            @fuzzy_match_p = Here_.build_sexp_fuzzy_matcher_via_natural_key_fragment_ @_unsanitized_label_string
            @match_p = @fuzzy_match_p
          else
            @match_p = @exact_match_p
          end ; nil
        end

        def __process_node_for_neighbors node
          stmt = node[ :stmt ]
          rule_i = stmt.class.rule
          if :node_stmt == rule_i
            __process_significant_node_for_potential_neighbor stmt
          elsif @catch_the_first_non_node_stmt
            @first_non_node_stmt = stmt
            @catch_the_first_non_node_stmt = false  # 1 of 3
          elsif :edge_stmt == rule_i && ! @first_edge_stmt
            @first_edge_stmt = stmt
          end ; nil
        end

        def __process_significant_node_for_potential_neighbor stmt
          @num_nodes_seen += 1
          _b = @match_p[ stmt ]
          if _b
            __when_match stmt
          elsif @still_looking_for_lexically_greater
            __when_still_looking stmt
          end ; nil
        end

        def __when_match stmt
          if @do_fuzzy
            __when_fuzzy_and_match stmt
          else
            @exact_match_found = stmt
            @still_looking = false
            @node_stream = nil
          end
        end

        def __when_fuzzy_and_match stmt
          _b = @exact_match_p[ stmt ]
          if _b
            @exact_match_found = stmt
            @still_looking = false
            @node_stream = nil
          else
            @still_looking_for_lexically_greater = nil
            @catch_the_first_non_node_stmt = nil  # 2 of 3
            ( @fuzzy_matches_found ||= [] ).push stmt
          end ; nil
        end

        def __when_still_looking stmt
          case @_unsanitized_label_string <=> stmt.label_or_node_id_normalized_string
          when 1  # new should go somewhere after current
            if ! @first_non_node_stmt
              @catch_the_first_non_node_stmt ||= true
            end
          when -1  # new node goes after current, this is special
            @catch_the_first_non_node_stmt = false  # 3 of 3
            @still_looking_for_lexically_greater = false  # here only
            @first_lexically_greater_node_stmt = stmt
          else
            self._SANITY  # we must have tried exact match already
          end
          NIL
        end

        def __via_verb_produce_relevant_sexp
          send :"produce_relevant_sexp_when__#{ @internal_verb }__"
        end

        def produce_relevant_sexp_when__touch__
          _ok = __resolve_relevant_sexp_when_touch
          _ok && @THIS_GUY  # (was @created_existing_or_destroyed_node)
        end

        def produce_relevant_sexp_when__retrieve__
          if @do_fuzzy
            self._HOLE
          elsif @exact_match_found
            @exact_match_found
          else
            _when_not_found
          end
        end

        def produce_relevant_sexp_when__delete__
          if @do_fuzzy
            self._HOLE
          elsif @exact_match_found
            __del
          else
            _when_not_found
          end
        end

        def __resolve_relevant_sexp_when_touch
          ok = __resolve_new_node_without_id
          ok &&= __to_new_node_apply_id
          ok && __via_neighbors_and_new_node_insert_if_necessary
        end

        def _when_not_found

          @listener.call :error, :node_not_found do

            _as_componet = Common_::Name.via_slug @_unsanitized_label_string
            # this might give us "human" inflection. we could do better,
            # but it would invole heavy hacking of the node class

            ACS_[]::Events::ComponentNotFound.with(
              :component, _as_componet,
              :component_association, Here_,
            )
          end
          UNABLE_
        end

        def __resolve_new_node_without_id

          _proto = produce_prototype_node

          _ = _proto.create_node_with_label__ @_unsanitized_label_string, & @listener

          _store :@created_existing_or_destroyed_node, _
        end

        def produce_prototype_node
          if @stmt_list
            __produce_prototype_node_when_stmt_list
          else
            _dangerously_memoized_hard_coded_default_node
          end
        end

        def __produce_prototype_node_when_stmt_list
          np = @stmt_list.named_prototypes_
          if np
            node = np[ :node_stmt ]  # might be nil
          end
          if ! node
            node = _dangerously_memoized_hard_coded_default_node
          end
          node
        end

        define_method :_dangerously_memoized_hard_coded_default_node, -> do

          yes = true ; x = nil

          once = -> doc do
            yes = false ; once = nil
            x = doc.class.parse(  # #[#071] "meh"
              :node_stmt,
              'your_node_ID_here [label="«your label here»"]',
            )
            NIL
          end

          -> do
            yes && once[ @graph_sexp ]
            x
          end
        end.call

        def __to_new_node_apply_id
          if _resolve_new_node_id_
            _ = remove_instance_variable :@new_node_ID_sym
            @created_existing_or_destroyed_node.set_node_id _
          end
        end

        def _find_next_available_node_id_programmatically

          _st = @graph_sexp.to_node_stream

          taken = _st.reduce_into( {} ) do |h|
            -> node do
              h[ node.node_ID_symbol_ ] = true
            end
          end

          head = @graph_sexp._label2id_stem @_unsanitized_label_string
          stem_sym = head.intern

          d = 1  # so that the first *numbered* node_id will be foo_2

          while taken[ stem_sym ]
            stem_sym = :"#{ head }_#{ d += 1 }"
          end

          @new_node_ID_sym = stem_sym ; ACHIEVED_
        end

        def __via_neighbors_and_new_node_insert_if_necessary
          if @has_neighbors
            __via_existent_neighbors_and_new_node_insert_if_necessary
          else
            __insert_new_node_into_empty_list
          end
        end

        def __via_existent_neighbors_and_new_node_insert_if_necessary
          if @exact_match_found || @fuzzy_matches_found
            __when_matches_exist
          elsif @can_create  # or nil
            __insert_when_touch_and_no_matches
          else
            __when_match_not_found
          end
        end

        def __when_matches_exist
          one = @exact_match_found || @fuzzy_matches_found.first  # CAREFUL
          if @can_create
            send :"when__#{ @internal_verb }__when_one_exists_already", one
          elsif @exact_match_found || 1 == @fuzzy_matches_found.length
            send :"when__#{ @internal_verb }__when_one_exists_already", one
          else
            __when_ambiguous
          end
        end

        def when__touch__when_one_exists_already one

          @created_existing_or_destroyed_node = one  # OVERWRITE

          is_ok = send :"when__#{ @verb_lemma_symbol }__and_you_found_one_it_is_OK"

          _this_top_sym = is_ok ? :success : ( is_ok.nil? ? :info : :error )

          @listener.call _this_top_sym, :found_existing_node do

            Found_existing_node___[].with(
              :component, Component_via_NodeStatement___.new( one ),
              :ok, is_ok,
            )
          end

          if :create == @verb_lemma_symbol
            UNABLE_
          else
            POSITIVE_NOTHINGNESS_
          end
        end

        def when__create__and_you_found_one_it_is_OK
          false
        end

        def when__touch__and_you_found_one_it_is_OK
          true
        end

        def when__delete__when_one_exists_already one
          self._DO_ME
          # node_controller( one ).destroy @error_p, @success_p
        end

        def __when_ambiguous

          @listener.call :error, :ambiguous do
            __build_ambiguous_event
          end
          UNABLE_
        end

        def __build_ambiguous_event
          build_not_OK_event_with :ambiguous, :name_s, @_unsanitized_label_string,
              :nodes, @fuzzy_matches_found do |y, o|

            _s_a = o.to_node_stream.map_by do |n|
              lbl n.label_or_node_id_normalized_string
            end.to_a

            y << "ambiguous node name #{ ick o.name_s }. #{
             }did you mean #{ or_ _s_a }?"
          end
        end

        def __insert_when_touch_and_no_matches

          _least_greater_neighbor = @first_lexically_greater_node_stmt ||
            @first_non_node_stmt || @first_edge_stmt

          nd = @created_existing_or_destroyed_node

          _new_stmt_list = @document.insert_stmt_before_stmt(
            nd, _least_greater_neighbor )

          node_stmt = _new_stmt_list[ :stmt ]

          nd.object_id == node_stmt.object_id or self._SANITY

          _see_created_node node_stmt

          ACHIEVED_
        end

        def __insert_new_node_into_empty_list

          nd = @created_existing_or_destroyed_node
          stmt_list = @document.insert_stmt nd
          node_stmt = stmt_list[ :stmt ]
          nd.object_id == node_stmt.object_id or self._SANITY
          _see_created_node node_stmt
          ACHIEVED_
        end

        def __del
          @document.destroy_stmt @exact_match_found
        end

        def _see_created_node node_stmt

          @THIS_GUY = @entity_via_created_element_by[ node_stmt ]

          if @listener
            __emit_created_node
          end
          NIL
        end

        def __emit_created_node

          _use_sym = @top_channel_for_created_symbol || :info

          _ev = __build_created_node_event  # eager for now  # #todo

          @listener.call _use_sym, :created_node do
            _ev
          end
          NIL
        end

        def __build_created_node_event

          _ev = Common_::Event.inline_OK_with(

            :created_node,  # #[#ac-007.4]
            :node, @THIS_GUY,
            :did_mutate_document, true,

          ) do |y, o|

            y << "created node #{ component_label o.node.node_label_ }"
          end

          _ev  # hi. #todo
        end

        def __when_match_not_found

          @listener.call :error, :match_not_found do
            __build_match_not_found_event
          end
          UNABLE_
        end

        def __build_match_not_found_event
          build_not_OK_event_with :match_not_found, :name_s, @_unsanitized_label_string,
              :seen_count, @num_nodes_seen do |y, o|
            y << "couldn't find a node whose label starts with #{
             }#{ ick o.name_s } #{
              }(among #{ o.seen_count } node#{ s o.seen_count })"
          end
        end

        def handle_error
          -> ev do
            send_event ev
            UNABLE_
          end
        end

        define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

        POSITIVE_NOTHINGNESS_ = true
      end

      # ==

      class Component_via_NodeStatement___

        # (we might do etc but this is a probe for now..)

        def initialize ns
          @__node_statement = ns
        end

        def description_under expag

          s = @__node_statement.label_or_node_id_normalized_string

          expag.calculate do
            component_label s
          end
        end
      end

      # ==

      Found_existing_node___ = Lazy_.call do

        FoundExistingNode = ACS_[]::Events::ComponentAlreadyAdded.prototype_with(

          :found_existing_node,
          :component_association, Here_,
          :did_mutate_document, false,
          :ok, nil
        )
      end

      # ==
      # ==
    end
  end
end
# #meta-tombstone-A: event prototypes for destroyed, not found
