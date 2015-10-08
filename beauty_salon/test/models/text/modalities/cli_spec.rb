require_relative '../../../test-support'

module Skylab::BeautySalon::TestSupport

  describe "[bs] CLI wrap" do

    extend TS_
    use :modality_integrations_CLI_support

    it "help screen has some customizations (fragile..)" do

      @_stdin = :_not_used_by_help_screen_

      invoke 'wrap', '-h'

      a = flush_baked_emission_array

      a.fetch( -11 ).string.should be_include '(default: 80)'  # ..
      a.last.string.should be_include 'non-interactive'
    end

    it "via a file" do

      @_stdin = _stdin_mocks.interactive_STDIN_instance

      _path = TestSupport_::Fixtures.file( :one_line )

      invoke 'wrap', '-n14', '-v', _path

      expect :e, "(line range union: 1-INFINITY)"

      stream_for_expect_stdout_stderr.unparsed_count.should eql 5

      expect :o, "a file with"
    end

    it "via STDIN" do

      @_stdin = _stdin_mocks.noninteractive_STDIN_class.new_via_lines(
        [ "one two\n", "three four\n" ] )

      invoke 'wrap', '-n5', '-'
      expect :o, "one"
      expect :o, "two"
    end

    it "not both" do

      @_stdin = _stdin_mocks.noninteractive_STDIN_instance
      invoke 'wrap', '-n1', 'xx'

      expect :e, %r(\Acouldn't wrap text because ambiguous upstr)
      expect :e

      expect_failed
    end

    def _stdin_mocks
      Home_.lib_.system.test_support::Mocks
    end

    def stdin_for_expect_stdout_stderr
      @_stdin
    end
  end
end
