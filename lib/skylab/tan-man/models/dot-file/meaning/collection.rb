module Skylab::TanMan
  class Models::DotFile::Meaning::Collection
    include Core::SubClient::InstanceMethods

    def apply node, meaning_ref, dry_run, verbose, error, success, info
      res = nil
      begin
        meaning = fetch_meaning meaning_ref, error, info
        meaning or break( res = meaning )
        meanings = resolve_meaning( meaning ) or break( res = meanings )
        attrs = parse_meanings( meanings ) or break( res = attrs )
        a_list = node.attr_list.content
        a_list._prototype ||= a_list_prototype
        added = [] ; changed = []
        node.attr_list.content._update_attributes! attrs,
          -> name, val { added << [name, val] },
          -> name, old, new { changed << [name, old, new] }
        preds = [ ]
        if added.length.nonzero?
          preds << "added attribute#{ s added }: #{
            }[ #{added.map { |k, v| "#{k}=#{v}" }.join(', ') } ]"
        end
        if changed.length.nonzero?
          preds << "changed #{ changed.map do |k, old, new|
            "#{ k } from #{ val old } to #{ val new }"
          end.join ' and ' }"
        end
        success[ "on node #{ lbl node.label } #{ preds.join ' and ' }" ]
        res = true
      end while nil
      res
    end

    def each &block
      list.each(& block)
    end

    hack_rx = Models::DotFile::Meaning::FUN.match_line_rx

    define_method :list do
      ::Enumerator.new do |y|
        fly = Models::DotFile::Meaning::Flyweight.new
        sexp.comment_nodes.each do |str|
          enum = Models::Comment::LineEnumerator.for str
          enum.each do |line|
            if hack_rx =~ line
              fly.set! str, ( enum.scn.pos - line.length )
              y << fly
            end
          end
        end
        nil
      end
    end

    define_method :set do |
      name, value_str, do_create, dry_run, verbose, error, success, info |

                                  # experimentally we're going all functional

      do_create = nil if :both == do_create # hack to allow a nil thru

      name = name.strip           # (just to be sure we are normal-esque)

      new_before_this = new_after_this = found = nil # this is everything

      create = -> do
        use_name = new_before_this || new_after_this
        if use_name               # because of our flyweight impl. we've
                                  # got to walk the tree again to get the item.
                                  # this was a bit tricky! suggestions welcome
          use_meaning = list.detect { |meaning| use_name == meaning.name }
          new_meaning = Models::DotFile::Meaning.new self, name, value_str
          res = nil
          ok = new_meaning.normalize! -> e { res = error[ e ] }, info
          ok or break res
          whole_string = use_meaning.whole_string
          bytes_a = whole_string.length
          new_meaning.duplicate_spacing! use_meaning
          if new_before_this # new_meaning should go before new_before_this
            whole_string[ use_meaning.line_start, 0 ] = new_meaning.line
          else
            z = use_meaning.value_index.end + 1 # in the case that we are
            if "\n" != whole_string[z]  # adding after the last item we may
              whole_string[z, 0] = "\n" # (DOS meh) need to add a newline.
            end
            whole_string[ z + 1, 0 ] = new_meaning.line
          end
          bytes_b = whole_string.length
          success[ "added new meaning #{ lbl name } #{
            }#{ new_before_this ? 'before' : 'after' } #{
            }#{ lbl use_name } (#{ bytes_b - bytes_a } bytes)" ]
        else
          error[ "can't add meaning when none is there to start with!" ]
        end
      end

      update = -> do
        o = found
        n = Models::DotFile::Meaning.new self, name, value_str
        res = nil
        ok = n.normalize! -> e { res = error[ e ] }, info
        ok or break res
        if o.value == n.value
          info[ "#{ lbl name } already means #{ val n.value }" ]
          nil
        else
          o_value = o.value # you've got to dupe this before it mutates below!
          o.whole_string[ o.value_index.begin .. o.value_index.end ] = n.value
          success[ "changed meaning of #{ lbl name } from #{
            }#{ val o_value } to #{ val n.value }" ]
        end
      end

      list.each do |meaning|
        current_name = meaning.name
        case current_name <=> name
        when -1                                # new one should go after
          new_after_this = current_name        # current one. keep the latest
                                               # such one found, for order

        when 0                                 # exact match, which is good
          found = meaning                      # or bad depending on `do_create`
          break                                # careful - flyweight!

        when 1                                 # new one should go before
          new_before_this ||= current_name     # current one. note only the
        end                                    # first such one, which in an
      end                                      # ordered list will maintain it.
                                               # this is more meaningful than
                                               # the `after` variable above.

      res =
      if found
        if do_create
          if value_str == found.value
            info[ "#{ lbl name } is already set to that value." ]
          else
            error[ "there is already a meaning for #{ lbl name }" ]
          end
        else
          update[ ]
        end
      elsif do_create.nil? || do_create        # (if you didn't specify whether
        create[ ]                              # this needs to be a create, or
      else                                     # or you specified that it does.)
        error[ "found no existing meaning to change: #{ val name }" ]
      end
      res
    end

    def unset meaning, delete, dry_run, verbose, error, success
      res = nil
      begin
        found = list.detect { |m| meaning == m.name }
        if found
          res = found.destroy error, -> bytes do
            success[ "forgetting #{ lbl meaning } (#{ bytes } bytes)" ]
          end
        elsif delete
          res = error[ "there is no such meaning to forget: #{ val meaning }" ]
        else
          res = success["there was no such meaning to forget: #{ val meaning }"]
        end
      end while nil
      res
    end

  protected

    a_list_proto = nil

    define_method :a_list_prototype do
      a_list_proto ||= begin
        p = sexp.class.grammar.parser_for_rule :a_list # [#054]
        syn_node = p.parse 'a=b, c=d' # you are setting the template for spacing
        a_list = sexp.class.element2tree syn_node, :a_list_prototype
        a_list
      end
      a_list_proto
    end

    def describe_interminable_meaning o
      case o.reason
      when :interminable
        s = o.trail.map do |m|
          "#{ lbl m.name } means #{ val m.value }"
        end.join ' and '
        msg = "interminable meaning: #{ s }, but #{
          }#{ ick o.trail.last.value } has no meaning."
      when :circular
        s = o.trail.map do |m|
          "#{ lbl m.name } -> #{ lbl m.value }"
        end.join ', '
        msg = "circular dependency in meaning: #{ s }"
      else
        msg = "interminable meaning - #{ o.reason }"
      end
      msg
    end

    alias_method :dotfile_controller, :request_client

    def fetch_meaning meaning_ref, error, info
      rx = /\A#{ ::Regexp.escape meaning_ref }/
      res = fuzzy_fetch list,
        -> meaning do
          if rx =~ meaning.name
            meaning_ref == meaning.name ? 1 : 0.5
          end
        end,
        -> x do
          error[ "there is no meaning associated with #{ ick meaning_ref } #{
            } (among #{ x } meaning#{ s x }). try #{ kbd "tell #{ meaning_ref}#{
            } means foo" } to give it meaning" ]
          false # life is easier with false
        end,
        -> partial do
          info[ "#{ ick meaning_ref } has ambiguous meaning. #{
            }did you mean #{ or_ partial.map { |m| "#{ lbl m.name }" } }?" ]
          nil # easy life
        end,
        -> fly { fly.collapse self } # when we find matches (either partial
                                  # or exact) we have to "collapse" the
                                  # flyweight.  Since it is after all a
                                  # flyweight, its values are transient
    end

    meaning_assignment_entry = ::Struct.new :a_list1, :meaning

    define_method :parse_meanings do |meanings|
      res = false                 # result
      ok = true                   # whether to keep processing here
      p = sexp.class.grammar.parser_for_rule :a_list # #watch [#054]
      parse = -> m do
        syn_node = p.parse m.value
        if ! syn_node
          error "failed to parse #{ lbl m.name } : #{ val m.value } - #{
            }#{ p.failure_reason }"
          emit :help, "try again after fixing the above syntax errors"
          ok = false ; res = nil
        end
        syn_node
      end

      assignments = [ ]           # flat list of assmt entry structs
      index = { }                 # hash of arrays of indexes into above
                                  # look for name collisions ('meaning
                                  # conflicts') only at the end

      conflict = -> conflict_h do
        sentences = conflict_h.map do |attr, idxs|
          predicates = idxs.map do |idx|
            asst = assignments[idx]
            "in #{ lbl asst.meaning.name } as #{
              }#{ ick asst.a_list1.equals.id.normalized_string }"
          end
          "#{ ick attr } was defined #{ predicates.join ' and ' } #{
          }- which one is right?"
        end
        error "there are unresolvable conflicts in meaning - #{
          }#{ sentences.join '. ' }"
        emit :help, "try again after you decide"
        ok = false ; res = nil
      end

      meanings.each do |m|
        syn_node = parse[ m ] or break
        a_list = sexp.class.element2tree syn_node, :custom_a_list
        a_list._items.each do |a_list1|
          o = meaning_assignment_entry.new a_list1, m
          assignments[ assmt_id = assignments.length ] = o
          id = o.a_list1.id.unparse
          existing = index.fetch( id ) { |k| index[k] = [] }
          if existing.length.zero?
            existing.push assmt_id
          else
            otr = assignments[ existing.last ]
            if otr.a_list1.equals.id.normalized_string !=
                 o.a_list1.equals.id.normalized_string then
              existing.push assmt_id
            end
          end
        end
      end
      if ok
        conflict_h = index.select { |k, a| a.length > 1 }
        conflict[ conflict_h ] if conflict_h.length.nonzero?
      end
      if ok
        pairs = # since some assignments might be redundant, we only do a subset
          index.map { |k, a| [k, a.first] }.sort { |a, b| a.last <=> b.last }
        res = pairs.map do |attr, idx|
          [ attr, assignments[idx].a_list1.equals.id.normalized_string ]
        end
      end
      res
    end

    def resolve_meaning meaning
      graph = Models::DotFile::Meaning::Graph.new self, list # yes a one-off
      res = graph.resolve meaning, -> o do
        error describe_interminable_meaning( o )
        emit :help, "perhaps address these issues with your meaning #{
          }graph and try again."
      end
      res || nil # if it was false, change it to nil - we handled it
    end

    def sexp
      dotfile_controller.sexp
    end
  end
end
