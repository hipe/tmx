# frozen_string_literal: true

module Skylab::BeautySalon::TestSupport

  module My_CLI

    def self.[] tcc
      tcc.include self
    end

    # -

      def parse_help_screen_fail_early_

        string_st = to_errput_line_stream_strictly

        o = Zerk_test_support_[]::CLI::Expect_Section_Fail_Early.define
        yield o
        spy = o.finish.to_spy_under self
        io = spy.spying_IO

        begin
          line = string_st.gets
          line || break
          io.puts line
          redo
        end while above

        spy.finish
        NIL
      end

      # -- (pretty sure this is somewhere else)

      def oxford_split_or_ actual_s, head_s, tail_s=nil
        _oxford_split_BS_myCLI :_or_, actual_s, head_s, tail_s
      end

      def oxford_split_and_ actual_s, head_s, tail_s=nil
        _oxford_split_BS_myCLI :_and_, actual_s, head_s, tail_s
      end

      def _oxford_split_BS_myCLI which_sym, actual_s, head_s, tail_s

        _rx = %r(\A
          #{ ::Regexp.escape head_s }
          (?<body>[-, a-z"]+)
          #{ tail_s and ::Regexp.escape tail_s }
        $)x

        md0 = _rx.match actual_s
        md0 || fail

        _rx = case which_sym
        when :_and_ ; /[ ]and[ ]/
        when :_or_  ; /[ ]or[ ]/
        end

        md1 = _rx.match md0[ :body ]
        md1 || fail

        s_a = md1.pre_match.split ', '
        s_a.push md1.post_match
        s_a
      end

      # --

      define_method :invocation_strings_for_expect_stdout_stderr, ( Lazy_.call do
        [ 'chimmy' ].freeze
      end )

      def subject_CLI
        Home_::CLI2
      end
    # -

    # ==

    # ==
    # ==
  end
end
# #broke-out of toplevel testsupport
