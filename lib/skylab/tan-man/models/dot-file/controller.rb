module Skylab::TanMan
  class Models::DotFile::Controller < ::Struct.new  :dry_run,
                                                    :force,
                                                    :pathname,
                                                    :statement,
                                                    :verbose

    include Core::SubClient::InstanceMethods

    extend Headless::Parameter::Controller::StructAdapter # just the members

    include Models::DotFile::Parser::InstanceMethods

    # (the below public nerks are generally called exclusively by
    # api action implementations!)

    def set_dependency source_ref, target_ref, error, success, info
      res = nil
      begin
        graph = self.sexp or break( res = graph )
        if ! graph.stmt_list._prototype
          res = error[
             Models::Association::Events::No_Prototype.new self, graph_noun ]
          break
        end
        res = graph.associate! source_ref, target_ref, { prototype: nil },
          error, success, info
      end while nil
      res
    end


    def check
      res = true # always succeeds
      begin
        sexp = self.sexp or break # emitted
        if verbose
          # this is strictly a debugging thing expected to be used from the
          # command line.  using the `infostream` (which here in the api
          # is a facade to an event emitter) is really icky and overkill here,
          # hence we just use $stderr directly :/
          TanMan::Services::PP.pp sexp, $stderr # (note above)
          s = ::Pathname.new( __FILE__ ).relative_path_from TanMan.dir_pathname
          info "(from #{ s })"
        else
          info "#{ escape_path pathname } looks good : #{ sexp.class }"
        end
      end while nil
      res
    end


    def disassociate! source_ref, target_ref, nodes_not_found,
                                                nodes_not_associated, success
      res = nil

      resolve_nodes = -> do
        ambis = [] ; not_founds = []
        ambi = -> o { ambis << o }  ; not_found = -> o { not_founds << o }
        source_node = fetch_node source_ref, not_found, ambi
        target_node = fetch_node target_ref, not_found, ambi

        if ! source_node || ! target_node
          agg = Models::Event::Aggregate.new self, [ ]
          agg.list << Models::Node::Events::Node_Not_Founds.new( self,
            not_founds ) if not_founds.length.nonzero?
          agg.list.concat ambis
          res = nodes_not_found[ agg ]
          break
        end
        [ source_node, target_node ]
      end

      find_edges = -> source_node, target_node do
        reverse_was_true = nil
        source_node_id = source_node.node_id
        target_node_id = target_node.node_id
        prev_node = sexp.stmt_list
        a = sexp.stmt_list._nodes.reduce( [ ] ) do |memo, stmt_list|
          stmt = stmt_list.stmt
          if :edge_stmt == stmt.class.rule
            src_id = stmt.source_node_id
            tgt_id = stmt.target_node_id
            if src_id == source_node_id
              if tgt_id == target_node_id
                memo.push [ prev_node, stmt ]
              end
            elsif tgt_id == source_node_id && src_id == target_node_id
              reverse_was_true = true
            end
          end
          prev_node = stmt_list
          memo
        end
        if a.length.nonzero?
          a
        else
          ev = Models::Node::Events::Nodes_Not_Associated.new( self,
            source_node, target_node, reverse_was_true )
          ev.message = "#{ lbl source_node.label } already does not #{
            }depend on #{ lbl target_node.label }#{ if reverse_was_true then
            " (but #{ lbl target_node.label } does depend on #{
            }#{ lbl source_node.label })" end }"
          rev = nodes_not_associated[ ev ]
          nil
        end
      end

      begin
        sexp or break # (else we might double up later on emissions ick!)
        ( source_node, target_node = resolve_nodes[ ] ) or break
        edges = find_edges[ source_node, target_node ] or break
        edges.reverse.each do |node, item|
          edge_stmt = node.destroy_child! item
          ev = Models::Node::Events::Disassociation_Success.new self,
            source_node, target_node, edge_stmt
          ev.message = "#{ lbl source_node.label } no longer depends #{
            }on #{ lbl target_node.label } (removed this edge_stmt: #{
            }#{ kbd edge_stmt.unparse })"
          res = success[ ev ]
        end
      end while nil
      res
    end



    constantize = ::Skylab::Autoloader::Inflection::FUN.constantize

    define_method :execute do     # execute a statement
      rule = statement.class.rule.to_s
      rule_stem = rule.match(/_statement\z/).pre_match
      action_class = Models::DotFile::Actions.const_fetch rule_stem
      o = action_class.new self
      res = o.invoke dotfile_controller: self,
                                dry_run: dry_run,
                                  force: force,
                              statement: statement,
                                verbose: verbose
      res
    end


  # --*-- the below are public but are for sub-clients only --*--
    def apply_meaning node_ref, meaning, dry_run, verbose, error, success, info
      res = nil
      begin
        node = fetch_node( node_ref, error, info )
        break( res = node ) if ! node
        res = meanings.apply node, meaning, dry_run, verbose, error,
                                                                  success, info
      end while nil
      res
    end

    define_method :fetch_node do |node_ref, not_found, ambiguous|
      res = nil
      begin
        sexp = self.sexp or break
        rx = /\A#{ ::Regexp.escape node_ref }/i # case-insensitive for now,
        res = fuzzy_fetch sexp._node_stmts,     # we could do a fuzzy tie-
          -> stmt do                            # breaker if we needed to
            if rx =~ stmt.label # stmt.node_id
              node_ref == stmt.label ? 1 : 0.5
            end
          end,
          -> count do
            not_found[ Models::Node::Events::Node_Not_Found.new(
              self, node_ref, count ) ]
            false # this makes life easier..
          end,
          -> partial do
            ambiguous[ Models::Node::Events::Ambiguous_Node_Reference.new(
              self, node_ref, partial ) ]
            nil # this makes life easier
          end
      end while nil
      res
    end

    def graph_noun
      "#{ escape_path pathname }"
    end

    def meanings
      @meanings ||= Models::DotFile::Meaning::Collection.new self
    end

    def set_meaning agent, target, create, dry_run, verbose,     # contrast
                                    error, success, neutral      # this way..
      meanings.set agent, target, create, dry_run, verbose,
                                   error, success, neutral
    end

    def sexp # etc
      res = nil
      begin
        res = services.tree.fetch pathname do |k, svc|
          tree = parse_file pathname
          if tree
            svc.set! k, tree
          end
          tree
        end
        if ! res
          emit :help, "perhaps try fixing above syntax errors and try again"
          res = nil
        end
      end while nil
      res
    end

    def unset_meaning *a                                         # ..with this.
      meanings.unset(* a)
    end

    nl_rx = /\n/ # meh
    num_lines = -> str do
      scn = TanMan::Services::StringScanner.new str
      num = 0
      num += 1 while scn.skip_until( nl_rx )
      num += 1 unless scn.eos?
      num
    end

    define_method :write do |dry_run, force, verbose|
      bytes = nil
      begin
        next_string = sexp.unparse
        if ! pathname.exist?
          error "strange - #{graph_noun} didn't previously exist - won't write"
          break # or just raise
        end
        pathname.exist? or fail 'sanity'
        prev_string = pathname.read
        if prev_string == next_string
          info "(no changes in #{ graph_noun } - nothing to save.)"
          break
        end
        num_a = num_lines[ prev_string ]
        num_b = num_lines[ next_string ]
        if num_b < num_a && ! force
          error "ok to reduce number of lines in #{
            }#{ escape_path pathname } from #{ num_a } to #{ num_b }? #{
            }If so, use #{ par :force }."
          break # IMPORTANT!
        end
        bytes = write_commit next_string, dry_run, verbose
        break if ! bytes
        info "wrote #{ escape_path pathname } (#{ bytes } bytes)"
      end while nil
      bytes
    end

  protected

    def write_commit string, dry_run, verbose
      res = nil
      begin
        temp = services.tmpdir.tmpdir.join 'next.dot'
        bytes = nil
        temp.open( 'w' ) { |fh| bytes = fh.write string }
        diff = services.diff.diff pathname, temp, nil,
          -> e do
            error e
          end,
          -> i do
            if verbose
              info( gsub_path_hack i ) # e.g. `diff --normal `...
            end
          end
        break( res = diff ) if ! diff
        a = []
        nerk = -> x, verb do
          break if x == 0
          a.push "#{ verb } #{ x } line#{ s x }"
        end
        nerk[ diff.num_lines_removed, 'removed' ]
        nerk[ diff.num_lines_added,   'added'   ]
        was_empty = a.empty?
        no_change = ( 0 == diff.num_lines_added && 0 == diff.num_lines_removed )
        if no_change
          a.push "no lines added or removed!"
        end
        if verbose
          info( a.join ', ' )
        end
        break if no_change
        fu = Headless::IO::FU.new -> msg do
          if verbose
            info( gsub_path_hack msg )
          end
        end
        fu.mv temp, pathname, noop: dry_run
        bytes
      end while nil
      res
    end
  end
end
