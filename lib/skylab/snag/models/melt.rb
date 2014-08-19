module Skylab::Snag

  module Models::Melt

    class << self
      def build_controller * a
        self::Controller__.new a
      end
    end

    class Controller__ < Snag_::Model_::Controller

    def initialize a
      @dry_run, @be_verbose, @paths, @pattern, @names, @working_dir,
        listener, _API_client = a

      @file_changes = []

      o = Snag_::Models::ToDo.build_enumerator @paths, @pattern, @names
      o.on_error_string listener.method :receive_error_string
      o.on_command_string do |cmd_str|  # (strict event handling)
        if @be_verbose
          @listener.receive_info_line cmd_str
        end
      end
      @todos = o
      super listener, _API_client
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
            send_info_string say_found_no_todos cmd
          else
            res = true
          end
        else
          send_info_string say_did_not_search
          res = false
        end
        res or break
        if @file_changes.length.nonzero?
          res = file_changes_flush
        end
      end while nil
      res
    end

  private

    def say_found_no_todos cmd
      "found no todo's #{ cmd.prepositional_phrase_under self }"
    end

    def say_did_not_search
      "(did not search for any todos)"
    end

    def todo todo
      if ! todo.message_body_string
        send_info_line say_no_message todo
        nil
      else
        node = add_new_open_node_for_todo_item todo
        node and change_source_line todo, node
      end
    end

    def add_new_open_node_for_todo_item todo
      new_node = nil
      ok = @API_client.call [ :nodes, :add ], {
                 be_verbose: @be_verbose,
        do_prepend_open_tag: true,
                    dry_run: @dry_run,
                    message: todo.message_body_string,
                working_dir: @working_dir
      }, -> o do
        o.on_error_event @listener.method :receive_error_event
        o.on_error_string @listener.method :receive_error_string
        o.on_info_event @listener.method :receive_info_event
        o.on_info_line @listener.method :receive_info_line
        o.on_info_string @listener.method :receive_info_string
        o.on_new_node { |nn| new_node = nn }
      end
      ok && new_node
    end

    def say_no_message todo
      "(will not melt todo with no message - #{ render_todo_location todo })"
    end

    def render_todo_location todo
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
          }# #{ node.identifier.render }" # some lines will just be a comment
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
        lines = Snag_::Library_::
          Basic::List::Scanner::For::Path[ first.pathname ]
        patch = Snag_::Lib_::Text_patch[]::Models::ContentPatch.new lines
        @file_changes.each do |todo|
          patch.change_line todo.line_number, todo.replacement_line
        end
        res = Snag_::Lib_::Text_patch[].file patch.render_simple,
          first.path, @dry_run, @be_verbose, method( :send_info_line )
        # typically an exit_code, like 0
        res or break
        send_info_line say_summary_of_changes_in_file
        @file_changes.clear
      end while nil
      res
    end

    def say_summary_of_changes_in_file
      first = @file_changes.first
      d = @file_changes.length
      change_summary_s = if 1 == d
        " - #{ first.one_line_summary }"
      end
      expression_agent.calculate do
        "(changed #{ d } line#{ s d } in #{ first.path }#{ change_summary_s })"
      end
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
          words[ 0, min_words - 1 ] = EMPTY_A_
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

      sp = SPACE_

      msg_body_excrpt
    end.call

    def expression_agent
      API::EXPRESSION_AGENT
    end

    def send_info_line s
      @listener.receive_info_line s ; NEUTRAL_
    end

    def send_info_string s
      @listener.receive_info_string s ; NEUTRAL_
    end
    end
  end
end
