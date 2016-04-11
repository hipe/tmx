module Skylab::MyTerm::TestSupport

  module My_Non_Interactive_CLI

    def self.[] tcc
      tcc.send :define_singleton_method, :given, Given___
      tcc.include self
    end

    Given___ = -> & p do

      yes = true ; x = nil
      define_method :niCLI_state do
        if yes
          yes = false
          x = instance_exec( & p )
        else
          x
        end
      end
    end

    # -

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

        _CLI = subject_CLI.new( nil, _sout, _serr, ['mt'] )

        _es = _CLI.invoke argv

        State___.new _es, lines
      end

      # --

      def expect * x_a
        Expectation___.new( x_a ).matches? niCLI_state
      end

      # --

      def subject_CLI
        Home_::CLI
      end

    # -

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
        @_st = Callback_::Polymorphic_Stream.via_array remove_instance_variable :@x_a

        begin
          send @_st.gets_one
        end until @_st.no_unparsed_exists

        at_done_with_phrase_

        true
      end

      # -- invites

      def invite
        extend Syntax_for_Invite___
        __expect_invite
      end

      # -- ordinal line related

      def only_line
        _number_of_lines 1
        _line_at_index 0
      end

      def number_of_lines
        _number_of_lines @_st.gets_one
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

      def _line_at_index d
        extend Syntax_for_Line__
        @_line_offset = d
        __expect_line
      end

      # -- e.s related

      def succeeds
        _expect_exitstatus 0
      end

      def exitstatus

        sym = @_st.gets_one
        d = Home_::Zerk_::Non_Interactive_CLI::Exit_status_for___[ sym ]
        d or fail ___say_bad_es sym
        _expect_exitstatus d
      end

      def ___say_bad_es sym
        "not an exitstatus: '#{ sym }'"
      end

      def _expect_exitstatus d
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

      def __expect_invite
        @_about = nil
        NOTHING_
      end

      def from_top
        @_from = nil
      end

      def from
        @_from = @_st.gets_one ; nil
      end

      def about_arguments
        @_about = "arguments"
      end

      def at_done_with_phrase_

        sym, s = @_state.lines.last
        sym == :e or fail

        if @_from
          _extra = " #{ @_from }"
        end

        ab_s = @_about
        if ab_s
          _tail = " about #{ ab_s }"
        else
          _tail = '.'  # DOT_
        end

        expect = "see 'mt#{ _extra } -h' for more#{ _tail }"

        s_ = s.gsub STYLE_RX_, EMPTY_S_
        s_.length < s.length or fail

        if s_ == expect
          ACHIEVED_
        else
          @_act = s_ ; @_exp = expect
          _fail_by :___say_etc
        end
      end

      def ___say_etc
        "needed #{ @_exp.inspect } had #{ @_act.inspect }"
      end
    end

    # ==

    module Syntax_for_Line__

      def __expect_line
        @_expect_on_channel = :e
        @_expect_is_styled = false
        _peek_for_matchee
      end

      def styled
        @_expect_is_styled = true
        _peek_for_matchee
      end

      def o
        @_expect_on_channel = :o
        _peek_for_matchee
      end

      def _peek_for_matchee

        x = @_st.current_token
        if x.respond_to? :ascii_only?
          @_matchee_shape = :__match_against_string
          @_matchee_string = x
          @_st.advance_one
        elsif x.respond_to? :named_captures
          @_matchee_shape = :__match_against_regexp
          @_matchee_regexp = x
          @_st.advance_one
        end
      end

      def at_done_with_phrase_

        sym, @_use_s = @_state.lines.fetch @_line_offset
        @_use_s.chomp!

        if sym == @_expect_on_channel

          if @_expect_is_styled
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
