require_relative '../../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] collection adapters - git config - mutable - integration" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_emission_fail_early
    use :collection_adapters_git_config_mutable

    with_a_document_with_a_section_called_foo

    context "add a variable with an invalid name - it's not atomic" do

      it "fails (results in nil)" do
        _tuple[1] == nil || fail
      end

      it "document is modified SOMEWHAT" do
        expect_these_lines_in_array_with_trailing_newlines_ _actual do |y|
          y << "[foo]"
          y << "[wizzie]"
        end
      end

      it "event" do
        ev = _tuple.first
        ev.invalid_variable_name == :'fum-fum' || fail
      end

      shared_subject :_tuple do

        _sect = touch_section 'wizzie'

        will_call_by_ do |p|
          _sect.assign 'he he', :'fum-fum', & p
        end

        a = []
        expect :error, :invalid_variable_name do |ev|
          a.push ev
        end
        a.push execute
        a.push document_to_lines_
        a
      end
    end

    it "add a variable with a valid name ; also use `[]=` ; also to line stream" do

      _sect = touch_section 'wizzie'
      _x = _sect[ :fum_fum ] = 'he he'
      _x == 'he he' || fail

      _actual = @document.to_line_stream

      expect_these_lines_in_array_with_trailing_newlines_ _actual do |y|
        y << '[foo]'
        y << '[wizzie]'
        y << 'fum-fum = he he'
      end
    end

    def _actual
      _tuple.last
    end
  end
end
