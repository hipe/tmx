module Skylab::BeautySalon

  module Models_::Search_and_Replace

     # notes stowed away in [#016] (as 2)

    here = ::Module.new

    Reactive_Nodes_ = here

      def via_stream
        count = 0
        while line = @stream.gets
          count += 1
          @serr.puts line
        end
        y = @y
        expression_agent.calculate do
          y << "(#{ count } file#{ s count } total)"
        end
        change_focus_to @parent  # necessary, else loop forever
        ACHIEVED_
      end

    class here::Matches_Node < Branch_

      def initialize( * )
        @has_path = false
        super
      end

      def orient_self
        @fa = @parent.lower_files_agent
        @rf = @parent.regexp_field
        nil
      end

      def to_body_item_value_string_when_can_receive_focus
        "different ways to achieve, manipulate matching files, strings"
      end

      def can_receive_focus
        @rf.value_is_known
      end

      def receive_path___ x

        if x
          @gbf = @rbf = @pag = nil
          @has_path = true
          @paths_agent_group = Explicit_Path___.new x
          ACHIEVED_
        else
          @has_path = @paths_agent_group = x
        end
      end

      attr_reader :has_path

      class Explicit_Path___
        def initialize s
          @path = s
        end
        def has_active_boolean
          true
        end
        def active_boolean
          self
        end
        def build_path_stream
          Callback_::Stream.via_item @path
        end
      end

      def prepare_for_focus

        if ! @has_path
          __init_paths_agent_group
        end

        @children = [
          Up_Button_.new( self ),
          * @gbf,
          * @rbf,
          Files_Node__.new( self ),
          Counts_Node__.new( self ),
          Matches_Node__.new( self ),
          Replace_Node__.new( self ),
          Quit_Button_.new( self ),
          * @pag ]

        if @is_interactive
          retrieve_values_from_FS_if_exist
        end

        ACHIEVED_
      end

      def __init_paths_agent_group

        grp = Zerk_::Enumeration_Group.new [ :grep, :ruby ], :grep_via, self
        @paths_agent_group = grp
        @gbf = Grep_Boolean__.new grp, self
        @grep_boolean_field = @gbf
        @rbf = Ruby_Boolean__.new grp, self
        @pag = grp
        NIL_
      end

      attr_reader :paths_agent_group, :grep_boolean_field

      def display_body  # :+#aesthetics :/
        @serr.puts
        super
        @serr.puts
      end

      def to_marshal_pair
      end

      # ~ public API for children calling up to us as parent

      def receive_branch_changed_notification
        if @is_interactive
          receive_try_to_persist
        end
        nil
      end

      class Grep_Boolean__ < Zerk_::Boolean  # BLAH:69

        include Node_Methods_

        def to_body_item_value_string
          if @is_activated
            "ON - matching files will be searched for using grep."
          else
            "(turn on using grep (not ruby) to find matching files)"
          end
        end

        def build_counts_stream
          ok = refresh_ivars
          ok and via_ivars_build_path_stream_for :counts
        end

        def build_path_stream
          ok = refresh_ivars
          ok and via_ivars_build_path_stream_for :paths
        end

        def refresh_ivars
          ok = refresh_upstream_path_stream
          ok and resolve_regexp_pair_array
        end

        def resolve_regexp_pair_array
          grx_fld = @parent.grep_rx_field
          if grx_fld.value_is_known
            @regexp_pair_a = [ :grep_extended_regexp_string, grx_fld.value_string ]
            ACHIEVED_
          elsif (( fld = @parent.regexp_field )).value_is_known
            @regexp_pair_a = [ :ruby_regexp, fld.regexp ]
            ACHIEVED_
          end
        end

        def refresh_upstream_path_stream
          cmd = @parent.parent[ :files ].build_command do end
          @upstream_path_stream = cmd && cmd.to_path_stream
          @upstream_path_stream ? ACHIEVED_ : UNABLE_
        end

        def via_ivars_build_path_stream_for mode_i

          S_and_R_::Magnetics_::Build_grep_path_stream.with(
            :upstream_path_stream, @upstream_path_stream,
            * @regexp_pair_a,
            :mode, mode_i,
            & method( :maybe_receive_grep_event ) )
        end

        def maybe_receive_grep_event * i_a, & ev_p
          if :grep_command_head == i_a.last && @is_interactive
            ev = ev_p[]
            @serr.puts
            @y << "(grep command head: #{ ev.command_head })"
            ev.ok
          else
            maybe_send_event_via_channel i_a, & ev_p
          end
        end

        def release_resources

          @upstream_path_stream.upstream.release_resource
        end
      end

      class Ruby_Boolean__ < Zerk_::Boolean  # BLAH:20

        include Node_Methods_

        def to_body_item_value_string
          if @is_activated
            "ON - matching files will be searched for using ruby."
          else
            "(turn on using ruby (not grep) to find matching files)"
          end
        end

        def build_path_stream
          maybe_send_event :error do
            Callback_::Event.inline_not_OK_with(
              :not_yet_implemented, :method_name, :build_path_stream )
          end
          UNABLE_
        end
      end

      class Files_Node__ < Node_  # BLAH:52

        def initialize x
          super
          @paths_agent_group = @parent.paths_agent_group
        end

        def to_body_item_value_string_when_can_receive_focus
          'list the matching filenames (but not the strings)'
        end

        def can_receive_focus
          @paths_agent_group.has_active_boolean
        end

        def is_terminal_node
          true
        end

        def receive_focus
          @stream = against_empty_polymorphic_stream
          @stream and via_stream
          change_focus_to @parent
          ACHIEVED_
        end

      private

        def against_empty_polymorphic_stream
          @paths_agent_group.active_boolean.build_path_stream
        end

        def via_stream
          count = 0
          line =  @stream.gets
          while line
            count += 1
            @serr.puts line
            line = @stream.gets
          end
          @serr.puts
          y = @y
          expression_agent.calculate do
            y << "(#{ count } file#{ s count } total)"
          end
          nil
        end

      public
        def to_marshal_pair
        end
      end

      class Counts_Node__ < Node_  # (grep only)  BLAH:57

        def initialize x
          super
          @grep_boolean_field = @parent.grep_boolean_field
        end

        def is_terminal_node
          true
        end

        def to_body_item_value_string_when_can_receive_focus
          "the grep --count option - \"Only a count of selected lines ..\""
        end

        def can_receive_focus
          @grep_boolean_field.is_activated
        end

        def receive_focus
          @stream = @grep_boolean_field.build_counts_stream
          @stream and via_stream
          change_focus_to @parent
          ACHIEVED_
        end

      private

        def against_empty_polymorphic_stream
          @grep_boolean_field.build_counts_stream
        end

        def via_stream
          match_count = file_count = 0
          item = @stream.gets
          while item
            file_count += 1
            match_count += item.count
            @serr.puts "#{ item.path }:#{ item.count }"
            item = @stream.gets
          end
          @serr.puts
          y = @y

          expression_agent.calculate do

            y << "(#{ np_ match_count, 'match' } in #{ np_ file_count, 'file' })"

              # e.g. "(X matches in Y files)"
          end
          nil
        end

      public
        def to_marshal_pair
        end
      end

      class Matches_Node__ < Node_  # BLAH:143

        def initialize x
          super
          @paths_agent_group = @parent.paths_agent_group
        end

        def can_receive_focus
          @paths_agent_group.has_active_boolean
        end

        def is_terminal_node
          true
        end

        def to_body_item_value_string_when_can_receive_focus
          'see the matching strings (not just files)'
        end

        def receive_focus
          resolve_file_stream && execute_via_file_stream_when_interactive
        end

        def to_marshal_pair
        end

      private

        def against_empty_polymorphic_stream
          resolve_file_stream && execute_via_file_stream_when_non_interactive
        end

        def resolve_file_stream
          rslv_file_stream_ivars && via_file_stream_ivars_resolve_file_stream
        end

        def rslv_file_stream_ivars
          @path_stream = @paths_agent_group.active_boolean.build_path_stream
          @path_stream && resolve_regexp_ivars
        end

        def resolve_regexp_ivars

          fld = @parent.regexp_field
          if fld.value_is_known
            grx_fld = @parent.grep_rx_field
            @gers = if grx_fld.value_is_known
              grx_fld.value_string
            end
            @rrx = fld.regexp
            ACHIEVED_
          end
        end

        def via_file_stream_ivars_resolve_file_stream

          _do_highlight = @is_interactive && @serr.tty?
          _oes_p = handle_unsigned_event_selectively

          @file_stream = S_and_R_::Magnetics_::File_Stream_via_Parameters.with(
            :upstream_path_stream, @path_stream,
            :ruby_regexp, @rrx,
            :grep_extended_regexp_string, @gers,
            :do_highlight, _do_highlight,
            for_interactive_search_and_replace_or_read_only,
            & _oes_p )

          @file_stream && ACHIEVED_
        end

        def for_interactive_search_and_replace_or_read_only
          :read_only
        end

        def execute_via_file_stream_when_interactive

          @serr.puts  # :+#aesthetics :/

          file = @file_stream.gets
          if file
            did_see_file = true
          end

          file_count = 0
          while file
            file_count += 1
            scn = file.to_read_only_match_stream
            match = scn.gets
            if match
              did_see_match = true
              display_matches match, scn
            end
            file = @file_stream.gets
          end

          summarize did_see_file, did_see_match, file_count

          change_focus_to @parent
          ACHIEVED_
        end

        def display_matches match, scn
          @match_path = match.path
          @subsequent_line_header = "#{ SPACE_ * ( @match_path.length + 1 ) }"  # for colon
          begin
            display_match match
            match = scn.gets
          end while match
        end

        def display_match match
          stream = match.to_line_stream
          current_line = match.lineno
          line = stream.gets
          @serr.puts "#{ @match_path }:#{ current_line }:#{ line }"
          while line = stream.gets
            current_line += 1
            @serr.puts "#{ @subsequent_line_header }#{ current_line }:#{ line }"
          end
        end

        def summarize did_see_file, did_see_match, file_count
          if ! did_see_file
            @y << "no files match against the grep pattern"
          elsif ! did_see_match
            y = @y
            expression_agent.calculate do
              if 1 == file_count
                y << "in the 1 file that was opened, there were no matches"
              else
                y << "none of the #{ file_count } #{
                  }#{ plural_noun file_count, 'file' } matched the pattern"
              end
            end
          end ; nil
        end

        def execute_via_file_stream_when_non_interactive
          @file_stream.expand_by do |file|
            file.to_read_only_match_stream
          end
        end
      end

      class Replace_Node__ < Matches_Node__  # BLAH: 233

        def to_body_item_value_string_when_can_receive_focus
          "begin interactive search and replace yay!"
        end

        def can_receive_focus
          super && @parent.replace_field.value_is_known
        end

        def to_marshal_pair
        end

        def receive_focus  # #note-372
          ok = super
          if ok
            while @node_with_focus
              @node_with_focus.before_focus
              ok = @node_with_focus.receive_focus
              ok or break
            end
          end
          ok
        end

        # ~ API for children

        def change_focus_to x
          @node_with_focus = x
          nil
        end

        def next_file_or_finished
          if @next_file_ES
            @current_file_ES = @next_file_ES
            @next_file_ES = @file_stream.gets
            @node_with_focus = build_edit_file_agent
            ACHIEVED_
          else
            @y << "finished."
            FINISHED_
          end
        end

        def engage_all_remaining_matches_in_all_remaining_files_via match_d, es  # big ball of meh

          @is_interactive and @serr.puts

          func = replace_function
          oes = @parent.handle_event_selectively_via_channel
          write_file = curry_file_writer work_dir
          ok = true
          file_count = 0

          begin  # while edit session with at least one match

            file_count += 1
            match = es.match_at_index match_d
            seen_match_count = used_match_count = 0

            begin  # while match

              seen_match_count += 1
              string = func.call match.md
              if string
                used_match_count += 1
                match.set_replacement_string string
              end

              match = es.match_at_index( match_d += 1 )

            end while match

            ok = write_file.call es, -> * i_a, & ev_p do
              oes.call i_a do
                ev = ev_p[]
                if :changed_file == ev.terminal_channel_i
                  ev = add_changes_info_to_event(
                    used_match_count, seen_match_count, file_count, ev )
                end
                ev
              end
            end
            ok or break

            begin
              es = @file_stream.gets
              es or break
            end until es.has_at_least_one_match

            es or break
            match_d = 0

          end while true

          if @is_interactive
            y = @y
            expression_agent.calculate do
              y << "finished (#{ file_count } #{ plural_noun file_count, 'file' } total)."
            end
            change_focus_to nil
            @parent.change_focus_to @parent
          end

          ok
        end

      private

        def add_changes_info_to_event used_match_d, seen_match_d, file_d, ev

          ev = ev.with_message_string_mapper -> msg, d do
            if d.zero?
              _changes = if used_match_d == seen_match_d
                "#{ used_match_d } #{ plural_noun seen_match_d, 'change' }"
              else
                "#{ used_match_d } of #{ seen_match_d } #{
                  }#{ plural_noun seen_match_d, 'match' }"
              end
              "file #{ file_d }: #{ _changes }. #{ msg }"
            else
              msg
            end
          end
        end

      public

        def go_up
          release_resources  # might fail but we ignore anyway
          @node_with_focus = nil  # we break out of our own loop with this

          # and in the parent loop we don't want to be doing "replace" any more
          @parent.change_focus_to @parent
          ACHIEVED_
        end

        def release_resources

          ok = @paths_agent_group.active_boolean.release_resources
          ok_ = @path_stream.upstream.release_resource
          ok && ok_ and begin
            if @is_interactive
              @y << "(released any `find` or `grep` resources.)"
            end
            ACHIEVED_
          end
        end

      private

        def execute_via_file_stream_when_interactive
          @current_file_ES = @file_stream.gets
          @next_file_ES = @file_stream.gets
          if @current_file_ES
            when_files
          else
            when_no_file
          end
        end

        def when_no_file
          @serr.puts
          @y << "no matching files."
          change_focus_to nil
          @parent.change_focus_to @parent
          ACHIEVED_
        end

        def execute_via_file_stream_when_non_interactive

          func = replace_function

          write_file = curry_file_writer(
            Home_.lib_.system.defaults.dev_tmpdir_path,
            handle_unsigned_event_selectively )

          @file_stream.expand_by do |edit_session|
            Callback_.stream do
              match = edit_session.gets_match
              if match
                string = func.call match.md
                if string
                  match.set_replacement_string string
                end
                match
              else
                write_file.call edit_session
                nil
              end
            end
          end
        end

        def curry_file_writer tmpdir_path, oes_p=nil

          -> edit_session, oes_p_=oes_p do

            S_and_R_::Magnetics_::Write_any_changed_file.with(
              :edit_session, edit_session,
              :work_dir_path, tmpdir_path,
              :is_dry_run, false,
              & oes_p_ )
          end
        end

        def replace_function
          @parent.replace_field.replace_function
        end

        def for_interactive_search_and_replace_or_read_only
          :for_interactive_search_and_replace
        end

        def when_no_files
          @serr.puts
          @y << "no files."
          change_focus_to @parent
          ACHIEVED_
        end

        def when_files
          @node_with_focus = build_edit_file_agent
          ACHIEVED_
        end

        def build_edit_file_agent
          S_and_R_::Reactive_Nodes_::Edit_File_Node.new @current_file_ES,
            @next_file_ES ? true : false,
            self
        end
      end
    end
  end
end