module Skylab::MyTerm::TestSupport

  module My_Non_Interactive_CLI

    def self.[] tcc
      tcc.extend ModuleMethods___
      tcc.include InstanceMethods
    end

    module ModuleMethods___
      def given & p
      # -
      yes = true ; x = nil
      define_method :niCLI_state do
        if yes
          yes = false
          x = instance_exec( & p )
        else
          x
        end
      end
      # -
      end

      def fake_fonts_dir dir
        define_method :_fake_fonts_dir do
          dir
        end
      end
    end

    module InstanceMethods

      def argv * argv

        lines = []

        add_line = -> a do
          lines.push a ; :_UNRE_
        end

        if do_debug
          io = debug_IO
          up = add_line
          add_line = -> a do
            io.puts a.inspect
            up[ a ]
          end
        end

        _sout = Puts_Proxy__.new do |s|
          add_line[ [ :o, s ] ]
        end

        _serr = Puts_Proxy__.new do |s|
          add_line[ [ :e, s ] ]
        end

        cli = subject_CLI.new argv, nil, _sout, _serr, ['mt']

        prepare_CLI_for_niCLI_ cli

        _es = cli.execute

        State___.new _es, lines
      end

      def prepare_CLI_for_niCLI_ cli
        dir = _fake_fonts_dir
        cli.EXPERIMENTAL_SETUP_ACS_ = -> acs do
          if dir
            path = TS_::Qualified_fonts_dir_via[dir]
            acs.kernel_.silo(:Installation).fonts_dir = path
          end
        end
        cli.filesystem_conduit = filesystem_conduit_for_niCLI_
        cli.system_conduit = system_conduit_for_niCLI_
        NIL_
      end

      def filesystem_conduit_for_niCLI_
        _OCD_filesystem_SINGLETON_
      end

      def system_conduit_for_niCLI_
        NOTHING_
      end

      # --

      def want * x_a
        Expectation___.new( x_a ).matches? niCLI_state
      end

      # --

      def subject_CLI
        Home_::CLI
      end

      def _fake_fonts_dir  # if one is not set explictly in test setup
        NOTHING_
      end
    end

    # ==

    class Puts_Proxy__ < ::Proc
      alias_method :puts, :call
      alias_method :<<, :call  # meh
    end

    # ==

    class Expectation___

      # (this is a very rough sketch - does not fail gracefully)

      def initialize x_a
        @x_a = x_a
      end

      def matches? sta

        @_state = sta
        @_scn = Common_::Scanner.via_array remove_instance_variable :@x_a

        begin
          send @_scn.gets_one
        end until @_scn.no_unparsed_exists

        at_done_with_phrase_

        true
      end

      # -- invites

      def invite
        extend Syntax_for_Invite___
        __want_invite
      end

      # -- ordinal line related

      def only_line
        _number_of_lines 1
        _line_at_index 0
      end

      def number_of_lines
        _number_of_lines @_scn.gets_one
      end

      def _number_of_lines d
        @_state.lines.length == d or fail
      end

      def first_line
        _line_at_index 0
      end

      def second_line
        _line_at_index 1
      end

      def third_from_last_line
        _line_at_index( -3 )
      end

      def penultimate_line
        _line_at_index( -2 )
      end

      def last_line
        _line_at_index( -1 )
      end

      def _line_at_index d
        extend Syntax_for_Line__
        @_line_offset = d
        __want_line
      end

      # -- e.s related

      def succeeds
        _want_exitstatus 0
      end

      def exitstatus

        sym = @_scn.gets_one
        d = Home_::Zerk_::NonInteractiveCLI::Exit_status_for___[ sym ]
        d or fail __say_bad_es sym
        _want_exitstatus d
      end

      def __say_bad_es sym
        "not an exitstatus: '#{ sym }'"
      end

      def _want_exitstatus d
        _actual = @_state.exitstatus
        if _actual == d
          ACHIEVED_
        else
          @_es = d
          _fail_by :__say_wrong_es
        end
      end

      def __say_wrong_es
        "expected exitstatus #{ @_es } had #{ @_state.exitstatus }"
      end

      def at_done_with_phrase_
        NOTHING_
      end

      # --

      def _fail_by m
        raise send m
      end
    end

    # ==

    module Syntax_for_Invite___

      def __want_invite
        @__want_adapter_activated = false
        @_about = nil
        NOTHING_
      end

      def when_adapter_activated
        @__want_adapter_activated = true ; nil
      end

      def from_top
        @_from = nil
      end

      def from
        @_from = @_scn.gets_one ; nil
      end

      def about_options
        @_about = "options"
      end

      def about_arguments
        @_about = "arguments"
      end

      def at_done_with_phrase_

        sym, s = @_state.lines.last
        sym == :e or fail

        buff = ""

        if @__want_adapter_activated
          buff << " -ai"  # meh
        end

        if @_from
          buff << " #{ @_from }"
        end

        ab_s = @_about
        if ab_s
          _tail = " about #{ ab_s }"
        else
          _tail = '.'  # DOT_
        end

        expect = "see 'mt#{ buff } -h' for more#{ _tail }"

        s_ = s.gsub STYLE_RX_, EMPTY_S_
        s_.length < s.length or fail

        if s_ == expect
          ACHIEVED_
        else
          @_act = s_ ; @_exp = expect
          _fail_by :__say_etc
        end
      end

      def __say_etc
        "needed #{ @_exp.inspect } had #{ @_act.inspect }"
      end
    end

    # ==

    module Syntax_for_Line__

      def __want_line
        @_want_on_channel = :e
        @_want_is_styled = false
        _peek_for_matchee
      end

      def styled
        @_want_is_styled = true
        _peek_for_matchee
      end

      def o
        @_want_on_channel = :o
        _peek_for_matchee
      end

      def _peek_for_matchee

        x = @_scn.head_as_is
        if x.respond_to? :ascii_only?
          @_matchee_shape = :__match_against_string
          @_matchee_string = x
          @_scn.advance_one
        elsif x.respond_to? :named_captures
          @_matchee_shape = :__match_against_regexp
          @_matchee_regexp = x
          @_scn.advance_one
        end
      end

      def at_done_with_phrase_

        sym, @_use_s = @_state.lines.fetch @_line_offset
        @_use_s.chomp!

        if sym == @_want_on_channel

          if @_want_is_styled
            if _is_styled
              send @_matchee_shape
            else
              _fail_by :__say_not_styled
            end
          elsif _is_styled
            _fail_by :__say_is_styled
          else
            send @_matchee_shape
          end
        else
          _fail_by :__say_etc
        end
      end

      def _is_styled

        if @_use_s.include? STYLED_CANARY___
          @_use_s = @_use_s.gsub STYLE_RX_, EMPTY_S_
          true
        else
          false
        end
      end

      def __match_against_regexp
        if @_matchee_regexp =~ @_use_s
          ACHIEVED_
        else
          _fail_by :__say_rx
        end
      end

      def __say_rx
        "needed to match against /#{ @_matchee_regexp.source }/: #{ @_use_s.inspect }"
      end

      def __say_not_styled
        "expected styled but was not styled: #{ @_use_s.inspect }"
      end

      def __say_is_styled
        "expected was not styled but was styled: #{ @_use_s.inspect }"
      end

      def __match_against_string
        if @_use_s == @_matchee_string
          ACHIEVED_
        else
          _fail_by :__say_didnt_match_string
        end
      end

      def __say_didnt_match_string
        "needed #{ @_matchee_string.inspect } - #{ @_use_s.inspect }"
      end
    end

    # ==

    State___ = ::Struct.new :exitstatus, :lines

    # --

    ACHIEVED_ = true
    EMPTY_S_ = ""
    NOTHING_ = nil
    STYLE_RX_ = %r(\e\[\d+(?:;\d+)*m)
    STYLED_CANARY___ = "\e"
  end
end
