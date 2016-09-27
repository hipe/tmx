module Skylab::DocTest::TestSupport

  module Models::Code_Line

    def self.[] tcc
      tcc.include self
    end

    # -

      def code_line_tuple_for_ line

        _cl = __code_line_via_string line
        _cae = __copula_assertion_entity_via_code_line _cl
        _cac = __copula_assertion_controller_via_copula_assertion_entity _cae

        el = Common_.test_support::Expect_Event::EventLog.for self

        _l = el.handle_event_selectively

        _st = _cac.to_line_stream( & _l )

        _lines = _st.to_a
        _em_a =  el.flush_to_array

        [ _lines, _em_a ]
      end

      def __copula_assertion_controller_via_copula_assertion_entity cae

        copula_assertion_view_controller_class_.via_two_(
          cae, :_expect_cx_not_used_ )
      end

      def __copula_assertion_entity_via_code_line cl

        Home_::Models_::CopulaAssertion.via_code_line__(
          cl, :_expect_cx_not_used_ )
      end

      def __code_line_via_string str

        # (tragic. so fragile. what happens when you don't test first)

        md = RX___.match str
        whole_string = md.offset 0
        second_spaces = md.offset 1
        actual_thing = md.offset 2
        copula_thing = md.offset 3
        expected_thing = md.offset 4

        cl = Home_::Models_::Code::Line___.allocate
        cl.instance_exec do
          @_content_range = actual_thing.first ... expected_thing.last
          @copula_range = copula_thing.first ... copula_thing.last
          @has_magic_copula = true
          @LTS_range = expected_thing.last ... whole_string.last
          @_margin_range = second_spaces.first ... second_spaces.last
          @string = str
        end
        cl
      end

      RX___ = /\A[ ]+#([ ]+)(.+[^ ])(  # => )(.+)\n\z/

      def exactly_one_result_line_
        _exactly_one result_lines_
      end

      def exactly_one_emission_
        _exactly_one emissions_
      end

      def _exactly_one a
        1 == a.length || fail
        a.fetch 0
      end

      def result_lines_
        code_line_tuple_.fetch 0
      end

      def emissions_
        code_line_tuple_.fetch 1
      end
    # -
  end
end
