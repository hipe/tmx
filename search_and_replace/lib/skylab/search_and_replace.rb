require 'skylab/callback'

module Skylab::SearchAndReplace

  # notes in [#001] (the readme)

  class << self

    def lib_
      @___lib ||= Callback_.
        produce_library_shell_via_library_and_app_modules Lib_, self
    end
  end  # >>

  module API

    class << self

      def call * x_a, & oes_p

        root = Root_Autonomous_Component_System___.new( & oes_p )
        root.__init_with_defaults

        Home_.lib_.zerk.call x_a, root
      end
    end  # >>
  end

  class Root_Autonomous_Component_System___

    Xxx = -> y do

        _ = <<-HERE
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

      st = Home_.lib_.basic::String[ :line_stream, :mutate_by_unindenting, _ ]
      while s = st.gets
        y << s
      end
      y
    end

    def initialize & oes_p

      @egrep_pattern = nil
      @ruby_regexp = nil

      @_oes_p = oes_p
    end

    def __init_with_defaults

      @filename_patterns = [ '*.rb' ]
      @paths = [ '.' ]
      NIL_
    end

    def event_handler_for _  # for [ze]
      @_oes_p
    end

    def __ruby_regexp__component_association

      -> st, & pp do
        if st.unparsed_exists
          ___interpret_ruby_regexp st.gets_one, & pp
        end
      end
    end

    def __egrep_pattern__component_association

      # for UI (when we get there), we want this to show up only when etc
      if ! @ruby_regexp
        yield :intent, :API  # that is, not UI
      end

      -> st, & pp do
        if st.unparsed_exists
          x = st.gets_one
          if x
            Callback_::Known_Known[ x ]
          end
        end
      end
    end

    def ___interpret_ruby_regexp s, & pp

      Callback_::Known_Known[ ::Regexp.new s ]

    rescue ::RegexpError => e

      pp[ nil ].call :error, :expression, :regexp_error do | y |
        y << "deesh: #{ e.message }"
      end

      UNABLE_
    end

    def __paths__component_association

      yield :is_plural_of, :path
    end

    def __path__component_association

      yield :is_singular_of, :paths

      -> st do
        x = st.gets_one
        if x
          Callback_::Known_Known[ x ]
        end
      end
    end

    def __filename_patterns__component_association

      yield :is_plural_of, :filename_pattern
    end

    def __filename_pattern__component_association

      yield :is_singular_of, :filename_patterns

      -> st do
        x = st.gets_one
        if x
          Callback_::Known_Known[ x ]
        end
      end
    end

    def __search__component_association

      a = nil
      if Nonzero_array_[ @paths ]

        fbf = _build :Files_by_Find, @paths, @filename_patterns

        a = [ fbf ]

        if @ruby_regexp

          fbg = _build :Files_by_Grep, @egrep_pattern, @ruby_regexp, fbf

          a.push fbg

          a.push _build( :Counts, fbg )

          a.push _build( :Matches, fbg )
        end
      end

      if a
        Home_::Interface_Models_::Search.new( a, & @_oes_p )
      else
        -> _st, & pp do
          Cannot_search_until___[ pp ]
          UNABLE_
        end
      end
    end

    def _build const, * a

      _nf = Callback_::Name.via_variegated_symbol const.downcase
      a.push _nf
      _cls = Home_::Interface_Models_.const_get const, false
      _cls.new( * a )
    end

    Cannot_search_until___ = -> pp do
      pp[ nil ].call :error, :expression, :uninterpretable_token do |y|
        y << "(to search you must have some paths..)"  # experiment
      end
    end
  end

  Nonzero_array_ = -> x do
    if x
      x.length.nonzero?
    end
  end

  if false  # #todo

    # ~ the agents

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
          # @files_field = Files_Field__.new( self ),
          # @preview_node = Preview_Node__.new( self ),
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

        _oes_p = handle_unsigned_event_selectively

        @o = _build_replace_function_via_string( s, & _oes_p )

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

        @o = _build_replace_function_via_string s, & _oes_p

        @o ? ACHIEVED_ : UNABLE_
      end

      def _build_replace_function_via_string s, & oes_p

        _work_dir = work_dir

        _ = S_and_R_::Magnetics_::Replace_Function_via_String_and_Work_Dir[
          s, _work_dir, & _oes_p ]

        _
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
      "and for now, there is no support for spaces in #{ s } list but that's coming.."  # #open [#006]
    end

    LIST_HACK_SEPARATOR_RX__ = /[ \t]+/

    class Dirs_Field__ < Field_

      include List_Hack_Methods__

      def path_list
        @a
      end
    end

    EMPTY_A_ = [].freeze
    EMPTY_RX_ = /\A[[:space:]]*\z/
    FINISHED_ = nil
    NONE_S_ = Zerk_::NONE_S
    S_and_R_ = self
  end

  Callback_ = ::Skylab::Callback

  On_event_selectively_ = -> * i_a, & ev_p do

    # a default event handler for when none is provided but one is required

    if :info != i_a.first
      raise ev_p[].to_exception
    end
  end

  Require_ACS_ = Callback_::Lazy.call do
    ACS_ = Lib_::ACS[]
    NIL_
  end

  Autoloader_ = Callback_::Autoloader

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    ACS = sidesys[ :Autonomous_Component_System ]
    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Fields = sidesys[ :Fields ]

    Shellwords = -> do
      require 'shellwords'
      ::Shellwords
    end

    String_scanner = -> do
      require 'strscan'
      ::StringScanner
    end

    system_lib = sidesys[ :System ]

    System = -> do
      system_lib[].services
    end

    Zerk = sidesys[ :Zerk ]
  end

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ]]

  ACHIEVED_ = true
  EMPTY_P_ = -> { NIL_ }
  EMPTY_S_ = ''
  Home_ = self
  IDENTITY_ = -> x { x }
  NEWLINE_ = "\n"
  NIL_ = nil
  SPACE_ = ' '
  UNABLE_ = false
end

# #tombstone: [#br-043] the frontier example of a back-less front..
