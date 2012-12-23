module Skylab::TanMan
  class Models::DotFile::Meaning::Collection
    include Core::SubClient::InstanceMethods


    def each &block
      list.each(& block)
    end


    hack_rx = Models::DotFile::Meaning::MATCH_LINE_RX

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

    alias_method :dotfile_controller, :request_client

    def sexp
      dotfile_controller.sexp
    end
  end
end
