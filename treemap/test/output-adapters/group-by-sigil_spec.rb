require_relative '../test-support'

module Skylab::Treemap::TestSupport

  describe "[tr] output-adapters - group by sigil" do

    TS_[ self ]
    use :want_event

    it "OK (small representative sample)" do

      # #lends-coverage to [#sy-008.03] (test side)
      # #lends-coverage to [#fi-008.16]

      _path = Fixture_file_[ 'eg-050-small-representative-sample' ]

      stdin = Home_.lib_.system.test_support::STUBS.interactive_STDIN_instance
      stdout = TS_.string_IO.new
      stderr = :_stderr_not_called_TR_

      call_API(
        :session,
        :upstream_reference, _path,
        :stdin, stdin,
        :stdout, stdout,
        :stderr, stderr,
        :output_adapter, 'group-by-sigi',
      )

      want_succeed

      stdout.rewind

      want_these_lines_in_array_with_trailing_newlines_ stdout do |y|
        y << '[ab]...(3)'
        y << '[cd].(1)'
        y << '(4 tests over 2 sigil changes)'
      end
    end
  end
end
