module Skylab::BeautySalon

  class Models_::Search_and_Replace  # see [#016]

    class << self

      def client_for_three * a
        Interactive_CLI__.new a
      end
    end

    class Interactive_CLI__

      def initialize three

        @handle_event_selectively_via_channel = -> _, & ev_p do
          ev = ev_p[]
          ev.render_all_lines_into_under @primary_UI_yielder, expression_agent
          ev.ok  # always propagate this - some logic relies on the false-ish-ness
        end

        @primary_UI_yielder = ::Enumerator::Yielder.new do |s|
          @serr.puts s
        end

        @sin, _, @serr = three
      end

      def write_options o

        o.separator EMPTY_S_

        o.separator 'description:'

        o.separator <<-O.gsub %r(^ {8}), EMPTY_S_

          ridiculous interactive search and replace: in a simple interactive
          terminal session, build your transformation progressively.
          then execute the tranformation, which can apply the edit-in-place
          changes one-by-one with yes/no confirmation. the main data elements
          of your transformation are persistent, being progressively written
          to a file for future re-use or prehaps editing.

        O

      end

      def run
        @node_with_focus = Search_and_Replace_Node__.new self
        begin
          @node_with_focus.before_focus
          ok = @node_with_focus.receive_focus
        end while ok
        @node_with_focus.exitstatus
      end

      # ~ messages received as zerk parent from zerk child (#hook-outs)

      # ~~ reflectors

      def is_agent
        false
      end

      def is_interactive
        true
      end

      # ~~ program flow

      def change_focus_to cx
        @node_with_focus = cx
        nil
      end

      # ~~ resources in support of events & UI

      attr_reader(
        :handle_event_selectively_via_channel,
        :primary_UI_yielder,
        :serr,
        :sin )

      def expression_agent
        BS_::Lib_::Brazen[]::API.expression_agent_instance
      end
    end

    class API

      class << self

        def call * x_a
          bc = new( x_a ).resolve_bound_call
          bc and begin
            bc.receiver.send bc.method_name, * bc.args
          end
        end

        def final_fallback_stdout_and_stderr
          [ $stdout, $stderr ]
        end
      end

      def initialize x_a
        @x_a = x_a
      end

      def resolve_bound_call
        Zerk_::API.produce_bound_call @x_a, (
          Search_and_Replace_Node__.new Top__.new produce_event_handler )
      end

      def produce_event_handler
        if :on_event_selectively == @x_a[ -2 ]
          globbing_p = @x_a.last
          @x_a[ -2, 2 ] = EMPTY_A_
          -> i_a, & ev_p do
            globbing_p[ * i_a, & ev_p ]
          end
        else
          Final_fallback_on_event_selectively_via_channel__[ *
            self.class.final_fallback_stdout_and_stderr ]
        end
      end

      Final_fallback_on_event_selectively_via_channel__ = -> sout, serr do
        lib = BS_::Lib_::Brazen[]::API
        evr = lib.two_stream_event_expressor.new(
          sout, serr, lib.expression_agent_instance )
        -> _, & ev_p do
          evr.receive_event ev_p[]
        end
      end

      class Top__

        def initialize p
          @handle_event_selectively_via_channel = p
        end

        attr_reader :handle_event_selectively_via_channel

        def is_interactive
          false
        end
      end
    end

    # ~ the agents

    module Node_Methods_

      # ~ messages received as child from parent

      def prepare_for_focus
        ACHIEVED_
      end

      # ~ messages received as parent from children

      def regexp_field
        @parent.regexp_field
      end

      def replace_field
        @parent.replace_field
      end

      def work_dir
        @parent.work_dir
      end

      def expression_agent
        @parent.expression_agent
      end
    end

    Brazen_ = BS_::Lib_::Brazen[]

    Zerk_ = Brazen_::Zerk

    class Node_ < Zerk_::Common_Node

      include Node_Methods_

    end

    class Branch_ < Zerk_::Branch_Node

      include Node_Methods_

      def before_focus
        @last_prepare_focus_was_OK ||= prepare_for_focus
        nil
      end
    end

    class Field_ < Zerk_::Field

      include Node_Methods_

    end

    Up_Button_ = Zerk_::Up_Button

    Quit_Button_ = Zerk_::Quit_Button

    class Search_and_Replace_Node__ < Branch_

      def initialize x
        super
        @work_dir = '.search-and-replace'
      end

      def prepare_for_focus

        @children = [
          @regexp_field = Search_Field__.new( self ),
          @replace_field = Replace_Field__.new( self ),
          @dirs_field = Dirs_Field__.new( self ),
          @files_field = Files_Field__.new( self ),
          pn = Preview_Node__.new( self ),
          Quit_Button_.new( self ) ]

        pn.orient_self

        @is_first_display = true

        if @is_interactive
          retrieve_values_from_FS_if_exist
        end

        ACHIEVED_
      end

      def display_separator
        if @is_first_display
          @is_first_display = false
        else
          super
        end
        nil
      end

      def display_description
        @y << "(display, edit, and execute the details of your search)"
        nil
      end

    public

      attr_reader :dirs_field, :files_field, :regexp_field,
        :replace_field, :work_dir

    end

    class Search_Field__ < Field_

      def initialize x
        @rx = nil
        super
      end

      NOUN___ = 'search regex'

      def to_body_item_value_string
        if @rx
          @rx.inspect
        else
          NONE_S_
        end
      end

      def display_description
        @y << nil
        @y << "enter the regex body without leading or trailing delimiters."
        @y << "there is not yet support for trailing modifiers (\"i\" etc)"
        @y << "but that's coming, and you may be able to hack it with \"(?i:xxx)\"."
        @y << nil
      end

      def when_entered_nonzero_length_blank_string
        when_deleted
      end

      def unknow_value
        @rx = nil
        ACHIEVED_
      end

      def against_nonempty_iambic_stream scan
        @rx = scan.gets_one
        ACHIEVED_
      end

      def via_line_know_value
        @rx = ::Regexp.new @line
        ACHIEVED_
      rescue ::RegexpError => @e
        _ = Callback_::Name.via_module( @e.class ).as_human
        @y << "#{ _ }: #{ @e.message }"
        PROCEDE_
      end

      def to_marshal_pair
        if @rx
          Callback_.pair.new @rx.inspect, name_i
        end
      end

      def marshal_load s, & p
        s.gsub! "\b", 'b'  # awful #open [#020]
        @rx = BS_::Lib_::Regexp_lib[].marshal_load s do |ev|
          p[ wrap_marshal_load_event ev ]
          UNABLE_
        end
        @rx and ACHIEVED_
      end

      def value_is_known
        ! @rx.nil?
      end

      # ~ for children

      def regexp
        @rx
      end
    end

    class Replace_Field__ < Field_

      def initialize x
        @o = nil
        super
      end

      def replace_function
        @o
      end

      def to_body_item_value_string
        if @o
          @o.as_text
        else
          NONE_S_
        end
      end

      def when_entered_nonzero_length_blank_string
        when_deleted
      end

      def against_nonempty_iambic_stream scan
        know_via_string scan.gets_one
      end

      def via_line_know_value
        s = @line ; @line = nil
        know_via_string s
      end

      def know_via_string s
        @o = S_and_R_::Actors_::Build_replace_function[
          s, handle_unsigned_event_selectively ]
        @o ? ACHIEVED_ : UNABLE_
      end

      def unknow_value
        @o = nil
        ACHIEVED_
      end

      def to_marshal_pair
        if @o
          Callback_.pair.new @o.marshal_dump, name_i
        end
      end

      def marshal_load s, & ep

        @o = S_and_R_::Actors_::Build_replace_function[ s, -> *, & ev_p do
          _ev = ev_p[]
          ep[ _ev ]
          UNABLE_
        end ]

        @o ? ACHIEVED_ : UNABLE_
      end

      def value_is_known
        ! @o.nil?
      end
    end

    NONE_S = Zerk_::NONE_S

    module List_Hack_Methods__

      def initialize x
        @a = nil
        super
      end

      def to_body_item_value_string
        if @a
          @a.join SPACE_
        else
          NONE_S
        end
      end

      def display_description
        @y << nil
        @y << THING_ABOUT_SPACES__
        @y << THATS_COMING__[ @name.as_human ]
        @y << nil
        nil
      end

      def prompt_when_value
        @serr.write "new #{ noun } (nothing to cancel, space(s) to remove): "
        PROCEDE_
      end

      def when_entered_nonzero_length_blank_string
        when_deleted
      end

      def against_nonempty_iambic_stream scan
        s = scan.gets_one
        if SOME_SPACE_RX_ =~ s
          maybe_send_event :error do
            build_not_OK_event_with :only_single_item_for_now, :s, s
          end
          UNABLE_
        else
          @a = [ s ]
          ACHIEVED_
        end
      end

      def via_line_know_value
        @line.strip!
        a = @line.split SOME_SPACE_RX_
        if a.length.zero?
          @a = nil
          UNABLE_
        else
          @a = a
          ACHIEVED_
        end
      end

      def unknow_value
        @a = nil
        ACHIEVED_
      end

      def to_marshal_pair
        if @a
          Callback_.pair.new @a.join( SPACE_ ), name_i
        end
      end

      def marshal_load s
        s.strip!
        a = s.split SOME_SPACE_RX_
        if a.length.zero?  # maybe sanity, maybe we use this above
          @a = nil
        else
          @a = a
        end
        ACHIEVED_
      end

      SOME_SPACE_RX_ = /[[:space:]]+/

      def value_is_known
        ! @a.nil?
      end
    end

    THING_ABOUT_SPACES__ =
      "for now, multiple values can be separated with one or more spaces."

    THATS_COMING__ = -> s do
      "and for now, there is no support for spaces in #{ s } list but that's coming.."  # #open [#023]
    end

    LIST_HACK_SEPARATOR_RX__ = /[ \t]+/

    class Dirs_Field__ < Field_

      include List_Hack_Methods__

      def path_list
        @a
      end
    end

    class Files_Field__ < Field_

      include List_Hack_Methods__

      def glob_list
        @a
      end
    end

    class Preview_Node__ < Branch_

      def initialize x
        super
      end

      def orient_self
        @parent_files_field = @parent.files_field
        @parent_dirs_field = @parent.dirs_field
        @regexp_field = @parent.regexp_field
        nil
      end

      def prepare_for_focus
        mod = S_and_R_::Preview_Agent_Children__
        @my_files_agent = mod::Files_Node.new self
        matches_agent = mod::Matches_Node.new self
        matches_agent.orient_self
        @children = [
          Up_Button_.new( self ),
          @my_files_agent,
          matches_agent,
          Quit_Button_.new( self ) ]

        @my_files_agent.orient_self
        ACHIEVED_
      end

      def display_description
        display_any_find_command
        @serr.puts
      end

      def can_receive_focus
        @parent_files_field.value_is_known &&
          @parent_dirs_field.value_is_known
      end

      def to_body_item_value_string
      end

      def to_marshal_pair
      end

      def prompt
        @serr.puts  # :+#aesthetics - our items list is too busy, needs more space :/
        super
      end

    private

      def display_any_find_command
        @my_files_agent.build_command do | * i_a, & ev_p|
          ev = ev_p[]
          if :info == i_a.first && :command_string == i_a[ 1 ]
            @serr.puts
            @serr.puts "current find command: #{ ev.command_string }"
          else
            maybe_send_event_via_channel i_a do
              ev
            end
          end
        end
        nil
      end

    public  # ~ for children only

      def dirs_field
        @parent_dirs_field
      end

      def files_field
        @parent_files_field
      end

      def lower_files_agent
        @my_files_agent
      end
    end

    EMPTY_A_ = [].freeze
    FINISHED_ = nil
    NONE_S_ = Zerk_::NONE_S
    S_and_R_ = self
  end
end
