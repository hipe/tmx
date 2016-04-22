require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] non-interactive CLI - counts" do

    TS_[ self ]
    Require_Zerk_[]
    Zerk_.test_support::Non_Interactive_CLI::Help_Screens[ self ]

    # for two reasons (boredom and necessity) some of the tests here are
    # perhaps unacceptably chunky. but see these tests as rough experiments
    # for conceptual would-be features for the testing lib to support.
    #
    # basically they're experiments at testing enough but not too much, of
    # the content of help screens. (and if we find it useful enough, push up)

    context "(counts help)" do

      given_screen do
        argv 'search', 'counts', '-h'
      end

      it "usage line: those options look good" do

        # eek a custom thing that says "of the 'right half' of the terms
        # in the usage line, they should all match this one regex"..

        bx = build_index_of_first_usage_line

        len = bx.length
        4 < len or fail

        _st = Callback_::Stream.via_range( 4 ... len )

        rx = %r(\A\[-[a-z] X\]\z)  # "[-a X]", "[-b X]" etc

        bad_a = _st.map_by do |d|
          bx.at_position d
        end.reduce_by do |s|
          rx !~ s
        end.to_a

        if bad_a.length.nonzero?
          fail ___say_not_opts bad_a
        end
      end

      def ___say_not_opts bad_s_a
        "didn't look like options: (#{ bad_s_a.join ', ' })"
      end

      it "description is there" do
        _ = %r(\bthe grep --count option\b)
        section( :description ).raw_line( 0 ).should be_line( :styled, _ )
      end

      it "options - note plurals do not show" do

        # eek - make sure every term in the pool is there (but allow others),
        #       and make sure none of the longs "look" plural (like i said EEK)

        _pool_a = %w( replacement-expression functions-directory ruby-regexp )
        # ("random sampling" of the first three items at writing)

        pool_h = ::Hash[ _pool_a.map { |s| [ s, true ] } ]

        opt = nil
        maybe_check_pool = -> do

          _yes = pool_h.delete opt.long_stem
          if _yes && pool_h.length.zero?
            maybe_check_pool = Home_::EMPTY_P_
          end
        end

        bad = nil
        rx = /s\z/  # eek
        check_plurality = -> do
          if rx =~ opt.long_stem
            ( bad ||= [] ).push ol
          end
        end

        st = build_index_of_option_section.to_value_stream

        while ( opt = st.gets )
          maybe_check_pool[]
          check_plurality[]
        end

        if pool_h.length.nonzero?
          fail __say_pool pool_h
        end

        if bad
          fail
        end
      end

      def __say_pool pool_h
        "still in pool: (#{ pool_h.keys * ', ' })"
      end
    end

    context "(counts missing args)" do

      given do
        argv 'search', 'counts'
      end

      it "cascading explanation of graph" do

        a = niCLI_state.lines

        _ = "to 'search' 'counts', must 'files-by-grep'"
        a[ -3 ].should be_line( :e, _ )

        _rx = %r('files-by-grep' is missing required parameter <ruby-regexp>)
        a[ -2 ].should be_line( :styled, :e, _rx )
      end
    end

    context "(counts cash money)" do

      given do

        _path = common_haystack_directory_

        argv( 'search', 'counts',
          '--ruby-regexp', '/wazoozle/i',
          '-p', _path,
          '--fil', '*.txt', '--filen', '*.orange',
        )
      end

      it "note sing-plural works" do

        a = niCLI_state.lines.reduce [] do |m, li|
          if :o == li.stream_symbol
            m << li
          end
          m
        end

        2 == a.length or fail
        # (order is not guaranteed by the filesystem .. so .. that.)
        a.first.should be_line( %r(\bsome-orange\.orange - 1 matching line\b) )
        a.last.should be_line( %r(\bthree-lines\.txt - 2 matching lines\b) )
      end
    end

    def subject_CLI
      Home_::CLI
    end
  end
end
