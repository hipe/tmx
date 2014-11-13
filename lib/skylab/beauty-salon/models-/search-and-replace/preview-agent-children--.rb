module Skylab::BeautySalon

  class Models_::Search_and_Replace

    Preview_Agent_Children__ = ::Module.new  # notes stowed away in [#016]

    class Preview_Agent_Children__::Files_Agent < Leaf_Agent_

      def orient_self
        @dirs_field = @parent.dirs_field
        @files_field = @parent.files_field
        nil
      end

      def to_body_item_value_string
        "previews all files matched by the `find` query"
      end

      def execute
        @cmd = build_command do | *, & ev_p |
          send_event ev_p[]
        end
        @cmd && via_command_execute
      end

      def build_command & maybe_p
        ok = refresh_values
        ok and via_fresh_values_build_command( & maybe_p )
      end

    private

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
          :on_event_selectively, maybe_p,
          :as_normal_value, IDENTITY_ )
      end

      def via_command_execute
        @scan = @cmd.to_scan
        @scan and via_scan
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
      end
    end

    class Boolean_Group_Controller_

      def initialize i_a, group_name_i, node
        @active_boolean = nil
        @group_name = Callback_::Name.via_variegated_symbol group_name_i
        @has_active_boolean = false
        @i_a = i_a
        @node = node
      end

      attr_reader :active_boolean, :has_active_boolean

      def activate name_i
        change_did_occur = maybe_activate name_i
        if change_did_occur
          when_changed
        else
          when_not_changed
        end
      end

    private

      def maybe_activate name_i  # no not trigger persistence from here
        @active_boolean = @has_active_boolean = nil
        change_did_occur = false
        @first = nil
        @i_a.each do |i|
          boolean = @node[ i ]
          @first ||= boolean
          if name_i == i
            if boolean.is_activated
              ok = true
            else
              ok = boolean.receive_activation
              if ok
                change_did_occur = true
              end
            end
            if ok
              @has_active_boolean = true
              @active_boolean = boolean
            end
          elsif boolean.is_activated
            _ok = boolean.receive_deactivation
            _ok and change_did_occur = true
          end
        end
        change_did_occur
      end

      def when_not_changed
        @node.change_focus_to @node
      end

      def when_changed
        @node.receive_branch_changed_notification
        @node.change_focus_to @node
      end

    public  # #note-122

      def is_executable
      end

      def marshal_load name_of_active_child_string, & ev_p
        name_i = name_of_active_child_string.intern
        _ok = @node.has_name name_i
        if _ok
          _change_did_occur = maybe_activate name_i
          _change_did_occur  # kinda nasty - this becomes 'OK'
        else
          when_marshal_load_fail name_i, ev_p
        end
      end

      def name_i
        @group_name.as_variegated_symbol
      end

      def to_body_item_value_string
      end

      def to_marshal_pair
        if @has_active_boolean
          Callback_.pair.new @active_boolean.name_i, @group_name.as_slug.intern
        end
      end

    private

      def when_marshal_load_fail name_i, ev_p
        ev_p.call :error, :marshal_load_error do
          self._ETC  # #todo
        end
        UNABLE_
      end
    end

    class Boolean_ < Leaf_Agent_

      def initialize group, parent
        @group = group
        @is_activated = false
        super parent
      end

      attr_reader :is_activated

      def execute
        @group.activate name_i
      end

      def receive_activation
        @is_activated = true
        ACHIEVED_
      end

      def receive_deactivation
        @is_activated = false
        ACHIEVED_
      end

      def to_marshal_pair  # the group controller does this
      end
    end

    class Preview_Agent_Children__::Matches_Agent < Branch_Agent_

      def orient_self
        @fa = @parent.lower_files_agent
        @sa = @parent.regexp_field
        nil
      end

      def to_body_item_value_string
        if is_executable
          "different ways to achieve, manipulate matching files, strings"
        end
      end

      def is_executable
        @sa.value_is_known
      end

      def prepare_UI
        grp = Boolean_Group_Controller_.new [ :grep, :ruby ], :grep_via, self
        @paths_agent_group = grp
        gbf = Grep_Boolean__.new grp, self
        @grep_boolean_field = gbf
        _rbf = Ruby_Boolean__.new grp, self

        @children = [
          Up_Button_.new( self ),
          gbf,
          _rbf,
          Files_Agent__.new( self ),
          Counts_Agent__.new( self ),
          Matches_Agent__.new( self ),
          Replace_Agent__.new( self ),
          Quit_Button_.new( self ),
          grp ]

        retrieve_values_from_FS_if_exist
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
        receive_try_to_persist
        nil
      end

      class Grep_Boolean__ < Boolean_

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
            :on_event_selectively, -> *, & ev_p do
              send_event ev_p[]
            end )
        end
      end

      class Ruby_Boolean__ < Boolean_

        def to_body_item_value_string
          if @is_activated
            "ON - matching files will be searched for using ruby."
          else
            "(turn on using ruby (not grep) to find matching files)"
          end
        end
      end

      class Paths_Depender__ < Agent_

        def initialize x
          super
          @paths_agent_group = @parent.paths_agent_group
        end

        def to_body_item_value_string
          if is_executable
            to_body_item_value_string_if_executable
          end
        end

        def is_executable
          @paths_agent_group.has_active_boolean
        end
      end

      class Files_Agent__ < Paths_Depender__

        def to_body_item_value_string_if_executable
          'list the matching filenames (but not the strings)'
        end

        def execute
          @scan = @paths_agent_group.active_boolean.build_path_scan
          @scan and via_scan
          change_focus_to @parent
        end

      private

        def via_scan
          count = 0
          line =  @scan.gets
          while line
            count += 1
            @serr.puts line
            line = @scan.gets
          end
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

      class Counts_Agent__ < Branch_Agent_  # (grep only)

        def initialize x
          super
          @grep_boolean_field = @parent.grep_boolean_field
        end

        def to_body_item_value_string
          if is_executable
            "the grep --count option - \"Only a count of selected lines ..\""
          end
        end

        def is_executable
          @grep_boolean_field.is_activated
        end

        def execute
          @scan = @grep_boolean_field.build_counts_scan
          @scan and via_scan
          change_focus_to @parent
        end

      private

        def via_scan
          match_count = file_count = 0
          item = @scan.gets
          while item
            file_count += 1
            match_count += item.count
            @serr.puts "#{ item.path }:#{ item.count }"
            item = @scan.gets
          end
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

      class Matches_Depender__ < Paths_Depender__

        def execute
          if resolve_file_scan
            execute_via_file_scan
          else
            change_focus_to @parent
          end
        end

      private

        def resolve_file_scan
          ok = refresh_file_scan_ivars
          ok && via_file_scan_ivars_resolve_file_scan
        end

        def refresh_file_scan_ivars
          @path_scan = @paths_agent_group.active_boolean.build_path_scan
          @regex = @parent.regexp_field.regexp
          @path_scan && @regex && ACHIEVED_
        end
      end

      class Matches_Agent__ < Matches_Depender__

        def to_body_item_value_string_if_executable
          'see the matching strings (not just files)'
        end

        def execute_via_file_scan
          while file = @file_scan.gets
            scn = file.to_read_only_match_scan
            while match = scn.gets
              @serr.puts match.render_line
            end
          end
          change_focus_to @parent
        end

        def via_file_scan_ivars_resolve_file_scan
          @file_scan = S_and_R_::Actors_::Build_file_scan.with(
            :upstream_path_scan, @path_scan,
            :ruby_regexp, @regex,
            :do_highlight, @serr.tty?,
            :read_only,
            :on_event_selectively, -> *, & ev_p do
              send_event ev_p[]
            end )
          @file_scan && ACHIEVED_
        end

        def to_marshal_pair
        end
      end

      class Replace_Agent__ < Matches_Depender__

        def to_body_item_value_string_if_executable
          "begin interactive search and replace yay!"
        end

        def is_executable
          super and  # from paths depender
            @parent.replace_field.value_is_known
        end

        def via_file_scan_ivars_resolve_file_scan
          @file_scan = S_and_R_::Actors_::Build_file_scan.with(
            :for_interactive_search_and_replace,
            :upstream_path_scan, @path_scan,
            :ruby_regexp, @regex,
            :do_highlight, @serr.tty?,
            :on_event_selectively, -> *, & ev_p do
              send_event ev_p[]
            end )
          @file_scan && ACHIEVED_
        end

        def execute_via_file_scan
          @current_file_ES = @file_scan.gets
          @next_file_ES = @file_scan.gets
          if @current_file_ES
            when_one_file
          else
            when_no_files
          end
        end

        def to_marshal_pair
        end

      private

        def when_one_file
          @edit_file_agent = nil
          begin
            @stay_in_loop = false
            @edit_file_agent ||= build_edit_file_agent
            signal = change_focus_to @edit_file_agent
            if AS_IS_SIGNAL_ == signal
              signal = @edit_file_agent.execute  # probably blocks waiting for input
            end
            if signal
              send :"when_#{ signal }"
            else
              @result = signal
            end
          end while @stay_in_loop
          @result
        end

        def build_edit_file_agent
          S_and_R_::Edit_File_Agent__.new @current_file_ES,
            @next_file_ES ? true : false,
            self
        end

        # ~ signals

        def when_as_is_signal  # you will get this e.g when the agent
          # receives ambiguous or unresolvable input (and reports it).
          # in such cases we want to stay truly as-is, which means:
          when_stay_with_file_signal
        end


        def when_finished_signal
          @serr.puts "finished."
          @result = nil
          nil
        end

        def when_next_file_signal
          @edit_file_agent = nil
          @current_file_ES = @next_file_ES
          if @current_file_ES
            @stay_in_loop = true
            @next_file_ES = @file_scan.gets
          else
            @result = when_no_files
            @next_file_ES = nil
          end
          nil
        end

        def when_stay_with_file_signal
          @stay_in_loop = true
          nil
        end

        # ~ end signals

        def when_no_files
          @serr.puts
          @serr.puts "                     (no matching files found)"  # example of smelly but prettier UI string
          change_focus_to @parent
        end
      end
    end
  end
end
