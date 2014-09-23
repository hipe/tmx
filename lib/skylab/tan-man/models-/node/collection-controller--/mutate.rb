module Skylab::TanMan

  class Models_::Node  # in [#084]

    class Collection_Controller__

      class Mutate

        Via_entity = self

        Callback_::Actor[ self, :properties,
          :verb,
          :entity,
          :datastore,
          :event_receiver, :kernel ]

        Event_[].sender self

        def execute
          init_ivars
          find_neighbors
          produce_relevant_sexp_via_create_or_mutate_or_destory
        end

      private

        def init_ivars
          @name_s = @entity.property_value :name
          @graph_sexp = @datastore.graph_sexp
          @stmt_list = @graph_sexp.stmt_list
          send :"init_ivars_for_#{ @verb }"
        end

        def init_ivars_for_touch
          @can_create = true
          @do_fuzzy = false
        end

        def init_ivars_for_create
          @can_create = true
          @do_fuzzy = false
        end

        def find_neighbors
          if @stmt_list
            find_neighbors_when_stmt_list
          else
            find_neighbors_when_empty_list
          end
        end

        def find_neighbors_when_empty_list
          @has_neighbors = false ; nil
        end

        def find_neighbors_when_stmt_list
          init_ivars_for_find_neighbors
          while @scan and node = @scan.gets
            process_node_for_neighbors node
          end ; nil
        end

        def init_ivars_for_find_neighbors
          @catch_the_first_non_node_stmt = nil
          @exact_match_found = nil
          @first_edge_stmt = nil
          @first_lexically_greater_node_stmt = nil
          @first_non_node_stmt = nil
          @fuzzy_matches_found = nil
          @has_neighbors = true
          @num_nodes_seen = 0
          @scan = @stmt_list.to_scan
          @still_looking_for_lexically_greater = @can_create  # || @can_create.nil?
          init_matchers
        end

        def init_matchers
          s = @name_s
          @exact_match_p = -> stmt do
            s == stmt.label_or_node_id_normalized_string
          end
          if @do_fuzzy
            @fuzzy_match_p = build_fuzzy_match_p
            @match_p = @fuzzy_match_p
          else
            @match_p = @exact_match_p
          end ; nil
        end

        def build_fuzzy_match_p
          rx = /\A#{ ::Regexp.escape @name_s }/i  # :+[#069] case insensitive?
          -> stmt do
            rx !~ stmt.label_or_node_id_normalized_string
          end
        end

        def process_node_for_neighbors node
          stmt = node[ :stmt ]
          rule_i = stmt.class.rule
          if :node_stmt == rule_i
            process_significant_node_for_potential_neighbor stmt
          elsif @catch_the_first_non_node_stmt
            @first_non_node_stmt = stmt
            @catch_the_first_non_node_stmt = false  # 1 of 3
          elsif :edge_stmt == rule_i && ! @first_edge_stmt
            @first_edge_stmt = stmt
          end ; nil
        end

        def process_significant_node_for_potential_neighbor stmt
          @num_nodes_seen += 1
          _b = @match_p[ stmt ]
          if _b
            when_match stmt
          elsif @still_looking_for_lexically_greater
            when_still_looking stmt
          end ; nil
        end

        def when_match stmt
          if @do_fuzzy
            when_fuzzy_and_match stmt
          else
            @exact_match_found = stmt
            @scan = nil
          end
        end

        def when_fuzzy_and_match stmt
          _b = @exact_match_p[ stmt ]
          if _b
            @exact_match_found = stmt
            @scan = nil
          else
            @still_looking_for_lexically_greater = nil
            @catch_the_first_non_node_stmt = nil  # 2 of 3
            ( @fuzzy_matches_found ||= [] ).push stmt
          end ; nil
        end

        def when_still_looking stmt
          case @name_s <=> stmt.label_or_node_id_normalized_string
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

        def produce_relevant_sexp_via_create_or_mutate_or_destory
          send :"produce_relevant_sexp_when_#{ @verb }"
        end

        def produce_relevant_sexp_when_touch
          ok = produce_relevant_sexp_when_create
          ok && @created_existing_or_destoryed_node
        end

        def produce_relevant_sexp_when_create
          ok = resolve_new_node_without_id
          ok &&= to_new_node_apply_id
          ok && via_neighbors_and_new_node_insert_if_necessary
        end

        def resolve_new_node_without_id
          proto = produce_prototype_node
          new = proto._create_node_with_label @name_s, handle_error
          if new
            @created_existing_or_destoryed_node = new
            ACHEIVED_
          else
            new
          end
        end

        def produce_prototype_node
          if @stmt_list
            produce_prototype_node_when_stmt_list
          else
            produce_hard_coded_default_prototype_node
          end
        end

        def produce_prototype_node_when_stmt_list
          np = @stmt_list._named_prototypes
          if np
            node = np[ :node_stmt ]  # might be nil
          end
          if ! node
            node = produce_hard_coded_default_prototype_node
          end
          node
        end

        define_method :produce_hard_coded_default_prototype_node, -> do
          _NODE_ = nil ; p = -> doc do
            doc.class.parse :node_stmt, 'foo [label="foo"]'  # :+[#071] "meh"
          end
          -> do
            _NODE_ ||= p[ @graph_sexp ]
          end
        end.call

        def to_new_node_apply_id
          ok = resolve_new_node_id
          if ok
            @created_existing_or_destoryed_node.set_node_id @new_node_id
          end
        end

        def resolve_new_node_id
          stem_s = @graph_sexp._label2id_stem @name_s
          stem_i = stem_s.intern
          h = ::Hash[ @graph_sexp.nodes.map do |node|
            [ node.node_id, true ]
          end ]
          d = 1  # so that the first *numbered* node_id will be foo_2
          while h.key? stem_i
            stem_i = :"#{ stem_s }_#{ d += 1 }"
          end
          @new_node_id = stem_i ; ACHEIVED_
        end

        def via_neighbors_and_new_node_insert_if_necessary
          if @has_neighbors
            via_existant_neighbors_and_new_node_insert_if_necessary
          else
            insert_new_node_into_empty_list
          end
        end

        def via_existant_neighbors_and_new_node_insert_if_necessary
          if @exact_match_found || @fuzzy_matches_found
            when_matches_exist
          elsif @can_create  # or nil
            insert_when_create_and_no_matches
          else
            when_match_not_found
          end
        end

        def when_matches_exist
          one = @exact_match_found || @fuzzy_matches_found.first  # CAREFUL
          if @can_create
            send :"when_#{ @verb }_when_one_exists_already", one
          elsif @exact_match_found || 1 == @fuzzy_matches_found.length
            send :"when_#{ @verb }_when_one_exists_already", one
          else
            when_ambiguous
          end
        end

        def when_touch_when_one_exists_already one
          @created_existing_or_destoryed_node = one  # OVERWRITE
          _ev = Node_::Events__::Exists.with :node_stmt, one, :ok, true
          send_event _ev
          POSITIVE_NOTHINGNESS_
        end

        def when_create_when_one_exists_already one
          _ev = Node_::Events__::Exists.with :node_stmt, one, :ok, false
          send_event _ev
          UNABLE_
        end

        def when_destroy_when_one_exists_already one
          self._DO_ME
          # node_controller( one ).destroy @error_p, @success_p
        end

        def when_ambiguous
          _ev = build_not_OK_event_with :ambiguous, :name_s, @name_s,
              :nodes, @fuzzy_matches_found do |y, o|
            _s_a = o.nodes.map do |n|
              lbl n.label_or_node_id_normalized_string
            end
            y << "ambiguous node name #{ ick o.name_s }. #{
             }did you mean #{ or_ _s_a }?"
          end
          send_event _ev
          UNABLE_
        end

        def insert_when_create_and_no_matches
          _least_greater_neighbor = @first_lexically_greater_node_stmt ||
            @first_non_node_stmt || @first_edge_stmt
          nd = @created_existing_or_destoryed_node
          new_stmt_list = @datastore.insert_stmt_before_stmt(
            nd, _least_greater_neighbor )
          node_stmt = new_stmt_list[ :stmt ]
          nd.object_id == node_stmt.object_id or self._SANITY
          send_created_event_for_node node_stmt
          ACHEIVED_
        end

        def insert_new_node_into_empty_list
          nd = @created_existing_or_destoryed_node
          stmt_list = @datastore.insert_stmt nd
          node = stmt_list[ :stmt ]
          nd.object_id == node.object_id or self._SANITY
          send_created_event_for_node node
          ACHEIVED_
        end

        def send_created_event_for_node node_stmt
          _ev = build_OK_event_with :created, :node_stmt, node_stmt do |y, o|
            y << "created node #{ lbl o.node_stmt.label }"
          end
          send_event _ev
        end

        def when_match_not_found
          _ev = build_match_not_found_event
          send_event _ev
          UNABLE_
        end

        def build_match_not_found_event
          build_not_OK_event_with :match_not_found, :name_s, @name_s,
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

        def send_event ev
          @event_receiver.receive_event ev ; nil
        end

        POSITIVE_NOTHINGNESS_ = true
      end
    end
  end
