module Skylab::BeautySalon

  class Models_::Search_and_Replace

    Preview_Agent_Children__ = ::Module.new  # notes stowed away in [#016] (as 2)

    class Preview_Agent_Children__::Files_Node < Field_

      def is_terminal_node
        true
      end

      def orient_self
        @dirs_field = @parent.dirs_field
        @files_field = @parent.files_field
        nil
      end

      def to_body_item_value_string_when_can_receive_focus
        "previews all files matched by the `find` query"
      end

      def receive_focus
        resolve_command
        @cmd && via_command_execute
      end

      def build_command & maybe_p
        ok = refresh_values
        ok and via_fresh_values_build_command( & maybe_p )
      end

    private

      alias_method :against_empty_iambic_stream, :receive_focus

      def resolve_command
        @cmd = build_command( & handle_unsigned_event_selectively )
        nil
      end

      def refresh_values
        @glob_list = @files_field.glob_list
        @path_list = @dirs_field.path_list
        @glob_list && @glob_list.length.nonzero? &&
          @path_list && @path_list.length.nonzero?
      end

      def via_fresh_values_build_command & maybe_p
        BS_::Lib_::System[].filesystem.find(
          :filenames, @glob_list,
          :paths, @path_list,
          :freeform_query_infix, '-type f',
          :on_event_selectively, maybe_p,
          :as_normal_value, IDENTITY_ )
      end

      def via_command_execute
        @scan = @cmd.to_scan
        if @is_interactive
          @scan and via_scan
        else
          @scan
        end
      end

      def via_scan
        count = 0
        while line = @scan.gets
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
    end

    class Preview_Agent_Children__::Matches_Node < Branch_

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

      def prepare_for_focus
        grp = Zerk_::Enumeration_Group.new [ :grep, :ruby ], :grep_via, self
        @paths_agent_group = grp
        gbf = Grep_Boolean__.new grp, self
        @grep_boolean_field = gbf
        _rbf = Ruby_Boolean__.new grp, self

        @children = [
          Up_Button_.new( self ),
          gbf,
          _rbf,
          Files_Node__.new( self ),
          Counts_Node__.new( self ),
          Matches_Node__.new( self ),
          Replace_Node__.new( self ),
          Quit_Button_.new( self ),
          grp ]

        if @is_interactive
          retrieve_values_from_FS_if_exist
        end

        ACHIEVED_
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

      class Grep_Boolean__ < Zerk_::Boolean

        include Node_Methods_

        def to_body_item_value_string
          if @is_activated
            "ON - matching files will be searched for using grep."
          else
            "(turn on using grep (not ruby) to find matching files)"
          end
        end

        def build_counts_scan
          ok = refresh_ivars
          ok and via_ivars_build_path_scan_for :counts
        end

        def build_path_scan
          ok = refresh_ivars
          ok and via_ivars_build_path_scan_for :paths
        end

        def refresh_ivars
          ok = refresh_upstream_path_scan
          @regex = @parent.regexp_field.regexp
          @regex && ok
        end

        attr_reader :regex

        def refresh_upstream_path_scan
          cmd = @parent.parent[ :files ].build_command do end
          @upstream_path_scan = cmd && cmd.to_scan
          @upstream_path_scan ? ACHIEVED_ : UNABLE_
        end

        def via_ivars_build_path_scan_for mode_i
          S_and_R_::Actors_::Build_grep_path_scan.with(
            :upstream_path_scan, @upstream_path_scan,
            :ruby_regexp, @regex,
            :mode, mode_i,
            :on_event_selectively, handle_unsigned_event_selectively )
        end

        def release_resources
          @upstream_path_scan.receive_signal :release_resource
        end
      end

      class Ruby_Boolean__ < Zerk_::Boolean

        include Node_Methods_

        def to_body_item_value_string
          if @is_activated
            "ON - matching files will be searched for using ruby."
          else
            "(turn on using ruby (not grep) to find matching files)"
          end
        end

        def build_path_scan
          maybe_send_event :error do
            BS_::Lib_::Event_lib[].inline_not_OK_with(
              :not_yet_implemented, :method_name, :build_path_scan )
          end
          UNABLE_
        end
      end

      class Files_Node__ < Node_

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
          @scan = against_empty_iambic_stream
          @scan and via_scan
          change_focus_to @parent
          ACHIEVED_
        end

      private

        def against_empty_iambic_stream
          @paths_agent_group.active_boolean.build_path_scan
        end

        def via_scan
          count = 0
          line =  @scan.gets
          while line
            count += 1
            @serr.puts line
            line = @scan.gets
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

      class Counts_Node__ < Node_  # (grep only)

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
          @scan = @grep_boolean_field.build_counts_scan
          @scan and via_scan
          change_focus_to @parent
          ACHIEVED_
        end

      private

        def against_empty_iambic_stream
          @grep_boolean_field.build_counts_scan
        end

        def via_scan
          match_count = file_count = 0
          item = @scan.gets
          while item
            file_count += 1
            match_count += item.count
            @serr.puts "#{ item.path }:#{ item.count }"
            item = @scan.gets
          end
          @serr.puts
          y = @y
          expression_agent.calculate do
            y << "(#{ match_count } match#{ s match_count, :es } #{
              }in #{ file_count } file#{ s file_count })"
          end
          nil
        end

      public
        def to_marshal_pair
        end
      end

      class Matches_Node__ < Node_

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
          resolve_file_scan && execute_via_file_scan_when_interactive
        end

        def to_marshal_pair
        end

      private

        def against_empty_iambic_stream
          resolve_file_scan && execute_via_file_scan_when_non_interactive
        end

        def resolve_file_scan
          rslv_file_scan_ivars && via_file_scan_ivars_resolve_file_scan
        end

        def rslv_file_scan_ivars
          @path_scan = @paths_agent_group.active_boolean.build_path_scan
          @regex = @parent.regexp_field.regexp
          @path_scan && @regex && ACHIEVED_
        end

        def via_file_scan_ivars_resolve_file_scan
          @file_scan = S_and_R_::Actors_::Build_file_scan.with(
            :upstream_path_scan, @path_scan,
            :ruby_regexp, @regex,
            :do_highlight, ( @is_interactive && @serr.tty? ),
            for_interactive_search_and_replace_or_read_only,
            :on_event_selectively, handle_unsigned_event_selectively )
          @file_scan && ACHIEVED_
        end

        def for_interactive_search_and_replace_or_read_only
          :read_only
        end

        def execute_via_file_scan_when_interactive

          @serr.puts  # :+#aesthetics :/

          file = @file_scan.gets
          if file
            did_see = true
          end

          while file
            scn = file.to_read_only_match_scan
            while match = scn.gets
              @serr.puts match.render_line
            end
            file = @file_scan.gets
          end

          if ! did_see
            @y << "no files match against the pattern."
          end

          change_focus_to @parent
          ACHIEVED_
        end

        def execute_via_file_scan_when_non_interactive
          @file_scan.expand_by do |file|
            file.to_read_only_match_scan
          end
        end
      end

      class Replace_Node__ < Matches_Node__

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
            @next_file_ES = @file_scan.gets
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
              es = @file_scan.gets
              es or break
            end until es.has_at_least_one_match

            es or break
            match_d = 0

          end while true

          if @is_interactive
            y = @y
            expression_agent.calculate do
              y << "finished (#{ file_count } #{ plural_noun 'file', file_count } total)."
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
                "#{ used_match_d } #{ plural_noun 'change', seen_match_d }"
              else
                "#{ used_match_d } of #{ seen_match_d } #{
                  }#{ plural_noun 'match', seen_match_d }"
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
          ok_ = @path_scan.receive_signal :release_resource
          ok && ok_ and begin
            if @is_interactive
              @y << "(released any `find` or `grep` resources.)"
            end
            ACHIEVED_
          end
        end

      private

        def execute_via_file_scan_when_interactive
          @current_file_ES = @file_scan.gets
          @next_file_ES = @file_scan.gets
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

        def execute_via_file_scan_when_non_interactive

          func = replace_function

          write_file = curry_file_writer(
            BS_::Lib_::System[].defaults.dev_tmpdir_path,
            handle_unsigned_event_selectively )

          @file_scan.expand_by do |edit_session|
            Callback_.scan do
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

        def curry_file_writer tmpdir_path, oes=nil
          -> edit_session, oes_=oes do
            S_and_R_::Actors_::Write_any_changed_file.with(
              :edit_session, edit_session,
              :work_dir_path, tmpdir_path,
              :is_dry_run, false,
              :on_event_selectively, oes_ )
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
          S_and_R_::Edit_File_Agent__.new @current_file_ES,
            @next_file_ES ? true : false,
            self
        end
      end
    end
  end
end
