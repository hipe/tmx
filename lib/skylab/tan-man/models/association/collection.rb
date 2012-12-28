module Skylab::TanMan
  class Models::Association::Collection
    include Core::SubClient::InstanceMethods

    def associate! source_ref, target_ref, assoc_param_h=nil
      # the above signature is for legacy compat. w/ test suite - may change!

           res = prod source_ref,
                      target_ref,
                             nil, # yes, `do_create`, iff necessary
            (assoc_param_h||nil), # callee will validate this and use it
                           false, # `do_fuzz` never (legacy compat for now)
        -> e { raise e.message }, # turn these into exceptions (legacy compat.)
                             nil, # don't call anything for success
                             nil  # don't call anything for info
      res
    end

                                  # if no associations found, result is always
                                  # nil. if assocations found, if you provided
                                  # a success[], is result, else is array of one
                                  # or more edge stmts that were removed.
    def destroy_all_associations node_id, _, success # i cannot fail
      res_a = each_associated_list_node( node_id ).to_a.reverse.map do |list|
        x = list._remove! list.stmt             # (reverse b/c deletes up
        x.stmt                                  # at root do a lot of juggling
      end                                       # we want to avoid. might be ok)
      res = nil
      if res_a.length.nonzero?
        res_a.reverse! # cosmetics - restore it back to the maybe lexical order
        if success
          ev = Models::Association::Events::Disassociation_Successes.new self,
            res_a
          res = success[ ev ]
        else
          res = res_a
        end
      end
      res
    end

    def set_dependency source_ref, target_ref, do_create, do_fuzz,
      error, success, info

      res = prod source_ref,
                 target_ref,
                  do_create, # up to caller whether to create etc.
                        nil, # we aren't using the assoc param here yet
                    do_fuzz, # up to caller whether we do fuzzy dupe checking
                      error, # caller handles error events
                    success, # caller handles successs events
                       info  # caller handles info events
      res
    end


    def unset_dependency source_ref, target_ref, do_fuzz, error, success, info

      res = prod source_ref,
                 target_ref,
                      false, # this value is necessary for destroy (create)
                      false, # i'm so sorry, it was too tempting not to..
                    do_fuzz, # whether to fuzzy match is up to caller
                      error, # caller handles error events
                    success, # caller handles success events - *REQUIRED* here
                       info  # caller handles info events
      res
    end



  protected

    def initialize request_client, graph_sexp
      super request_client
      @nodes = nil
      @graph_sexp = graph_sexp
    end

    def create source_node, target_node, params, error
      res = nil
      begin
        o = graph_sexp
        if ! o.stmt_list._prototype
          res = error[
            Models::Association::Events::No_Prototypes.new self, graph_noun ]
          break
        end
        if params.prototype
          proto = o._named_prototype params.prototype
          if ! proto
            res = error[
              Models::Association::Events::No_Prototype.new self, graph_noun,
                params.prototype ]
            break
          end
        else
          proto = o._named_prototype :edge_stmt
          proto ||= begin
            @_default_edge_stmt_prototype ||= begin
              prot = o.class.parse :edge_stmt, 'foo -> bar' # [#054]
              prot or fail "sanity - unexpected parse failure parsing edge_stmt"
              prot
            end
          end
        end
        res = proto._create source_node, target_node, params
      end while nil
      res
    end

    def destroy edge_pairs, source_node, target_node, success
      res = nil
      edge_pairs.reverse.each do |node, item|
        edge_stmt = node._remove! item
        ev = Models::Association::Events::Disassociation_Success.new self,
          source_node, target_node, edge_stmt
        ev.message = "#{ lbl source_node.label } no longer depends #{
          }on #{ lbl target_node.label } (removed this edge_stmt: #{
          }#{ kbd edge_stmt.unparse })"
        res = success[ ev ]
      end
      res # le sketch
    end

    def each_associated_list_node node_id
      ::Enumerator.new do |y|     # used to be a nice pretty reduce but w/e
        each_edge_stmt_list.each do |edge_stmt_list|
          o = edge_stmt_list.stmt
          if o.source_node_id == node_id or o.target_node_id == node_id
            y << edge_stmt_list
          end
        end
        nil
      end
    end

    def each_edge_stmt_list       # repeats some of `prod` but w/o all the
      ::Enumerator.new do |y|     # lexcial trappings
        sl = graph_sexp.stmt_list or break
        sl._nodes.each do |stmt_list|
          stmt = stmt_list.stmt or next
          :edge_stmt == stmt.class.rule or next
          y << stmt_list
        end
        nil
      end
    end

    def graph_noun
      request_client.graph_noun
    end

    attr_reader :graph_sexp

    def nodes
      @nodes ||= request_client.send :nodes
    end

    association_params = ::Struct.new :attrs, :prototype

    define_method :prod do
      |source_ref, target_ref, do_create, assoc_param_h, do_fuzz,
        error, success, info|

      res = nil
      begin
        ok = true

        params = association_params.new
        if assoc_param_h
          assoc_param_h.each { |k, v| params[k] = v } ; assoc_param_h = nil
        elsif false == assoc_param_h
          do_destroy = true # i'm so sorry
        end

        source_node, target_node = -> do       # --~ find nodes ~--
          do_creat = ( false == do_create ) ? false : nil # soften this so it
                                               # doesn't bark if this is a
                                               # strict create for assocs..
                                               # .. (but not nodes)

          if success && (do_create || do_create.nil?)  # aggregate successes
            sagg = TanMan::Model::Event::Aggregate.new # into one lump event
            succes = -> e { sagg.list.push e }         # (but "exists" for read-
          end                                          # onlies are too loud.)


          eagg = TanMan::Model::Event::Aggregate.new # aggregate errors
          erro = -> e { eagg.list.push e ; false }   # ick, nec

          src = nodes.produce source_ref, do_creat, do_fuzz, erro, succes
          tgt = nodes.produce target_ref, do_creat, do_fuzz, erro, succes

          if ! ( src && tgt )                  # emit aggregated errors
            ok = [src, tgt].include?( false ) ? false : nil # omg
            if eagg.list.length.nonzero?
              if ! eagg.list.index { |e| ! e.is? :'not-found' } # ling. hack
                eagg2 = Models::Node::Events::Not_Founds.new self, eagg.list
                eagg = eagg2
              end
              error[ eagg ]
            end
            break ok
          end

          if sagg  && sagg.list.length.nonzero? # emit aggregated successes
            success[ sagg ]
          end

          [ src, tgt ]
        end.call
        ok or break( res = ok )

                                               # --~ lexical pasta ~--
        looking = do_create || do_create.nil?  #   else don't bother
        keep_first_non_edge = nil              #   visible by not_looking[]
        reverse_was_true = false
        src = source_node.node_id
        tgt = target_node.node_id

        compare = -> do                        # --~ make a comparator ~--
          if looking                           # this is the expensive version
            src_s = src.to_s
            tgt_s = tgt.to_s
            -> stmt do
              src_id = stmt.source_node_id
              tgt_id = stmt.target_node_id
              if ! reverse_was_true && src == tgt_id && tgt == src_id
                reverse_was_true = true        # while we're being expensive
              end                              # we do this cute thing
              x = src_s <=> src_id.to_s
              x = tgt_s <=> tgt_id.to_s if 0 == x
              x
            end
          else                                 # and this is the cheap one
            -> stmt do
              src_id = stmt.source_node_id
              tgt_id = stmt.target_node_id
              if ! reverse_was_true && src == tgt_id && tgt == src_id
                reverse_was_true = true         # ACK here too
              end
              0 if src_id == src && tgt_id == tgt
            end
          end
        end
        cmp = compare[ ]
        not_looking = -> do                    # we switch from expensive to
          looking = keep_first_non_edge = false # cheap when we an exact match
          cmp = compare[ ]                     # or definite anchor, whichever
        end



        edge_pairs, new_before_this = -> do    # --~ find associations ~--
          first_lexically_greater_edge = first_non_edge = nil
          new_before_this = nil                # per [#067]..
          prev_node = graph_sexp.stmt_list
          a = graph_sexp.stmt_list._nodes.reduce( [ ] ) do |memo, stmt_list|
            stmt = stmt_list.stmt
            if :edge_stmt == stmt.class.rule
              case cmp[ stmt ]
              when nil                         # no match and no lexicals to do
                                               #  just a short circuit
              when  0
                memo.push [ prev_node, stmt ]  # exact match, but there might
                not_looking[ ] if looking      # (weirdly) be more so stay

              when 1                           # new should come after this
                keep_first_non_edge = true     # only set this here, once
                                               # you've seen any nodes

              when -1                          # this comes after new, this is
                first_lexically_greater_edge = stmt # special
                not_looking[ ]
              end
            elsif keep_first_non_edge
              first_non_edge = stmt            # in case we found edges but
              keep_first_non_edge = nil        # none lexically greater
            end
            prev_node = stmt_list
            memo
          end
          [ a, ( first_lexically_greater_edge || first_non_edge ) ]
        end.call

                                               # --~ dénouement ~--
        if edge_pairs.length.nonzero?
          edge_stmt = -> { _, x = edge_pairs.first ; x } # when you only care
                                  # about the 1st result, and item not node

                                  # in a `create` operation, it is always an
          if do_create            # error to find any existing ones
            ev = Models::Association::Events::Exists.new self, edge_stmt[ ]
            res = error[ ev ]
          elsif do_create.nil?    # the lazy create result should be the same
            if info               # shape as the successful strict create,
              ev = Models::Association::Events::Exists.new self, edge_stmt[], 1
              info[ ev ]          # namely, the stmt created (or found)
            end
            res = edge_stmt
          elsif do_destroy
            res = destroy edge_pairs, source_node, target_node, success
          else
            res = edge_pairs      # *very* experimental -- might change!
          end                     # a strict read-only operation: we don't
                                  # use this yet afaik
        elsif do_create || do_create.nil?
          edge_stmt = create source_node, target_node, params, error
          edge_stmt or break( res = edge_stmt )
          graph_sexp.stmt_list._insert_before! edge_stmt, new_before_this
          res = if success
            success[ Models::Association::Events::Created.new self, edge_stmt ]
          else
            edge_stmt
          end
        elsif error               # `do_create` was false and nothing was found,
                                  # so if you set an error lambda boy howdy
          ev = Models::Association::Events::Not_Associated.new self,
            source_node, target_node, reverse_was_true

          ev.message = "#{ lbl source_node.label } already does not #{
            }depend on #{ lbl target_node.label }#{
            }#{ if reverse_was_true
                  " (but #{ lbl target_node.label } does depend on #{
                    }#{ lbl source_node.label }!)"
                 end }"

          res = error[ ev ]
        end
      end while nil
     res
    end
  end
end
