require_relative '../test-support'

module Skylab::BeautySalon::TestSupport::Models::S_and_R::Actors_BFS

  describe "[bs] models - S & R - models - read only file session " do

    extend TS_

    it "BFS loads" do
      Actors_[]::Build_file_stream
    end

    it "normal - (unlike grep we get one entry per match not per line)" do

      file_session_stream = Actors_[]::Build_file_stream.with :upstream_path_stream,
        build_stream_for_single_path_to_file_with_three_lines,
        :ruby_regexp, /\bwazoozle\b/i,
        :read_only

      one_file = file_session_stream.gets
      file_session_stream.gets.should be_nil

      ms = one_file.to_read_only_match_stream
      first = ms.gets
      mid = ms.gets
      last = ms.gets
      ms.gets.should be_nil

      first.line_number.should eql 1
      mid.line_number.should eql 3
      last.line_number.should eql 3

      # make a mess-test to prove that in the input we have two matches
      # on one line, and in the output we render each match individually,
      # rendering that same line redundantly multiple times, each time
      # highlighting each next match on that line.

      mid_match = mid.dup_with :do_highlight, true
      last_match = last.dup_with :do_highlight, true

      ls = mid_match.to_line_stream
      mid_match_line = ls.gets
      ls.gets.should be_nil

      last_match_line = last_match.to_line_stream.to_a.join BS_::EMPTY_S_

      p = BS_._lib.CLI_lib.parse_styles

      mid_sexp = p[ mid_match_line ]
      last_sexp = p[ last_match_line ]

      p = -> sexp do
        sexp.reduce [] do |m, x|
          if :string == x.first
            m.push x.last
          end
          m
        end
      end

      mid_strings = p[ mid_sexp ]
      last_strings = p[ last_sexp ]

      mid_strings.should eql(
        [ "when i say \"", "wazoozle", "\" i mean WaZOOzle!\n" ] )

      last_strings.should eql(
        [ "when i say \"wazoozle\" i mean ", "WaZOOzle", "!\n" ] )

    end
  end
end
