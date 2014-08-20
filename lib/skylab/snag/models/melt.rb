module Skylab::Snag

  module Models::Melt

    class << self
      def build_controller * a
        self::Controller__.new a
      end

      def replacement_non_content_width
        REPLACEMENT_NON_CONTENT_WIDTH__
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

    def melt
      @file_changes.clear
      @cmd = @todos.command  # even if only used in error, couple to it now
      ok = crt_open_nodes
      ok && melt_when_nodes_opened
    end
  private
    def crt_open_nodes
      ok = ACHIEVED_
      @todos.each do |tod|
        ok_ = todo tod.collapse
        if UNABLE_ == ok_
          ok = UNABLE_
          break
        end
      end
      ok
    end
    def melt_when_nodes_opened
      cnt = @todos.seen_count
      if cnt
        if cnt.zero?
          send_info_event bld_found_no_todos_event @cmd
        else
          ok = ACHIEVED_
        end
      else
        send_info_string say_did_not_search
        ok = UNABLE_
      end
      if ok
        if @file_changes.length.nonzero?
          ok = flush_file_changes
        end
      end
      ok
    end

    def bld_found_no_todos_event cmd
      _ev = cmd.to_phrasal_noun_modifier_event
      Snag_::Model_::Event.inline :found_no_todo, :find_ev, _ev do |y, o|
        calculate y_=[], o.find_ev, & o.find_ev.message_proc
        _s = y_ * SPACE_
        y << "found no todo's #{ _s }"
      end
    end

    def say_did_not_search
      "(did not search for any todos)"
    end

    def todo todo
      if todo.any_message_body_string
        node = add_new_open_node_for_todo_item todo
        node and change_source_line todo, node
      else
        send_info_line say_no_message todo
        NEUTRAL_
      end
    end

    def add_new_open_node_for_todo_item todo
      new_node = nil
      ok = @API_client.call [ :nodes, :add ], {
                 be_verbose: @be_verbose,
        do_prepend_open_tag: true,
                    dry_run: @dry_run,
                    message: todo.any_message_body_string,
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

    # #note-110

    message_body_excerpt = sep = nil  # scope

    define_method :change_source_line do |todo, node|  # #todo
      res = true
      begin  # #todo - during de-functionalization re-write this
        fail 'sanity - should have checked for empty message body string' if
          ! todo.any_message_body_string
        if @file_changes.length.nonzero? && @file_changes.last.path != todo.path
          res = flush_file_changes or break
        end
        s_ = "#{ COMMENT_OPENER__ }#{ OPEN_TAG_S__ }#{
          }#{ BETWEEN_TAG_AND_NODE_IDENTIFIER__ }#{ node.identifier.render }"
        s = todo.any_before_comment_content_string
        new_line = if s
          "#{ s }#{ TWO_SPACES__ }#{ s_ }"
        else
          s_  # some lines will be only a comment
        end
        excerpt = message_body_excerpt[ new_line, todo ]
        if excerpt
          new_line.concat "#{ sep }#{ excerpt }"
        end
        todo.replacement_line = new_line
        @file_changes << todo
      end while nil
      nil
    end
    BETWEEN_TAG_AND_NODE_IDENTIFIER__ = ' '.freeze
    COMMENT_OPENER__ = '# '.freeze
    ENDING_IN_ONLY_ONE_SPACE_RX__ = /(?<![ ])[ ]\z/
    OPEN_TAG_S__ =  Models::Tag.canonical_tags.open_tag.render
    TWO_SPACES__ = '  '.freeze
    Models::Melt::REPLACEMENT_NON_CONTENT_WIDTH__ =
      TWO_SPACES__.length + COMMENT_OPENER__.length

    def flush_file_changes
      @file_changes.length.nonzero? and flsh_nonzero_file_changes
    end

    def flsh_nonzero_file_changes
      first = @file_changes.first
      lines = Snag_::Library_::Basic::List::Scanner::For::Path[ first.pathname ]
      patch = Snag_::Lib_::Text_patch[]::Models::ContentPatch.new lines
      @file_changes.each do |todo|
        patch.change_line todo.line_number, todo.replacement_line
      end
      ok = Snag_::Lib_::Text_patch[].file patch.render_simple,
        first.path, @dry_run, @be_verbose, method( :send_info_line )
      if ok  # typically an exit_code, like 0
        send_info_line say_summary_of_changes_in_file
        @file_changes.clear
        NEUTRAL_
      end
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

      msg_body_excrpt = -> new_line, todo do  # #note-170
        # add words to the excerpt so long as the next word would not
        # put you over the limit, taking into account spaces and ellipses etc
        res = nil
        begin  # #todo during de-functionalization, rewrite this
          words = todo.any_message_body_string.split sp
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

      min_words = 3  # #note-210

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

    def send_info_event ev
      @listener.receive_info_event ev ; NEUTRAL_
    end
    end
  end
end
