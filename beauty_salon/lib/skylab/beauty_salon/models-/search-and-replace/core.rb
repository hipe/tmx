module Skylab::BeautySalon

  module Models_::Search_and_Replace  # see [#016]

    Actions = ::Module.new

    class Actions::Search_and_Replace < Home_.lib_.brazen::Action  # sorry

      # this is :[#br-043] the frontier example of a back-less front..

      @is_promoted = true

      @instance_description_proc = -> y do

        s = <<-HERE
          ridiculous interactive search and replace: in a simple interactive
          terminal session, build your transformation progressively.
          then execute the tranformation, which can apply the edit-in-place
          changes one-by-one with yes/no confirmation, or all at once
          non-interactively.

          the main data elements of your transformation are persistent,
          being progressively written to a file in a simple, human readable
          format for future re-use or prehaps even hackish manual editing.

          there is an undocumented custom function API so you can write
          arbitrary code to express your transformation.

          ALWAYS BACK UP YOUR TREE (e.g in version control) before using
          this! once the old file has been replaced with the new file there
          is no undo. although we like to think of this software as stable,
          it certainly hasn't been used for enough different cases for that
          categorization yet!

          there is a known issue with files with multibyte characters.
        HERE

        st = Home_.lib_.basic::String[ :line_stream, :mutate_by_unindenting, s ]
        y << s while s = st.gets
       end
    end

    class API

      class << self

        def call * x_a, & oes_p
          oes_p and x_a.push :on_event_selectively, oes_p
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

        _S_R_node = Zerk_Tree.new Top__.new produce_event_handler

        Zerk_::API.produce_bound_call @x_a, _S_R_node
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

        lib = Home_.lib_.brazen::API

        evr = lib::Two_Stream_Event_Expresser.new(
          sout, serr, lib.expression_agent_instance )

        -> * i_a, & ev_p do
          evr.maybe_receive_on_channel_event i_a, & ev_p
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

      def grep_rx_field
        @parent.grep_rx_field
      end

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

    # Zerk_ = Home_.lib_.zerk

    module Zerk_
      # temporary while we wait for the rewrite
      Branch_Node = ::Class.new
      Common_Node = ::Class.new
      Field = ::Class.new
      Up_Button = ::Class.new
      Quit_Button = ::Class.new
      NONE_S = nil
    end

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

    class Zerk_Tree < Branch_

      class << self

        def name_function
          @___nf ||= Callback_::Name.via_variegated_symbol :'search_&_replace'
        end
      end

      def initialize x
        super

        # something somewhere doesn't like a relative path for the below.
        # ideally, relative paths would "just work" for the rest of the
        # system just like abspaths do, so this is a workaround for now

        @work_dir = ::File.join ::Dir.pwd, '.search-and-replace'
      end

      def prepare_for_focus

        @children = [
          @grep_rx_field = Grep_RX_Field__.new( self ),
          @regexp_field = Search_Field__.new( self ),
          @replace_field = Replace_Field__.new( self ),
          @dirs_field = Dirs_Field__.new( self ),
          @files_field = Files_Field__.new( self ),
          @preview_node = Preview_Node__.new( self ),
          Quit_Button_.new( self ) ]

        @preview_node.orient_self

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

      attr_reader :dirs_field, :files_field, :grep_rx_field, :regexp_field,
        :replace_field, :work_dir

      def receive__path__ x  # exeriment for API
        @preview_node.receive_path__ x
      end
    end

    class Grep_RX_Field__ < Field_

      def initialize x
        super
        @s = nil
      end

      def to_body_item_value_string
        if @s
          @s
        else
          "(defaults to the same pattern as below)"
        end
      end

      def display_description
        @serr.puts
        engine = 'oniguruma'
        other = Search_Field__.name_function.as_slug
        @y << "`grep` is used to cull the stream of files that `find` finds"
        @y << "down to only those files that contain the pattern (according"
        @y << "to grep). each such file is opened and searched (again) for"
        @y << "the pattern (but this time possibly with the file treated"
        @y << "as one big string, and with a \"native\" \"platform\""
        @y << "(currently \"#{ engine }\" regex, in a manner that possibly"
        @y << "grep does not support (for example with multiline"
        @y << "matching)). so this grep step amounts to an experimental"
        @y << "optimization that saves us the considerable resource"
        @y << "overhead of having to open every file that `find` finds."
        @y << nil
        @y << "if left empty, at execution time this field will effectively"
        @y << "default to the `.source` value of the (native) '#{ other }'"
        @y << "which works surprisingly often but certainly not always."
        @y << nil
        @y << "if the pattern that you need `grep` to use differs from the"
        @y << "pattern to be used to edit the individual files (for example"
        @y << "because of incompatible syntaxes between grep's \"extended\" regex"
        @y << "syntax and e.g the #{ engine } engine, or because multiline"
        @y << "behavior is desired but grep only operates on one line at a time)"
        @y << "whatever you enter here will be shellescaped at passed"
        @y << "to the grep `-E` argument."
        @y << nil
        @y << "you can make this far simpler than your '#{ other }' regex"
        @y << "and things should still work - it is simply a way to decide"
        @y << "which files to bother with opening."
        @y << nil
      end

      def know_via_nonblank_mutable_string s
        marshal_load s
      end

      def against_nonempty_polymorphic_stream stream
        against_nonempty_polymorphic_stream_assume_string stream
      end

      def marshal_load s
        @s = s
        ACHIEVED_
      end

      def value_is_known
        ! @s.nil?
      end

      def when_entered_nonzero_length_blank_string
        when_deleted
      end

      def unknow_value
        @s = nil
        ACHIEVED_
      end

      def to_marshal_pair
        if @s
          Callback_::Pair.via_value_and_name( @s, name_symbol )
        end
      end

      def value_string
        @s
      end
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

      def know_via_nonblank_mutable_string s
        @rx = ::Regexp.new s
        ACHIEVED_
      rescue ::RegexpError => @e
        _ = Callback_::Name.via_module( @e.class ).as_human
        @y << "#{ _ }: #{ @e.message }"
        PROCEDE_
      end

      def against_nonempty_polymorphic_stream stream
        @rx = stream.gets_one
        ACHIEVED_
      end

      def marshal_load s, & p

        @rx = Home_.lib_.basic::Regexp.marshal_load s do | * i_a, & ev_p |

          if :error == i_a.first
            p[ wrap_marshal_load_event ev_p[] ]
            UNABLE_
          end
        end
        @rx and ACHIEVED_
      end

      def to_marshal_pair
        if @rx
          Callback_::Pair.via_value_and_name( @rx.inspect, name_symbol )
        end
      end

      def value_is_known
        ! @rx.nil?
      end

      def when_entered_nonzero_length_blank_string
        when_deleted
      end

      def unknow_value
        @rx = nil
        ACHIEVED_
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

      def to_body_item_value_string
        if @o
          @o.as_text
        else
          NONE_S_
        end
      end

      def display_description
        @y << nil
        @y << "example: foo{{ $1.bar }} baz {{ $2.downcase }}"
        @y << "content in between the \"{{\" and \"}}\" is our pseudo-DSL:"
        @y << "$1, $2 etc are the captures in your expression."
        @y << "`bar` and `downcase` are \"functions\" (called as chainable"
        @y << "methods), either builtin (like `upcase`, `downcase`) or"
        @y << "user-provided. (supported escape sequences: \\n \\t \\)"
        @y << nil
      end

      def know_via_nonblank_mutable_string s

        @o = S_and_R_::Actors_::Build_replace_function[
          s, work_dir, & handle_unsigned_event_selectively ]

        @o ? ACHIEVED_ : UNABLE_
      end

      def against_nonempty_polymorphic_stream st

        if st.current_token.respond_to? :call
          receive_matchdata_values = st.gets_one
          @o = -> md do
            receive_matchdata_values[ * md.captures ]
          end
          ACHIEVED_
        else
          against_nonempty_polymorphic_stream_assume_string st
        end
      end

      def marshal_load s, & ep

        _oes_p = -> *, & ev_p do
          _ev = ev_p[]
          ep[ _ev ]
          UNABLE_
        end

        @o = S_and_R_::Actors_::Build_replace_function[ s, work_dir, & _oes_p ]

        @o ? ACHIEVED_ : UNABLE_
      end

      def to_marshal_pair
        if @o
          Callback_::Pair.via_value_and_name( @o.marshal_dump, name_symbol )
        end
      end

      def value_is_known
        ! @o.nil?
      end

      def when_entered_nonzero_length_blank_string
        when_deleted
      end

      def unknow_value
        @o = nil
        ACHIEVED_
      end

      # ~ for children

      def replace_function
        @o
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
        @serr.flush
        PROCEDE_
      end

      def know_via_nonblank_mutable_string s
        s.strip!
        a = s.split SOME_SPACE_RX_
        if a.length.zero?
          @a = nil
          UNABLE_
        else
          @a = a
          ACHIEVED_
        end
      end

      def against_nonempty_polymorphic_stream stream
        s = stream.gets_one
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

      def to_marshal_pair
        if @a
          Callback_::Pair.via_value_and_name( @a.join( SPACE_ ), name_symbol )
        end
      end

      def value_is_known
        ! @a.nil?
      end

      def when_entered_nonzero_length_blank_string
        when_deleted
      end

      def unknow_value
        @a = nil
        ACHIEVED_
      end

      SOME_SPACE_RX_ = /[[:space:]]+/
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

        @mod = S_and_R_::Reactive_Nodes_

        @parent_files_field = @parent.files_field
        @parent_dirs_field = @parent.dirs_field

        @matches_agent = @mod::Matches_Node.new self
        @regexp_field = @parent.regexp_field

        nil
      end

      def to_body_item_value_string
      end

      def prepare_for_focus
        @my_files_agent = @mod::Files_Node.new self
        @matches_agent.orient_self
        @children = [
          Up_Button_.new( self ),
          @my_files_agent,
          @matches_agent,
          Quit_Button_.new( self ) ]

        @my_files_agent.orient_self
        ACHIEVED_
      end

      def display_description
        display_any_find_command
        @serr.puts
      end

      def receive_path__ x
        @matches_agent.receive_path___ x
      end

      def can_receive_focus
        @matches_agent.has_path or
        @parent_files_field.value_is_known &&
          @parent_dirs_field.value_is_known
      end

      def prompt
        @serr.puts  # :+#aesthetics - our items list is too busy, needs more space :/
        super
      end

      def to_marshal_pair
      end

    private

      def display_any_find_command
        @my_files_agent.build_command do | * i_a, & ev_p|
          ev = ev_p[]
          if :info == i_a.first && :find_command_args == i_a[ 1 ]
            _s_a = ev.find_command_args.map( & Home_.lib_.shellwords.method( :shellescape ) )
            @serr.puts
            @serr.puts "current find command: #{ _s_a * SPACE_ }"
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

    module Actors_
      Autoloader_[ self ]
      stowaway :Build_file_stream, 'build-file-scan'
      stowaway :Build_grep_path_stream, 'build-grep-path-scan'
    end

    EMPTY_A_ = [].freeze
    EMPTY_RX_ = /\A[[:space:]]*\z/
    FINISHED_ = nil
    NONE_S_ = Zerk_::NONE_S
    S_and_R_ = self
  end
end
