require_relative '../../../../../test-support'

module Skylab::BeautySalon::TestSupport

  describe "[bs] models - S & R - models - read only file session", wip: true do

    extend TS_
    use :models_search_and_replace_actors_build_file_scan_support

    it "BFS loads" do
      actors_::Build_file_stream
    end

    it "normal - (unlike grep we get one entry per match not per line)" do

      file_session_stream = actors_::Build_file_stream.with :upstream_path_stream,
        build_stream_for_single_path_to_file_with_three_lines_,
        :ruby_regexp, /\bwazoozle\b/i,
        :read_only

      one_file = file_session_stream.gets
      file_session_stream.gets.should be_nil

      ms = one_file.to_read_only_match_stream
      first = ms.gets
      mid = ms.gets
      last = ms.gets
      ms.gets.should be_nil

      first.lineno.should eql 1
      mid.lineno.should eql 3
      last.lineno.should eql 3

      # make a mess-test to prove that in the input we have two matches
      # on one line, and in the output we render each match individually,
      # rendering that same line redundantly multiple times, each time
      # highlighting each next match on that line.

      mid_match = mid.dup_with :do_highlight, true
      last_match = last.dup_with :do_highlight, true

      ls = mid_match.to_line_stream
      mid_match_line = ls.gets
      ls.gets.should be_nil

      last_match_line = last_match.to_line_stream.to_a.join EMPTY_S_

      p = Home_.lib_.brazen::CLI_Support::Styling::Parse_styles

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
