# frozen_string_literal: will_not_work_here  #here1

require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe "[bs] operations - wrap" do

    TS_[ self ]
    use :my_API
    use :modality_agnostic_interface_things

    subject_dig = %i( text wrap )

    context 'number not a number' do

      it 'fails' do
        _event || fail
      end

      it 'explains' do
        _ev = _event
        _actual = black_and_white _ev
        _actual == "'num-chars-wide' must be an integer, had \"zango\"" || fail
      end

      shared_subject :_event do

        call( * subject_dig,
          :num_chars_wide, 'zango',
        )
        _my_expect_failed_by :uninterpretable_under_number_set
      end
    end

    context 'number too low' do

      it 'fails' do
        _event || fail
      end

      it 'explains' do
        _ev = _event
        _actual = black_and_white _ev
        _actual == "'num-chars-wide' must be greater than or equal to 1, had -1" || fail
      end

      shared_subject :_event do

        call( * subject_dig,
          :num_chars_wide, -1,
        )
        _my_expect_failed_by :number_too_small
      end
    end

    context 'money' do

      it 'wrapped.' do
        _actual = _tuple[1]
        expect_these_lines_in_array_with_trailing_newlines_ _actual do |y|
          # :#here1:
          y << "it's time for"
          y << "WAZOOZLE, see"
          y << "fazzoozle my noozle"
          y << "when i say \"wazoozle\""
          y << "i mean WaZOOzle!"
        end
      end

      it '(no info messages)' do
        _tuple.first.length.zero? || fail
      end

      shared_subject :_tuple do

        info_output_lines = EMPTY_A_  # implicity asserts that it is not written to
        payload_output_lines = []

        _path = universal_fixture_ :three_lines

        upstream_io = ::File.open _path

        call( * subject_dig,

          :output_bytestream, payload_output_lines,
          :informational_downstream, info_output_lines,

          :upstream, upstream_io,
          :num_chars_wide, 22,
        )

        expect_API_result_for_success_

        upstream_io.closed? || fail  # #coverpoint3.1

        [ info_output_lines, payload_output_lines ]
      end
    end

    # -- setup & execution

    def _my_expect_failed_by sym

      # (there's a issue - these emissions should be corrected to have
      # this same symbol)

      ev = nil
      expect :error, :invalid_property_value do |ev_|
        ev = ev_
      end
      expect_result nil  # (expect_API_result_for_success_, expect_API_result_for_failure_ are same)
      ev.terminal_channel_symbol == sym || fail
      ev
    end

    def expression_agent  # override our own simpler default
      expression_agent_instance_for_legacy_API_
    end

    def universal_fixture_ sym
      TestSupport_::Fixtures.file( sym )
    end

    # ==

    # ==
    # ==
  end
end
# #history-A.1: full rewrite for ween off matryoshka
