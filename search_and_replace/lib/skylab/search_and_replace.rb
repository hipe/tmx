require 'skylab/common'

module Skylab::SearchAndReplace

  # notes in [#001] (the readme)

  class << self

    def lib_
      @___lib ||= Common_.
        produce_library_shell_via_library_and_app_modules Lib___, self
    end
  end  # >>

  Common_ = ::Skylab::Common

  Lazy_ = Common_::Lazy

  rx = /(?:\r?\n|\r)\z/
  Mutate_by_my_chomp_ = -> mutable_s do
    md = rx.match mutable_s
    if md
      self._COVER_ME
      s = md[ 0 ]
      mutable_s[ ( - s.length )..-1 ] = EMPTY_S_
      s
    end
  end

  module API

    class << self

      def call * x_a, & oes_p

        root = Root_Autonomous_Component_System_.new  # #cold-model
        root._init_with_defaults

        _pp = -> _ do
          oes_p
        end

        Require_zerk_[]

        Zerk_::API.call x_a, root, & _pp
      end  # :cp1
    end  # >>
  end

  class Root_Autonomous_Component_System_  # 1x by CLI and 1x by API

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

    def initialize

      block_given? and self._REFACTOR_do_not_use_hot_model_any_more

      @egrep_pattern = nil
      @ruby_regexp = nil
    end

    def _init_with_defaults

      @filename_patterns = [ '*.rb' ]
      @paths = [ '.' ]
      @ruby_regexp = nil

      NIL_
    end

    def __ruby_regexp__component_association

      if @ruby_regexp  # #item-value-description (#survey)
        yield :description, -> qkn do
          # ([ze] uses [#ba-019] ("ick") which doesn't express regexps)
          qkn.value_x.inspect
        end
      end

      -> st, & pp do
        if st.unparsed_exists
          x = st.gets_one
          if x
            if x.respond_to? :casefold?
              Common_::Known_Known[ x ]
            else
              ___interpret_ruby_regexp x, & pp
            end
          else
            # setting it to false-ish has been requested explicitly
            Common_::Known_Known[ x ]
          end
        end
      end
    end

    def ___interpret_ruby_regexp s, & pp

      # in order to interpret regexp *options* (namely "extended",
      # "ignore case", "multiline", "o...(#open [#015])"):
      #
      #   1) if the string starts with a slash and ends with a slash and
      #      zero or more letters, it is assumed that the slases delimit
      #      the regexp and the letters are options..
      #
      #   2) otherwise (and the string does not match the above pattern),
      #      the whole string is used as the regexp body.

      _lib = Home_.lib_.basic::Regexp

      use_oes_p = nil

      _oes_p = -> * i_a, & ev_p do
        use_oes_p ||= pp[ self ]
        use_oes_p[ * i_a, & ev_p ]
      end

      if LENIENT_RX_RX___ !~ s
        s = "/#{ s }/"  # effectively normalize input, so we can use marshal load
      end

      rx = _lib.marshal_load s, & _oes_p

      if rx
        Common_::Known_Known[ rx ]
      else
        rx
      end
    end

    LENIENT_RX_RX___ = %r(\A/.*/[a-z]*\z)

    def __egrep_pattern__component_association

      -> st, & pp do
        if st.unparsed_exists
          x = st.gets_one
          if x
            Common_::Known_Known[ x ]
          end
        end
      end
    end

    def __paths__component_association

      yield :is_plural_of, :path
    end

    def __path__component_association

      yield :is_singular_of, :paths

      -> st do
        x = st.gets_one
        if x
          Common_::Known_Known[ x ]
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
          Common_::Known_Known[ x ]
        end
      end
    end

    def __search__component_association

      Home_::Interface_Models_::Search
    end
  end

  if false  # #open [#006]
        @y << "(display, edit, and execute the details of your search)"

      def xx
          "(defaults to the same pattern as below)"
      end

      # #description_for:egrep_pattern

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

      # #description_for:ruby_regexp

      def display_description
        @y << nil
        @y << "enter the regex body without leading or trailing delimiters."
        @y << "there is not yet support for trailing modifiers (\"i\" etc)"
        @y << "but that's coming, and you may be able to hack it with \"(?i:xxx)\"."
        @y << nil
      end

      # #description_for:replacement_expression

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

      # -- #list_parsing

      def prompt_when_value
        @serr.write "new #{ noun } (nothing to cancel, space(s) to remove): "
        @serr.flush
        PROCEDE_
      end

      def know_via_nonblank_mutable_string s
        s.strip!
        a = s.split SPACE_SPAN_RX_
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
        if SPACE_SPAN_RX_ =~ s
          maybe_send_event :error do
            build_not_OK_event_with :only_single_item_for_now, :s, s
          end
          UNABLE_
        else
          @a = [ s ]
          ACHIEVED_
        end
      end

    S_and_R_ = self
  end

  Require_ACS_ = Lazy_.call do
    ACS_ = Home_.lib_.ACS ; nil
  end

  Attributes_actor_ = -> cls, * a do
    Home_.lib_.fields::Attributes::Actor.via cls, a
  end

  Attributes_ = -> h do
    Home_.lib_.fields::Attributes[ h ]
  end

  Require_zerk_ = Lazy_.call do
    Zerk_ = Home_.lib_.zerk ; nil
  end

  Autoloader_ = Common_::Autoloader

  module Lib___

    sidesys = Autoloader_.build_require_sidesystem_proc

    ACS = sidesys[ :Autonomous_Component_System ]
    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Fields = sidesys[ :Fields ]
    Git = sidesys[ :Git ]

    Shellwords = -> do
      require 'shellwords'
      ::Shellwords
    end

    String_scanner = -> do
      require 'strscan'
      ::StringScanner
    end

    System = -> do
      System_lib[].services
    end

    System_lib = sidesys[ :System ]

    Tmpdir = Lazy_.call do
      require 'tmpdir'
      ::Dir.tmpdir
    end

    Zerk = sidesys[ :Zerk ]
  end

  Autoloader_[ Magnetics_ = ::Module.new ]

  Autoloader_[ Throughput_Magnetics_ = ::Module.new ]

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]

  ACHIEVED_ = true
  EMPTY_A_ = []
  EMPTY_P_ = -> { NOTHING_ }
  EMPTY_S_ = ''
  Home_ = self
  IDENTITY_ = -> x { x }
  NEWLINE_ = "\n"
  NOTHING_ = nil
  NIL_ = nil
  SPACE_ = ' '
  SPACE_SPAN_RX_ = /[[:space:]]+/
  UNABLE_ = false
end

# #tombstone: removed some unavailability rigging
# #tombstone: [#br-043] the frontier example of a back-less front..
