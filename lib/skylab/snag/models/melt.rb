module Skylab::Snag

  module Models::Melt  # see [#063]

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
        delegate, _API_client = a

      @file_changes = []
      @todos = Snag_::Models::ToDo.build_scan @paths, @pattern, @names,
        :on_command_string, -> cmd_str do
          if @be_verbose
            @delegate.receive_info_line cmd_str
          end
        end,
        :on_error_event, delegate.method( :receive_error_event )
      super delegate, _API_client
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
      @todos.each do |fly|
        ok = fly.collapse @delegate
        ok or break
        ok = add_open_node_for_todo_if_appropriate ok
        ok or break
        ok = ACHIEVED_
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

    def add_open_node_for_todo_if_appropriate todo
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
        o.on_error_event @delegate.method :receive_error_event
        o.on_error_string @delegate.method :receive_error_string
        o.on_info_event @delegate.method :receive_info_event
        o.on_info_line @delegate.method :receive_info_line
        o.on_info_string @delegate.method :receive_info_string
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

    def change_source_line todo, node
      todo.any_message_body_string or self._SANITY  # always check for empty msg body string
      ok = flush_any_file_changes todo
      ok and mutate_line todo, node
    end

    def flush_any_file_changes todo
      if @file_changes.length.nonzero? && @file_changes.last.path != todo.path
        flush_file_changes
      else
        ACHIEVED_
      end
    end

    def mutate_line todo, node
      new_line = build_new_line todo, node
      todo.replacement_line = new_line
      @file_changes.push todo
      ACHIEVED_
    end

    def build_new_line todo, node
      s = todo.any_before_comment_content_string
      s_ = "#{ COMMENT_OPENER__ }#{ OPEN_TAG_S__ }#{
        }#{ BETWEEN_TAG_AND_NODE_IDENTIFIER__ }#{ node.identifier.render }"
      new_line = if s
        "#{ s }#{ TWO_SPACES__ }#{ s_ }"
      else
        s_  # some lines will be only a comment
      end
      excerpt = Get_any_message_body_excerpt__[ new_line, todo ]
      excerpt and new_line.concat "#{ SEP_ }#{ excerpt }"
      new_line
    end

    BETWEEN_TAG_AND_NODE_IDENTIFIER__ = ' '.freeze
    COMMENT_OPENER__ = '# '.freeze
    ENDING_IN_ONLY_ONE_SPACE_RX__ = /(?<![ ])[ ]\z/
    OPEN_TAG_S__ =  Models::Tag.canonical_tags.open_tag.render
    SEP_ = ' - '.freeze
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

    class Get_any_message_body_excerpt__

      Snag_::Model_::Actor[ self,
        :properties, :new_line, :todo_o ]

      def execute
        init
        work
        @message_body_excerpt
      end
    private
      def init
        @ellipsis = ELLIPSIS__
        @line_width = LINE_WIDTH__
        @min_words = MIN_WORDS__
        0 < @min_words or self._SANITY
      end

      def work
        @word_s_a = @todo_o.any_message_body_string.split SPACE_
        if @word_s_a.length.zero?
          @message_body_excerpt = nil
        else
          when_nonzero_number_of_words
        end
      end

      def when_nonzero_number_of_words
        @available_length = LINE_WIDTH__ - ( @new_line.length + SEP_.length )
        @excerpt_s = @word_s_a[ 0, @min_words - 1 ].join SPACE_
        @word_s_a[ 0, @min_words - 1 ] = EMPTY_A_
        if next_length > @available_length
          @message_body_excerpt = nil
        else
          flush
        end
      end

      def flush
        @message_body_excerpt = @excerpt_s  # success is guaranteed from here
        while @word_s_a.length.nonzero?
          accept_one
          _stop = next_length > @available_length
          _stop and break
        end
        if @word_s_a.length.nonzero?
          @excerpt_s.concat @ellipsis
        end ; nil
      end

      def next_length
        d = @excerpt_s.length
        if @word_s_a.length.nonzero?
          d.zero? or d += SPACE_.length
          d += @word_s_a.first.length
          1 < @word_s_a.length and d += @ellipsis.length
        end
        d
      end

      def accept_one
        @excerpt_s.length.nonzero? and _s = SPACE_
        @excerpt_s.concat "#{ _s }#{ @word_s_a.shift }" ; nil
      end

      ELLIPSIS__ = ' ..'.freeze
      LINE_WIDTH__ = Models::Manifest.line_width
      MIN_WORDS__ = 3  # #note-210
    end

    def expression_agent
      API::EXPRESSION_AGENT
    end

    def send_info_line s
      @delegate.receive_info_line s ; NEUTRAL_
    end

    def send_info_string s
      @delegate.receive_info_string s ; NEUTRAL_
    end

    def send_info_event ev
      @delegate.receive_info_event ev ; NEUTRAL_
    end
    end
  end
end
