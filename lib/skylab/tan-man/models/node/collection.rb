module Skylab::TanMan
  class Models::Node::Collection
    include Core::SubClient::InstanceMethods # for `build_message` of events :/

    def add node_ref, do_fuzzy, error, success
      res = prod node_ref,
                     true, # yes `do_create`, call error[] if already exists
                    false, # no do not destroy
                 do_fuzzy,
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
                 do_fuzzy,
                    error,
                  success
      res
    end

    def rm node_ref, do_fuzzy, error, success
      res = prod node_ref,
                    false, # no do not create
                     true, # yes, we are here to destroy
                 do_fuzzy,
                    error, # required lambda, called e.g. if node not found
                  success  # if the destroy succeeds you get a destroyed bus. ob
      res
    end

    def list verbose, payload
      graph_sexp._node_stmts.each do |node_stmt|
        payload[ node_stmt ]
      end
      nil
    end

    def node! node_ref
      res = prod node_ref,
                      nil, # create iff necessary
                    false, # no do not destroy
                    false, # this is not fuzzy match - exact match only
 -> e { raise e.message }, # afaik only models sexp events invalid-characters
                      nil  # do not report success, just please give me the node
      res
    end

    attr_reader :graph_sexp

  private

    def initialize request_client, graph_sexp
      super request_client
      @graph_sexp = graph_sexp
    end

    def create node_ref, error
      res = nil
      begin

        proto = -> do
          sl = graph_sexp.stmt_list or break
          sl._named_prototypes or break
          sl._named_prototypes[ :node_stmt ] # might be nil
        end.call

        proto ||= graph_sexp.class.parse :node_stmt, 'foo [label="foo"]'
                                  # as part of the new "meh" paradigm ([#071])
                                  # we just hard-code some prototypes if needed

        if ! proto # off for now
          res = error[ Models::Node::Events::No_Prototype.new self, graph_noun ]
          break
        end

        new = proto._create_node_with_label node_ref, error
        new or break( res = new )

        node_id = -> do
          stem = graph_sexp._label2id_stem node_ref
          identifier = stem.intern
          h = ::Hash[ graph_sexp._node_stmts.map { |n| [ n.node_id, true ] } ]
          i = 1 # so that the first *numbered* node_id will be foo_2
          identifier = "#{ stem }_#{ i += 1 }".intern while h.key? identifier
          identifier
        end.call

        new.node_id! node_id
        res = new
      end while nil
      res
    end

    alias_method :dot_file, :request_client

    def graph_noun
      request_client.graph_noun
    end

    def node_controller node_stmt
      Models::Node::Controller.new request_client, node_stmt
    end

    public :node_controller # experimentally expose this to other controllers

    # When creating new nodes this is how we should decide where they go:
    # (this is likely not implemented fully as you read this)
    # (#doc-point [#067] is a big part of this, see more there.)
    #
    #   + if you find any existing node statements,
    #     + if you encounter any first one that is lexically greater than you,
    #       you should go immediately before it (order).
    #     + else (all the nodes were lexically less than you), insert yourself
    #       before the first statement that followed the last node statement
    #       you ever saw (proximity).
    #
    #   + else, since you did not see any node statements at all
    #     + if you saw any edge statements, you should go immediately
    #       before the first one you saw (taxonomic order).
    #     + else, since you did not see any edge statements, you should go
    #       at the very very end after any existing statements at all (idem).
    #
    # The above, if left to its own devices, will ensure that all node stmts
    # get added in alphabetical order with respect to themselves, and come
    # before e.g. all edge stmts.
    #
    # Aesthetically, we like to have node_stmts appear before any edge_stmts
    # that refer to them. But functionally it is imperative that stmts
    # that alter the appearance of other statements come before those stmts
    # they are supposed to pertain to.


    def prod node_ref, do_create, do_destroy, do_fuzzy, error, success

      # ~ exposition ~
      rx = /\A#{ ::Regexp.escape node_ref }/i # [#069]
      exact_match = -> node_stmt { node_ref == node_stmt.label }
      fuzzy_match = -> node_stmt { rx =~ node_stmt.label } if do_fuzzy
      match = fuzzy_match || exact_match
      exact_match_found = fuzzy_matches_found = nil
      still_looking_for_lexically_greater = do_create || do_create.nil?
      catch_the_first_non_node_stmt = nil
      first_edge_stmt = first_non_node_stmt =
        first_lexically_greater_node_stmt = nil

      # ~ climax ~
      node_statement_count = 0
      sl = graph_sexp.stmt_list
      sl and sl._nodes.each do |stmt_list|
        stmt = stmt_list[:stmt]
        rule = stmt.class.rule
        if :node_stmt == rule
          node_statement_count += 1
          if match[ stmt ]
            if do_fuzzy
              break( exact_match_found = stmt ) if exact_match[ stmt ]
              still_looking_for_lexically_greater =
                catch_the_first_non_node_stmt = nil                   # 1 of 3
              ( fuzzy_matches_found ||= [] ).push stmt
            else
              exact_match_found = stmt
              break
            end
          elsif still_looking_for_lexically_greater
            case node_ref <=> stmt.label
            when 1  # new should go somewhere after current
              if ! first_non_node_stmt
                catch_the_first_non_node_stmt ||= true              # here only
              end
            when -1 # new node goes after current, this is special
              catch_the_first_non_node_stmt = false                    # 2 of 3
              still_looking_for_lexically_greater = false # here only
              first_lexically_greater_node_stmt = stmt
            else
              fail "sanity - didn't you try match[] already!?"
            end
          end
        elsif catch_the_first_non_node_stmt
          first_non_node_stmt = stmt
          catch_the_first_non_node_stmt = false                        # 3 of 3
        elsif :edge_stmt == rule && ! first_edge_stmt
          first_edge_stmt = stmt
        end
      end

      # ~ dénouement ~
      res = nil
      begin
        if exact_match_found || fuzzy_matches_found
          one = exact_match_found || fuzzy_matches_found.first        # CAREFUL
          if do_create
            res = error[ Models::Node::Events::Exists.new self, one ] # meh, use
            break                                                   # first here
          end
          if exact_match_found || 1 == fuzzy_matches_found.length
            if do_destroy
              res = node_controller( one ).destroy error, success
              break
            end
            res = one
            success[Models::Node::Events::Exists.new self, one, true] if success
            break
          end
          res = error[ Models::Node::Events::Ambiguous.new self,
                       node_ref, fuzzy_matches_found ]
        elsif do_create || do_create.nil?
          new = create( node_ref, error ) or break( res = new )
          new_before_this = first_lexically_greater_node_stmt ||
            first_non_node_stmt || first_edge_stmt
          stmt_list = dot_file.insert_stmt new, new_before_this
          res = stmt_list[:stmt]
          success[ Models::Node::Events::Created.new self, res ] if success
        elsif error               # not found - emit only if asked for
          ev = Models::Node::Events::Not_Found.new self,
            node_ref,node_statement_count
          res = error[ ev ]
        end
      end while nil
      res
    end
  end
end
