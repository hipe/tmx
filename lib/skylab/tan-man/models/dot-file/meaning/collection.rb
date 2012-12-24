module Skylab::TanMan
  class Models::DotFile::Meaning::Collection
    include Core::SubClient::InstanceMethods

    def apply node, meaning_ref, dry_run, verbose, error, success, info
      res = nil
      begin
        meaning = fetch_meaning meaning_ref, error, info
        meaning or break( res = meaning )
        resolved = resolve_meaning( meaning ) or break( res = resolved )
        $stderr.puts "HOLY SHIT GO ON WITH YOUR BAD SELF: #{ resolved.class }"
        res = true
      end while nil
      res
    end


    def each &block
      list.each(& block)
    end


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


    def resolve_meaning meaning
      graph = Models::DotFile::Meaning::Graph.new self, list # yes a one-off
      res = graph.resolve meaning, -> o do
        error describe_interminable_meaning( o )
        emit :help, "perhaps address these issues with your meaning #{
          }graph and try again."
      end
      res || nil # if it was false, change it to nil - we handled it
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

    def sexp
      dotfile_controller.sexp
    end
  end
end
