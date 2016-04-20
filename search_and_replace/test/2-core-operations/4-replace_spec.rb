require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] core operations - replace" do

    TS_[ self ]
    use :my_API

    shared_subject :_the_edit_session_prototype do

      _dir = the_wazizzle_worktree_

      state = call(
        :ruby_regexp, /\bHAHA\b/,
        :path, _dir,
        :filename_pattern, '*',
        :search,
        :replacement_expression, 'GOOD JERB',
        :replace,
      )

      a = state.result.to_a
      1 == a.length or fail
      a.fetch 0
    end

    def _match_controller
      edit_session_.first_match_controller
    end

    context "when the replacement is *not* engaged" do

      def edit_session_  # do NOT mutate
        _the_edit_session_prototype
      end

      it "the match controller knows that the replacement is *not* engaged" do

        _match_controller.replacement_is_engaged.should eql false
      end
    end

    context "when the replacement *is* engaged" do

      def edit_session_
        _performance_tuple.fetch 0
      end

      def __emissions_array
        _performance_tuple.fetch 1
      end

      def __performance_result
        _performance_tuple.fetch 2
      end

      shared_subject :_performance_tuple do

        _proto = _the_edit_session_prototype
        es = _proto.dup  # this IS the use of [#014]
        _mc = es.first_match_controller

        _oes_p = event_log.handle_event_selectively

        _ok_x = _mc.engage_replacement( & _oes_p )

        a = [ es ]
        a.push @event_log.flush_to_array
        a.push _ok_x
        a
      end

      it "calling `engage_replacement` on the m.c results in true" do

        __performance_result.should eql true
      end

      it "the match controller in an engaged state knows it is engaged" do

        _match_controller.replacement_is_engaged.should eql true
      end

      context "this won't clobber the original file for you but you can.." do

        def __output_big_string
          _my_tuple.fetch 0
        end

        def __emissions
          _my_tuple.fetch 1
        end

        shared_subject :_my_tuple do

          el = build_event_log  # create a new one, because etc..

          _oes_p = el.handle_event_selectively

          _x = edit_session_.write_output_lines_into "", & _oes_p

          _emissions = el.flush_to_array

          [ _x, _emissions ]
        end

        it "you can write the output lines to whatever context you want." do

          __output_big_string.should eql "  ok oh my geez --> GOOD JERB <--\n"
        end

        it "it emits one emission, the number of bytes written" do

          em_a = __emissions
          1 == em_a.length or fail
          _ = em_a.fetch( 0 ).should be_emission :info, :data, :number_of_bytes_written

          _.cached_event_value.should eql 34
        end
      end

      context "the replacement expression can be disengaged again" do

        shared_subject :_tuple do

          _es_proto = edit_session_
          _my_es = _es_proto.dup
          mc = _my_es.first_match_controller
          _x = mc.disengage_replacement
          [ _x, mc ]
        end

        it "the match controller knows it is not engaged after this" do
          _tuple.fetch( 1 ).replacement_is_engaged.should eql false
        end

        it "the successful result of the call is TRUE (parallels `engage[..]`)" do
          _tuple.fetch( 0 ).should eql true
        end
      end
    end
  end
end
