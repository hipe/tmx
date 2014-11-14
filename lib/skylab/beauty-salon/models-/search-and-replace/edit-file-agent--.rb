module Skylab::BeautySalon

  class Models_::Search_and_Replace

    class Edit_File_Agent__ < Branch_  # notes are stowed away in [#016]

      def initialize edit_session, has_next_file, x
        super x
        @es = edit_session
        @has_next_file = has_next_file

        if @es.has_at_least_one_match
          @has_at_least_one_match = true
          @cm = @es.match_at_index 0
        else
          @has_at_least_one_match = false
        end
      end

    private

      def prepare_UI
        refresh_button_visibilities
        @children = [ Up_Button_.new( 3, self ) ]
        if @has_at_least_one_match
          add_children_when_matches
        end
        @children.push Next_File_Button__.new self
        @children.push Quit_Button_.new self
        ACHIEVED_
      end

      def add_children_when_matches
        a = @children
        a.push Previous_Button__.new self
        a.push Yes_Button__.new self
        a.push Undo_Button__.new self
        a.push Next_Match_Button__.new self
        a.push All_Remaining_in_File_Button__.new self
        a.push Skip_Remaining_in_File_Button__.new self
        a.push Done_with_File_Button__.new self
        nil
      end

      def refresh_button_visibilities
        @do_show_all_remaining_button = false
        @do_show_done_with_file_button = false
        @do_show_next_file_button = false
        @do_show_next_match_button = false
        @do_show_previous_button = false
        @do_show_skip_remaining_in_file_button = false
        @do_show_undo_button = false
        @do_show_yes_button = false
        if @cm
          via_current_match_activate_button_visibilities
        end ; nil
      end

      def via_current_match_activate_button_visibilities

        if @cm.has_next_match

          more_work_remains = !! @cm.next_disengaged_match  # meh

          @do_show_all_remaining_button = more_work_remains

          @do_show_next_match_button = true
          if @has_next_file
            if more_work_remains
              @do_show_skip_remaining_in_file_button = true
            else
              @do_show_done_with_file_button = true
            end
          else
            @do_show_done_with_file_button = true
          end
        elsif @has_next_file
          @do_show_next_file_button = true
        else
          @do_show_done_with_file_button = true
        end

        @do_show_previous_button = @cm.has_previous_match

        if @cm.replacement_is_engaged
          @do_show_undo_button = true
        else
          if @parent.replace_field.value_is_known
            @do_show_yes_button = true
          end
        end ; nil
      end

      def display_body
        if @es.has_at_least_one_match
          if @cm.replacement_is_engaged
            display_body_when_replacement_is_engaged
          else
            display_body_when_replacement_is_not_engaged
          end
        else
          display_body_when_no_matches
        end
        nil
      end

      def display_body_when_no_matches
        io = @serr
        io.puts
        io.puts "file #{ @es.ordinal }: #{ @es.path }"
        io.puts
        io.puts "(has no matches aganst #{ @es.ruby_regexp })"
        io.puts
        nil
      end

      def display_body_when_replacement_is_engaged
        io = @serr
        io.puts
        io.puts "file #{ @es.ordinal } match #{ @cm.ordinal } (replacement engaged): #{ @es.path }"
        io.puts
        display_context_lines
        io.puts
        nil
      end

      def display_body_when_replacement_is_not_engaged
        io = @serr
        io.puts
        io.puts "file #{ @es.ordinal } match #{ @cm.ordinal } (before): #{ @es.path }"
        io.puts
        display_context_lines
        io.puts
        nil
      end

      def display_context_lines

        bf, *rest = @es.context_scanners NUM_LINES_BEFORE__,
          @cm.match_index, NUM_LINES_AFTER__

        line_cache = []
        while _segmented_line = bf.gets
          line_cache.push _segmented_line
        end
        num_before_lines = line_cache.length
        rest.each do |scan|
          while segmented_line = scan.gets
            line_cache.push segmented_line
          end
        end

        match_line_num = @cm.first_line_number
        first_context_line_num = match_line_num - num_before_lines
        highest_line_number = match_line_num - 1 - num_before_lines + line_cache.length

        fmt = " %#{ highest_line_number.to_s.length }d: %s"

        line_cache.each_with_index do |segmented_line, d|

          _line_no = first_context_line_num + d

          _part_s_a = segmented_line.map do |seg|
            case seg.category
            when :normal
              seg.string
            when :original
              BS_::Lib_::CLI_lib[].pen.stylify ORIGINAL_STYLE__, seg.string
            when :replacement
              BS_::Lib_::CLI_lib[].pen.stylify REPLACEMENT_STYLE__, seg.string
            end
          end

          @serr.puts ( fmt % [ _line_no, _part_s_a.join( EMPTY_S_ ) ] )

        end
        nil

      end

      NUM_LINES_BEFORE__ = NUM_LINES_AFTER__ = 2

      ORIGINAL_STYLE__ = [ :strong, :green ]

      REPLACEMENT_STYLE__ = [ :strong, :blue ]

      public  # ~ public API for our children (buttons)

      def current_match
        @cm
      end

      attr_reader(
        :do_show_all_remaining_button,
        :do_show_done_with_file_button,
        :do_show_next_file_button,
        :do_show_next_match_button,
        :do_show_previous_button,
        :do_show_skip_remaining_in_file_button,
        :do_show_undo_button,
        :do_show_yes_button )

      def engage_all_remaining_matches  # assume same as next method. see.
        ok = true
        func = @parent.replace_field.replace_function

        do_loop = if @cm.replacement_is_engaged
          cm = @cm.next_disengaged_match
          if cm
            @cm = cm
            true
          end
        else
          true
        end

        while do_loop
          new_string = func.call @cm.md
          if new_string
            @cm.set_replacement_string new_string
          else
            ok = new_string  # or not
            break
          end
          cm = @cm.next_disengaged_match
          if cm
            @cm = cm
          else
            break
          end
        end

        while cm = @cm.next_match
          @cm = cm
        end

        refresh_button_visibilities
        ok
      end

      def engage_replacement_of_current_match  # assume: replace function..
        # ..value is known, current match exists.
        # we could weirdly cache the replacement string and re-use it but meh
        _func = @parent.replace_field.replace_function
        new_string = _func.call @cm.md
        if new_string
          @cm.set_replacement_string new_string
          refresh_button_visibilities
          # we stay here so the user can see the change that occurred
        end  # we hope that the function emitted a reason
        nil
      end

      def disengage_replacement_of_current_match
        @cm.disengage_replacement
        refresh_button_visibilities
        nil
      end

      def go_to_next_match
        @cm = @cm.next_match
        refresh_button_visibilities
        nil
      end

      def go_to_previous_match
        @cm = @cm.previous_match
        refresh_button_visibilities
        nil
      end

      def next_file_or_finished_signal
        if @has_next_file
          NEXT_FILE_SIGNAL_
        else
          FINISHED_SIGNAL_
        end
      end

      def write_any_changed_file
        S_and_R_::Actors_::Write_any_changed_file.with(
          :edit_session, @es,
          :work_dir_path, work_dir,
          :is_dry_run, false,  # etc.
          :on_event_selectively, -> *, & ev_p do
            send_event ev_p[]  # result matters!
        end )
      end

      class Button_ < Field_

        def when_focus
          execute
        end

        def execute
          change_focus_to @parent
          nil
        end

      private

        def write_any_changed_file
          @parent.write_any_changed_file
        end
      end

      # ~ button agents - where applicable assume parent node has current match

      class Previous_Button__ < Button_
        def is_executable
          @parent.do_show_previous_button
        end

        def execute
          super
          @parent.go_to_previous_match
          STAY_WITH_FILE_SIGNAL_
        end
      end

      class Yes_Button__ < Button_
        def is_executable
          @parent.do_show_yes_button
        end

        def execute
          super  # always shed focus
          @parent.engage_replacement_of_current_match
          STAY_WITH_FILE_SIGNAL_  # (so you can see the change)
        end
      end

      class Undo_Button__ < Button_
        def is_executable
          @parent.do_show_undo_button
        end

        def execute
          super
          @parent.disengage_replacement_of_current_match
          STAY_WITH_FILE_SIGNAL_
        end
      end

      class Next_Match_Button__ < Button_
        def is_executable
          @parent.do_show_next_match_button
        end

        def execute
          super
          @parent.go_to_next_match
          STAY_WITH_FILE_SIGNAL_
        end
      end

      class All_Remaining_in_File_Button__ < Button_
        def is_executable
          @parent.do_show_all_remaining_button
        end

        def execute
          super
          ok = @parent.engage_all_remaining_matches
          ok &&= write_any_changed_file
          if ok
            STAY_WITH_FILE_SIGNAL_  # -OR- @parent.next_file_or_finished_signal
          else
            STAY_WITH_FILE_SIGNAL_
          end
        end
      end

      class Next_File_Button__ < Button_  # see #note-321

        def is_executable
          @parent.do_show_next_file_button
        end

        def execute
          super
          if write_any_changed_file
            NEXT_FILE_SIGNAL_
          else
            STAY_WITH_FILE_SIGNAL_
          end
        end
      end

      class Skip_Remaining_in_File_Button__ < Button_  # see #note-321

        def is_executable
          @parent.do_show_skip_remaining_in_file_button
        end

        def execute
          super
          if write_any_changed_file
            @parent.next_file_or_finished_signal
          else
            STAY_WITH_FILE_SIGNAL_
          end
        end
      end

      class Done_with_File_Button__ < Button_  # see #note-321

        def is_executable
          @parent.do_show_done_with_file_button
        end

        def execute
          super
          if write_any_changed_file
            @parent.next_file_or_finished_signal
          else
            STAY_WITH_FILE_SIGNAL_
          end
        end
      end
    end
  end
end
