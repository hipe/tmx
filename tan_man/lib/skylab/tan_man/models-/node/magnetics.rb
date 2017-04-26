module Skylab::TanMan

  class Models_::Node  # in [#084]

    module Magnetics

      CommonMagnetic__ = ::Class.new Common_::MagneticBySimpleModel

      class Create_or_Retrieve_or_Touch_via_NodeName_and_Collection < CommonMagnetic__
        # -
          attr_writer(
            :name_string,
            :verb_lemma_symbol,  # 'create' | 'retrieve' | 'touch'
          )

          def execute
            super
          end

          def _init_name_string_
            NOTHING_
          end

          def _init_ivars_
            @node_ID_is_provided = false
            super
          end

          def _resolve_new_node_id_
            _resolve_new_node_id_programmatically
          end
        # -
      end

      class Create_or_Touch_or_Delete_via_Node_and_Collection < CommonMagnetic__ # 2x
        # -
          attr_writer(
            :entity,
          )

          def execute
            super
          end

          def _init_name_string_
            @name_string = @entity.node_name_string__ ; nil
          end

          def _init_ivars_

            provided_ID = @entity.lookup_value_softly_ :id
            if provided_ID
              @provided_ID = provided_ID
              @provided_ID_sym = provided_ID.intern
              @node_ID_is_provided = true
            else
              @node_ID_is_provided = false
            end
            super
          end

          def _resolve_new_node_id_

            if @node_ID_is_provided
              @new_node_ID_sym = @provided_ID.intern
              ACHIEVED_
            else
              _resolve_new_node_id_programmatically
            end
          end
        # -
      end

      # ==

      class CommonMagnetic__  # (re-open)

        attr_writer(
          :document,
          :listener,
          :verb_lemma_symbol,
        )

        def execute
          _init_ivars_
          __find_neighbors
          __via_verb_produce_relevant_sexp
        end

        def _init_ivars_
          @graph_sexp = @document.graph_sexp
          _init_name_string_
          @stmt_list = @graph_sexp.stmt_list
          send :"init_ivars_for__#{ @verb_lemma_symbol }__"
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
          @node_stream = @stmt_list.to_node_stream_
          @still_looking = @node_stream && true
          @still_looking_for_lexically_greater = @can_create  # || @can_create.nil?
          __init_matchers
        end

        def __init_matchers

          if @node_ID_is_provided
            __init_matcher_using_node_IDs
          else
            __init_matcher_using_labels
          end
        end

        def __init_matcher_using_node_IDs
          sym = @provided_ID_sym
          @match_p = -> stmt do
            sym == stmt.node_id
          end ; nil
        end

        def __init_matcher_using_labels
          s = @name_string
          @exact_match_p = -> stmt do
            s == stmt.label_or_node_id_normalized_string
          end
          if @do_fuzzy
            @fuzzy_match_p = Here_.build_sexp_fuzzy_matcher_via_natural_key_fragment_ @name_string
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
          case @name_string <=> stmt.label_or_node_id_normalized_string
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
          end ; nil
        end

        def __via_verb_produce_relevant_sexp
          send :"produce_relevant_sexp_when__#{ @internal_verb }__"
        end

        def produce_relevant_sexp_when__touch__
          ok = __resolve_relevant_sexp_when_touch
          ok && @created_existing_or_destroyed_node
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

            _as_componet = Common_::Name.via_slug @name_string
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

          _new = _proto._create_node_with_label @name_string, & handle_event_selectively

          _store :@created_existing_or_destroyed_node, _new
        end

        def produce_prototype_node
          if @stmt_list
            __produce_prototype_node_when_stmt_list
          else
            _produce_hard_coded_default_prototype_node
          end
        end

        def __produce_prototype_node_when_stmt_list
          np = @stmt_list.named_prototypes_
          if np
            node = np[ :node_stmt ]  # might be nil
          end
          if ! node
            node = _produce_hard_coded_default_prototype_node
          end
          node
        end

        define_method :_produce_hard_coded_default_prototype_node, -> do
          _NODE_ = nil ; p = -> doc do
            doc.class.parse :node_stmt, 'foo [label="foo"]'  # :+[#071] "meh"
          end
          -> do
            _NODE_ ||= p[ @graph_sexp ]
          end
        end.call

        def __to_new_node_apply_id
          ok = _resolve_new_node_id_
          if ok
            @created_existing_or_destroyed_node.set_node_id @new_node_ID_sym
          end
        end

        def _resolve_new_node_id_programmatically

          stem_s = @graph_sexp._label2id_stem @name_string
          stem_i = stem_s.intern

          _st = @graph_sexp.to_node_stream

          h = _st.reduce_into( {} ) do |hash|
            -> node do
              hash[ node.node_id ] = true
            end
          end

          d = 1  # so that the first *numbered* node_id will be foo_2

          while h.key? stem_i
            stem_i = :"#{ stem_s }_#{ d += 1 }"
          end

          @new_node_ID_sym = stem_i ; ACHIEVED_
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

            lib = Here_::Events__

            lib::Found_Existing_Node.with(
              :component, lib::Node_Statement_as_Component.new( one ),
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
          build_not_OK_event_with :ambiguous, :name_s, @name_string,
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

          _send_created_event_for_node node_stmt

          ACHIEVED_
        end

        def __insert_new_node_into_empty_list
          nd = @created_existing_or_destroyed_node
          stmt_list = @document.insert_stmt nd
          node = stmt_list[ :stmt ]
          nd.object_id == node.object_id or self._SANITY
          _send_created_event_for_node node
          ACHIEVED_
        end

        def __del
          @document.destroy_stmt @exact_match_found
        end

        def _send_created_event_for_node node_stmt

          @listener.call :info, :created_node do
            __build_created_node_event node_stmt
          end
        end

        def __build_created_node_event node_stmt

          build_OK_event_with :created_node,  # #[#ac-007.4]

              :node_stmt, node_stmt,
              :did_mutate_document, true do | y, o |

            y << "created node #{ lbl o.node_stmt.label }"
          end
        end

        def __when_match_not_found

          @listener.call :error, :match_not_found do
            __build_match_not_found_event
          end
          UNABLE_
        end

        def __build_match_not_found_event
          build_not_OK_event_with :match_not_found, :name_s, @name_string,
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
      # ==
    end
  end
end