end
if false
module Skylab::TanMan
  class Models::Node::Collection
    include Core::SubClient::InstanceMethods # for `build_message` of events :/

    def add node_ref, do_fuzzy, error, success
      res = prod node_ref,
                     true, # yes `do_create`, call error[] if already exists
                    false, # no do not destroy
                 @do_fuzzy,
                    error, # this determines your result if failed e.g. existed
                  success  # (if the add succeeded, you get the business object)
      res
    end

    def fetch node_ref, error
      res = prod node_ref,
                    false, # no do not create
                    false, # no do not destroy
                     true, # yes sure why not always fuzzy
                    error, # if provided receives Not_Found, Ambiguous events
                      nil  # do not create Exists events, just result in node
      res
    end

    def produce node_ref, do_create, do_fuzzy, error, success
      res = prod node_ref,
                do_create,
                    false, # no do not destroy
                 @do_fuzzy,
                    error,
                  success
      res
    end

    def rm node_ref, do_fuzzy, error, success
      res = prod node_ref,
                    false, # no do not create
                     true, # yes, we are here to destroy
                 @do_fuzzy,
                    error, # required lambda, called e.g. if node not found
                  success  # if the destroy succeeds you get a destroyed bus. ob
      res
    end

    def touch_node_via_label node_ref
      res = prod node_ref,
                      nil, # create iff necessary
                    false, # no do not destroy
                    false, # this is not fuzzy match - exact match only
 -> e { raise e.message }, # afaik only models sexp events invalid-characters
                      nil  # do not report success, just please give me the node
      res
    end
  end
end
end
