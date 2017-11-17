require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] ersatz parser - edges" do

    TS_[ self ]
    use :memoizer_methods
    use :want_event
    use :ersatz_parser

    # -
      it "when an opening line is in too far" do

        _input_string = <<-HERE
          begin "hi"
              begin "hey"
                begin "howdy"
                end
             end
          end
        HERE

        _parse _input_string
        _want_error '"hey"', 2
      end

      it "when a closing line is in too far" do

        _input_string = <<-HERE
          begin "hi"
             begin "hej"
                begin "howdy"
                end
              end
          end
        HERE

        _parse _input_string
        _want_error '"hej"', 2
      end

      it "when it doesn't appear to end" do

        _parse _same_string
        _want_error '"oi"', 2
      end

      it "without event handler, throws exception" do

        _ec = ersatz_lib_module_::ParseError
        _s = _same_string
        _p = grammar_one_parser_

        begin
          _p.parse_string _s
        rescue _ec => e
        end

        want_message = <<-HERE.unindent
          hack failed: couldn't find end line for node opened on line 2
            line 2: "  begin \\"oi\\"\\n"
            (3 lines in file.)
        HERE
        want_message.chomp!  # we put no trailing LTS's in exception messages

        e.message == want_message || fail
      end

      shared_subject :_same_string do

        <<-HERE.unindent
          begin "hi"
            begin "oi"
          end
        HERE
      end

    # -

    def _want_error substr, lineno

      @_result == false || fail

      want_one_event :parse_error do |em|
        em.lineno == lineno || fail
        em.line.include? substr or fail
        em.error_subcategory == :ending_line_not_found
      end
    end

    def _parse input_string

      _p = event_log.handle_event_selectively

      @_result = grammar_one_parser_.parse_string input_string, & _p

      NIL_
    end
  end
end
