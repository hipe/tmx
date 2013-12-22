module Skylab::Snag

  class Models::Melt::Controller

    # one public method - `melt`

    include Snag::Core::SubClient::InstanceMethods

      # straightforward subclient - emits PIE upwards

 private

    #        ~ all methods/procs listed in pre-order traversal ~

    def initialize rc, paths, dry_run, names, pattern, be_verbose
      super rc
      @dry_run = dry_run
      @pattern = pattern
      @file_changes = []
      o = Snag::Models::ToDo::Enumerator.new paths, names, pattern
      o.on_error method( :error )
      o.on_command do |cmd_str|   # (strict event handling)
        if @be_verbose
          info cmd_str
        end
      end
      @todos = o
      @be_verbose = be_verbose
    end

    def melt  # public
      res = true
      begin
        @file_changes.clear
        cmd = @todos.command  # even if only used in error, couple to it now
        @todos.each do |tod|
          res = todo tod.collapse  # turn a flyweight into a proper model, b.c
          false == res and break   # we will do some heavy lifing w/ it
        end
        false == res and break
        cnt = @todos.seen_count
        res = nil
        if cnt
          if cnt.zero?
            info "found no todo's #{ cmd.prepositional_phrase_under self }"
          else
            res = true
          end
        else
          info "(did not search for any todos)"
          res = false
        end
        res or break
        if @file_changes.length.nonzero?
          res = file_changes_flush
        end
      end while nil
      res
    end

    public :melt

    todo_where = nil  # scope

    define_method :todo do |todo|
      if ! todo.message_body_string
        info "(will not melt todo with no message - #{ todo_where[ todo ] })"
        nil
      else
        new_node = nil
        res = @request_client.api_invoke [ :nodes, :add ], {
                   be_verbose: @be_verbose,
          do_prepend_open_tag: true,
                      dry_run: @dry_run,
                      message: todo.message_body_string
        }, -> a do
          a.on_new_node { |n| new_node = n }
          a.on_info method( :info )
          a.on_raw_info -> txt do
            @request_client.send :emit, :raw_info, txt
          end
          a.on_error method( :error )
        end
        if res
          res = change_source_line todo, new_node
        end
        res
      end
    end

    todo_where = -> todo do
      "#{ todo.path }:#{ todo.line_number_string }"
    end

    # Each time you want to change a line in source code, cache up all
    # the changes you want to make to each line that is in the same file
    # and patch the file all in one atomic action. (This pattern could of
    # course be broadened, with some work, to make a patch for a whole
    # codebase [#028].) (but note it is annoying b/c of the atomicicity
    # of node ids and you need the correct id for the patch, so you want
    # to be sure you do it right.)

    message_body_excerpt = sep = nil  # scope

    define_method :change_source_line do |todo, node|
      res = true
      begin
        fail 'sanity - should have checked for empty message body string' if
          ! todo.message_body_string
        if @file_changes.length.nonzero? && @file_changes.last.path != todo.path
          res = file_changes_flush or break
        end
        new_line = "#{ todo.pre_comment_string }#{
          }# #{ node.identifier }" # some lines will just be a comment
        excerpt = message_body_excerpt[ new_line, todo ]
        if excerpt
          new_line << "#{ sep }#{ excerpt }"
        end
        todo.replacement_line = new_line
        @file_changes << todo
      end while nil
      nil
    end

    def file_changes_flush
      res = nil
      begin
        break if @file_changes.length.zero?
        first = @file_changes.first
        lines = Headless::Services::
          Basic::List::Scanner::For::Path[ first.pathname ]
        patch = Headless::Services::Patch::Models::ContentPatch.new lines
        @file_changes.each do |todo|
          patch.change_line todo.line_number, todo.replacement_line
        end
        res = Headless::Services::Patch.file patch.render_simple,
          first.path, @dry_run, @be_verbose, -> e { info e }
        # typically an exit_code, like 0
        res or break
        x = @file_changes.length
        xtra = if 1 == x
          " - #{ first.one_line_summary }"
        end
        info "(changed #{ x } line#{ s x } in #{ first.path }#{ xtra })"
        @file_changes.clear
      end while nil
      res
    end

    sep = ' - '

    message_body_excerpt = -> do

      ellipsis = line_width = min_words = sp = nil  # scope

      # You are taking out the todo tag and message from the line, and replacing
      # it with a node identifer (number). This operation may leave you with
      # extra whitespace in the remainder of the line. To avoid having obtuse,
      # unreadable node identifiers, we will fill the remaining available
      # space with an excerpt from the original message, ellipsified to fit
      # within whatever space remain in the line.
      #
      # (parts might get pushed up one day, tracked by [#hl-045])
      #
      msg_body_excrpt = -> new_line, todo do
        # add words to the excerpt so long as the next word would not
        # put you over the limit, taking into account spaces and ellipses etc
        res = nil
        begin
          words = todo.message_body_string.split sp
          words.length.zero? and break # maybe just sanity
          available_length = line_width - ( new_line.length + sep.length )
          fail 'sanity' if min_words < 1
          excerpt = words[ 0, min_words - 1 ].join sp
          words[ 0, min_words - 1 ] = []
          next_length = -> do
            x = excerpt.length
            if words.length.nonzero?
              x += sp.length if excerpt.length.nonzero?
              x += words.first.length
              if words.length > 1
                x += ellipsis.length
              end
            end
            x
          end
          shift = -> do
            excerpt.concat "#{ sp if excerpt.length.nonzero? }#{ words.shift }"
            nil
          end
          break if next_length[] > available_length # atomicicity w/ min_words
          res = excerpt
          while words.length.nonzero?
            shift[]
            break if next_length[] > available_length
          end
          excerpt.concat( ellipsis ) if words.length.nonzero?
        end while nil
        res
      end

      ellipsis = ' ..'

      line_width = Models::Manifest.line_width

      min_words = 3 # arrived at heuristically, min num words from msg to
        # bother including in the replacement line - (too few sounds dumb,
        # an interesting nlp problems similar to summarization [#it-001])

      sp = ' '

      msg_body_excrpt
    end.call
  end
end
