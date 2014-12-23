module Skylab::TanMan

  class Models_::Meaning

    class Collection_Controller__ < Model_lib_[].collection_controller  # #todo - push up

      class << self

        def build_via_iambic x_a
          new do
            init_via_iambic x_a
          end
        end
      end

      def initialize
        super
        @input_string = @action.argument_value :input_string
      end

      # ~ create

      def persist_entity ent, & oes_p
        _p = method :build_scan
        _os = @action.argument_value :output_string
        Meaning_::Actors__::Persist[ ent, _os, _p, oes_p ]
      end

      # ~ retrieve (many)

      def entity_stream_via_model cls, & oes_p
        if model_class == cls  # just to punish those who dare defy us
          build_scan
        end
      end

      # #todo: remove to_property_hash

    private

      def build_scan
        scan = build_comment_line_scan
        fly = Meaning_::Flyweight__.new
        scan_ = scan.map_reduce_by do |line|
          if ASSOCIATION_RX__ =~ line
            fly.set!(
              scan.last_start_position,
              scan.last_end_position,
              scan.source_string )
            fly
          end
        end
        scan_.parent_scan = scan
        scan_
      end
      ASSOCIATION_RX__ = /\A[ \t]*[-a-z]+[ \t]*:/

      def build_comment_line_scan
        if @input_string
          produce_comment_line_scan_via_mystery_string @input_string
        else

        end
      end

      def produce_comment_line_scan_via_mystery_string str
        Models_::Comment::Line_Scan.of_mystery_string str
      end
    end

    if false
    def apply node, meaning_ref, dry_run, verbose, error, success, info
      res = nil
      begin
        meaning = fetch_meaning meaning_ref, error, info
        meaning or break( res = meaning )
        meanings = resolve_meaning( meaning ) or break( res = meanings )
        attrs = parse_meanings( meanings ) or break( res = attrs )
        res = dotfile_controller.nodes.node_controller( node ).
          update_attributes attrs, error, success
      end while nil
      res
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
          new_meaning = Models::Meaning.new self, name, value_str
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
            if NEWLINE_ != whole_string[z]  # adding after the last item we may
              whole_string[z, 0] = NEWLINE_  # (DOS meh) need to add a newline.
            end
            whole_string[ z + 1, 0 ] = new_meaning.line
          end
          bytes_b = whole_string.length
          success[ Models::Meaning::Events::Created.new self,
            name, new_before_this, use_name, ( bytes_b - bytes_a ) ]
        else
          error[ Models::Meaning::Events::No_Starter.new self ]
        end
      end

      update = -> do
        o = found
        n = Models::Meaning.new self, name, value_str
        res = nil
        ok = n.normalize! -> e { res = error[ e ] }, info
        ok or break res
        if o.value == n.value
          info[ "#{ lbl name } already means #{ val n.value }" ]
          nil
        else
          o_value = o.value # you've got to dupe this before it mutates below!
          o.whole_string[ o.value_index.begin .. o.value_index.end ] = n.value
          success[ Models::Meaning::Events::Changed.new self,
            name, o_value, n.value ]
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
            info[ Models::Meaning::Events::Same_Value_Already_Set.new self,
              name, value ]
          else
            info[ Models::Meaning::Events::Different_Value_Already_Set.new self,
              name, found.value, value_str ]
          end
        else
          update[ ]
        end
      elsif do_create.nil? || do_create        # (if you didn't specify whether
        create[ ]                              # this needs to be a create, or
      else                                     # or you specified that it does.)
        error[ Models::Meaning::Events::Not_Found.new self, name ]
      end
      res
    end

    def unset meaning_name, delete, dry_run, verbose, error, success
      res = nil
      begin
        found = list.detect { |m| meaning_name == m.name }
        if found
          res = found.destroy error, -> bytes do
            success[ Models::Meaning::Events::Forgotten.new self,
              meaning_name, bytes ]
          end
        elsif delete
          res = error[ Models::Meaning::Events::Not_Found.new self,
            meaning_name, 'forget', :present ]
        else
          res = success[ Models::Meaning::Events::Not_Found.new self,
            meaning_name, 'forget', :past ]
        end
      end while nil
      res
    end

  private

    alias_method :dotfile_controller, :request_client

    def fetch_meaning meaning_ref, error, info
      rx = /\A#{ ::Regexp.escape meaning_ref }/
      fuzzy_fetch list,
        -> meaning do
          if rx =~ meaning.name
            meaning_ref == meaning.name ? 1 : 0.5
          end
        end,
        -> x do
          ev = Models::Meaning::Events::Not_Found.new self, meaning_ref,
            'fetch', :present
          ev.message = "there is no meaning associated with #{
            }#{ ick meaning_ref } (among #{ x } meaning#{ s x }). #{
            }try #{ kbd "tell #{ meaning_ref } means foo" } to give it meaning"
          error[ ev ]
          false # life is easier with false
        end,
        -> partial do
          info[ Models::Meaning::Events::Ambiguous.new self,
                meaning_ref, partial ]
          nil # easy life
        end,
        -> fly { fly.collapse self } # when we find matches (either partial
                                  # or exact) we have to "collapse" the
                                  # flyweight.  Since it is after all a
                                  # flyweight, its values are transient
    end

    meaning_assignment_entry = ::Struct.new :a_list1, :meaning

    define_method :parse_meanings do |meaning_a|
      res = false                 # result
      ok = true                   # whether to keep processing here
      p = sexp.class.grammar.parser_for_rule :a_list # #watch [#054]
      parse = -> str do
        syn_node = p.parse str
        if ! syn_node
          send_error_string "failed to parse #{ val str } - #{ p.failure_reason }"
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
        send_error_string "there are unresolvable conflicts in meaning - #{
          }#{ sentences.join '. ' }"
        emit :help, "try again after you decide"
        ok = false ; res = nil
      end

      meaning_a.each do |m|
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

    def sexp
      dotfile_controller.sexp
    end

    def resolve_meaning meaning
      graph = Models::Meaning::Graph.new self, list  # yes a one-off
      meaning_a = graph.resolve_meaning_strings meaning.name, -> interm do
        send_error_string describe_interminable_meaning interm
        emit :help, "perhaps address these issues with your meaning #{
          }graph and try again."
      end
      meaning_a || nil  # if it was false, we handled it. change to nil
    end

    def describe_interminable_meaning o
      case o.reason
      when :interminable
        trail_a = o.trail_a
        stack_a = [ "#{ ick trail_a.last } has no meaning." ]
        if 1 < trail_a.length
          stack_a << "#{ lbl trail_a[-2] } means #{ val trail_a[-1] }, but "
          trail_a.pop
        end
        while 1 < trail_a.length
          stack_a << "#{ lbl trail_a[-2] } means #{ val trail_a[-1] } and "
          trail_a.pop
        end
        stack_a.reverse.join
      when :circular
        trail_a = o.trail_a
        s = trail_a.map{ |sym| "#{ lbl sym }" }.join( ' -> ' )
        "circular dependency in meaning: #{ s }"
      else
        "interminable meaning - #{ o.reason }"
      end
    end
    end

  end
end
