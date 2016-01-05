require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] magnetics - (10) read only file session stream" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event

    it "the subject performer loads" do
      _subject
    end

    def _subject
      magnetics_::File_Session_Stream_via_Parameters
    end

    context "unlike grep we get one entry per match not one per line" do

      shared_subject :state_ do

        _st = build_stream_for_single_path_to_file_with_three_lines_

        o = _subject.new( & no_events_ )
        o.for = :read_only
        o.ruby_regexp = /\bwazoozle\b/i
        o.upstream_path_stream = _st
        file_session_stream = o.execute

        one_file = file_session_stream.gets
        another_file = file_session_stream.gets

        ms = one_file.to_read_only_match_stream
        first_match = ms.gets
        second_match = ms.gets
        third_match = ms.gets
        fourth_match = ms.gets

        _My_Struct.new(
          one_file,
          another_file,
          first_match,
          second_match,
          third_match,
          fourth_match,
        )
      end

      dangerous_memoize :_My_Struct do

        x = ::Struct.new :one_file, :another_file,
          :first_match, :second_match, :third_match, :fourth_match

        Struct_1_1_1_1 = x
        x
      end

      it "there was only one file" do

        o = state_
        o.one_file or fail
        o.another_file and fail
      end

      it "in the first file there are three matches" do

        o = state_
        o.third_match or fail
        o.fourth_match and fail
      end

      it "each match knows what line number it came from" do

        o = state_
        o.first_match.lineno.should eql 1
        o.second_match.lineno.should eql 3
        o.third_match.lineno.should eql 3
      end

      context "since matches can be multi-line (with `do_highlight`):" do

        # NOTE - in two lines there were three matches. the second and
        # third match are on the same line (the second line). it is these
        # two matches that we focus on below..

        alias_method :super_, :state_

        shared_subject :state_ do

          o = super_

          to_lines = -> div do

            _expag = Home_::CLI.highlighting_expression_agent_instance__
            _st = div.to_line_stream_under _expag
            _st.to_a
          end

          [ to_lines[ o.second_match ],
            to_lines[ o.third_match], ]
        end

        it "you can convert the match itself to a \"line\" stream" do

          a = state_
          a.fetch( 0 ).length.should eql 1
          a.fetch( 1 ).length.should eql 1
          a.length.should eql 2
        end

        it "the match is highlighted within the full line" do

          a = state_

          mid_strings = _treat a.fetch 0
          last_strings = _treat a.fetch 1

          mid_strings.should eql(
            [ "when i say \"", "wazoozle", "\" i mean WaZOOzle!\n" ] )

          last_strings.should eql(
            [ "when i say \"wazoozle\" i mean ", "WaZOOzle", "!\n" ] )
        end

        define_method :_treat, -> do

          parse_styles = nil
          setup = -> do
            setup = nil
            parse_styles = Home_.lib_.brazen::CLI_Support::Styling::Parse_styles
          end

          -> lines do
            setup && setup[]

            parts = []
            lines.each do | line |
              sexp = parse_styles[ line ]
              sexp.each do | x |
                if :string == x.first
                  parts.push x.last
                end
              end
            end
            parts
          end

        end.call
      end
    end
  end
end
