module Skylab::BeautySalon

  class Models_::Search_and_Replace  # see [#016]

    Brazen_ = BS_::Lib_::Brazen[]

    Zerk_ = Brazen_::Zerk

    def initialize * three
      if three.length.nonzero?
        @sin, _, @serr = three
        @primary_UI_yielder = ::Enumerator::Yielder.new do |s|
          @serr.puts s
        end
      end
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
      @agent = Search_Agent_Agent__.new self
      begin
        ok = @agent.execute
      end while ok
      @agent.exitstautus
    end

    # #hook-out that every zerk top node must implement

    attr_reader :primary_UI_yielder

    attr_reader :sin, :serr

    def is_agent
      false
    end

    def change_focus_to cx
      cx.before_focus
      @agent = cx
      cx.when_focus
    end

    # ~ the agents

    module Agent_Methods__

    private

      def send_event ev
        scan = ev.scan_for_render_lines_under expression_agent
        s = scan.gets
        if false == ev.ok
          @serr.puts "#{ @name.as_human } error: #{ s }"
          while s = scan.gets
            @serr.puts "  #{ s }"
          end
          UNABLE_
        else
          @serr.puts "#{ @name.as_human } node #{ s }"
          while s = scan.gets
            @serr.puts "  #{ s }"
          end
          PROCEDE_
        end
      end

      def expression_agent
        BS_::Lib_::Brazen[]::API.expression_agent_instance
      end

      def prepare_UI
        ACHIEVED_
      end

    public

      def before_focus
        @last_prepare_UI_was_OK ||= prepare_UI
      end

      def when_focus
        AS_IS_
      end
    end

    class Branch_Agent_ < Zerk_::Branch_Agent

      include Agent_Methods__

    public  # ~ as parent we receive these from children

      def regexp_field
        @parent.regexp_field
      end

      def current_child_hashtable
        @_curr_chld_h ||= build_child_hashtable.freeze
      end
    end

    class Leaf_Agent_ < Zerk_::Leaf_Agent
      include Agent_Methods__
    end

    class Search_Agent_Agent__ < Branch_Agent_

      def initialize x
        super x
        @children = [
          @regexp_field = Search_Agent__.new( self ),
          Replace_Agent__.new( self ),
          Dirs_Agent__.new( self ),
          Files_Agent__.new( self ),
          pa = Preview_Agent__.new( self ),
          Quit_Agent_.new( self ) ]
        pa.orient_self
        @persist_path = '.search-and-replace/current-search.conf'
        retrieve_values_from_FS_if_exist
        @is_first_display = true
      end

      define_method :receive_try_to_persist, Zerk_::RECEIVE_TRY_TO_PERSIST_METHOD

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

      attr_reader :regexp_field

    end

    class Search_Agent__ < Leaf_Agent_

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

      def via_line_know_value
        @rx = ::Regexp.new @line
        ACHIEVED_
      rescue ::RegexpError => @e
        _ = Callback_::Name.via_module( @e.class ).as_human
        @y << "#{ _ }: #{ @e.message }"
        AS_IS_
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

      def wrap_marshal_load_event ev
        noun_ = noun
        ev.with_message_string_mapper -> s do
          "(failed to unmarshal #{ noun_ }: #{ s })"
        end
      end

      def value_is_known
        ! @rx.nil?
      end

      # ~ for children

      def regexp
        @rx
      end
    end

    class Replace_Agent__ < Leaf_Agent_

      def initialize x
        @xxx = nil
        super
      end

      def to_body_item_value_string
        if @xxx
          @xxx
        else
          NONE_S_
        end
      end

      def when_entered_nonzero_length_blank_string
        when_deleted
      end

      def via_line_know_value
        @xxx = @line
        ACHIEVED_
      end

      def unknow_value
        @xxx = nil
        ACHIEVED_
      end

      def to_marshal_pair
        if @xxx
          Callback_.pair.new @xxx, name_i
        end
      end

      def marshal_load x, & ep
        @xxx = x
        ACHIEVED_
      end

      def value_is_known
        ! @xxx.nil?
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
        AS_IS_
      end

      def when_entered_nonzero_length_blank_string
        when_deleted
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
      "and for now, there is no support for spaces in #{ s } list but that's coming.."
    end

    LIST_HACK_SEPARATOR_RX__ = /[ \t]+/

    class Dirs_Agent__ < Leaf_Agent_

      include List_Hack_Methods__

      def path_list
        @a
      end
    end

    class Files_Agent__ < Leaf_Agent_

      include List_Hack_Methods__

      def glob_list
        @a
      end
    end

    class Preview_Agent__ < Branch_Agent_

      def initialize x
        super
      end

      def orient_self
        h = @parent.current_child_hashtable
        @parent_files_agent = h.fetch :files
        @parent_dirs_agent = h.fetch :dirs
        @regexp_agent = h.fetch :search
        nil
      end

      attr_reader :regexp_agent

      def prepare_UI
        mod = S_and_R_::Preview_Agent_Children__
        @my_files_agent = mod::Files_Agent.new self
        matches_agent = mod::Matches_Agent.new self
        matches_agent.orient_self
        @children = [
          Up_Agent_.new( self ),
          @my_files_agent,
          matches_agent,
          Quit_Agent_.new( self ) ]

        @my_files_agent.orient_self
        DONE_
      end

      def display_description
        display_any_find_command
        @serr.puts
      end

      def is_executable
        @parent_files_agent.value_is_known &&
          @parent_dirs_agent.value_is_known
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
        @my_files_agent.build_command do |i, i_, *, & ev_p|
          ev = ev_p[]
          if :info == i && :command_string == i_
            @serr.puts
            @serr.puts "current find command: #{ ev.command_string }"
          else
            send_event ev
          end
        end
        nil
      end

    public  # ~ for children only

      def lower_files_agent
        @my_files_agent
      end
    end

    class Up_Agent_ < Leaf_Agent_

      def initialize times=2, x
        @times = times
        super x
      end

      def to_body_item_value_string
      end

      def when_focus
        execute
      end

      def execute
        scn = Callback_.scan.via_times @times
        if scn.gets
          current = @parent
        end
        while scn.gets
          current = current.parent
        end
        if current
          change_focus_to current  # disreagard signal, assumed "as is"
          :_UP_
        else
          UNABLE_
        end
      end
    end

    class Quit_Agent_ < Leaf_Agent_

      def to_body_item_value_string
      end

      def when_focus
        execute
      end

      def display_panel
        # if you overwrote `execute` you wouldn't see the amusingly useless nav
        super
        @y << 'goodbye.'
        DONE_
      end

      def prompt
      end

      def to_marshal_pair
      end
    end

    AS_IS_ = Zerk_::AS_IS_SIGNAL
    DONE_ = nil
    NONE_S_ = Zerk_::NONE_S
    S_and_R_ = self
  end
end
