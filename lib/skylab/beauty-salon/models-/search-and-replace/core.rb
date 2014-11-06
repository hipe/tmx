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
        ridiculous interactive search and replace.
        uses ruby to edit the files
      O

    end

    def run
      @agent = Search_Agent_Agent__.new self
      begin
        ok = @agent.execute
      end while ok
      @agent.exitstautus
    end

    # #hook-out to look like a zerk parent agent

    attr_reader :primary_UI_yielder

    attr_reader :sin, :serr

    def is_agent
      false
    end

    def change_agent_to agent
      @agent = agent
      STAY_
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
    end

    class Branch_Agent_ < Zerk_::Branch_Agent
      include Agent_Methods__
    end

    class Leaf_Agent_ < Zerk_::Leaf_Agent
      include Agent_Methods__
    end

    class Search_Agent_Agent__ < Branch_Agent_

      def initialize x
        super x
        @children = [
          Search_Agent__.new( self ),
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
        STAY_
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
        STAY_
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
        @parent_files_agent = @parent[ :files ]
        @parent_dirs_agent = @parent[ :dirs ]
        nil
      end

      def prepare_for_UI
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

      def to_body_item_value_string
      end

      def execute
        change_agent_to @parent.parent
      end
    end

    class Quit_Agent_ < Leaf_Agent_

      def to_body_item_value_string
      end

      def prompt
      end

      def block_for_response
        DONE_
      end

      def display_panel
        # if you overwrote `execute` you wouldn't see the amusingly useless nav
        super
        @y << 'goodbye.'
        DONE_
      end

      def to_marshal_pair
      end
    end

    DONE_ = nil
    NONE_S_ = Zerk_::NONE_S
    S_and_R_ = self
    STAY_ = true
  end
end
