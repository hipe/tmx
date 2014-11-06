module Skylab::BeautySalon

  class Models_::Search_and_Replace

    Preview_Agent_Children__ = ::Module.new

    class Preview_Agent_Children__::Files_Agent < Leaf_Agent_

      def orient_self
        o = @parent.parent
        @dirs_agent = o[ :dirs ]
        @files_agent = o[ :files ]
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
        @glob_list = @files_agent.glob_list
        @path_list = @dirs_agent.path_list
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
        change_agent_to @parent  # necessary, else loop forever
      end
    end

    class Group_Controller_

      def initialize i_a, node
        @active_toggle = nil
        @has_active_toggle = false
        @i_a = i_a
        @node = node
      end

      attr_reader :active_toggle, :has_active_toggle

      def activate name_i
        @active_toggle = @has_active_toggle = nil
        @i_a.each do |i|
          toggle = @node[ i ]
          if name_i == i
            _ok = if toggle.is_activated
              true
            else
              toggle.activate
            end
            if _ok
              @has_active_toggle = true
              @active_toggle = toggle
            end
          else
            if toggle.is_activated
              toggle.deactivate
            end
          end
        end
        nil
      end
    end

    class Toggle_ < Leaf_Agent_

      def initialize group, parent
        @group = group
        @is_activated = false
        super parent
      end

      attr_reader :is_activated

      def execute
        @group.activate name_i
        change_agent_to @parent
      end

      def activate
        @is_activated = true
        ACHIEVED_
      end

      def deactivate
        @is_activated = false
        ACHIEVED_
      end
    end

    class Preview_Agent_Children__::Matches_Agent < Branch_Agent_

      def orient_self
        @fa = @parent.lower_files_agent
        @sa = @parent.parent[ :search ]
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

      def prepare_for_UI
        @files_agent_group = group = Group_Controller_.new [ :grep, :ruby ], self
        @children = [
          Up_Agent_.new( self ),
          Grep_Agent__.new( group, self ),
          Ruby_Agent__.new( group, self ),
          Files_Agent__.new( self ),
          ca = Counts_Agent__.new( self ),
          Matches_Agent__.new( self ),
          Replace_Agent__.new( self ),
          Quit_Agent_.new( self ) ]
        ca.orient_self
        ACHIEVED_
      end

      attr_reader :files_agent_group

      def display_body  # :+#aesthetics :/
        @serr.puts
        super
        @serr.puts
      end

      class Grep_Agent__ < Toggle_

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
          @regex = @parent.parent.parent[ :search ].regexp
          @regex && ok
        end

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

      class Ruby_Agent__ < Toggle_

        def to_body_item_value_string
          if @is_activated
            "ON - matching files will be searched for using ruby."
          else
            "(turn on using ruby (not grep) to find matching files)"
          end
        end
      end

      class Similar__ < Leaf_Agent_

        def initialize x
          super
          @files_agent_group = @parent.files_agent_group
        end

        def to_body_item_value_string
          if is_executable
            to_body_item_value_string_if_executable
          end
        end

        def is_executable
          @files_agent_group.has_active_toggle
        end
      end

      class Files_Agent__ < Similar__

        def to_body_item_value_string_if_executable
          'list the matching filenames (but not the strings)'
        end

        def execute
          @scan = @files_agent_group.active_toggle.build_path_scan
          @scan and via_scan
          change_agent_to @parent
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
      end

      class Counts_Agent__ < Branch_Agent_

        def orient_self
          @grep_agent = @parent[ :grep ]
        end

        def to_body_item_value_string
          if is_executable
            "the grep --count option - \"Only a count of selected lines ..\""
          end
        end

        def is_executable
          @grep_agent.is_activated
        end

        def execute
          @scan = @grep_agent.build_counts_scan
          @scan and via_scan
          change_agent_to @parent
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
      end

      class Matches_Agent__ < Similar__

        def to_body_item_value_string_if_executable
          'see the matching strings (not just files)'
        end
      end

      class Replace_Agent__ < Similar__

        def to_body_item_value_string_if_executable
          'yeah.'
        end
      end
    end
  end
end
