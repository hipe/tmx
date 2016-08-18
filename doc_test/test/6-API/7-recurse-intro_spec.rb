require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] API - recurse intro" do

    TS_[ self ]
    use :my_API
    # use :expect_event
    # use :stubbed_FS

    it "path is required", wip: true do

      _rx = /\Amissing required attribute 'path'\z/

      begin
        call_API :recursive
      rescue ::ArgumentError => e
      end

      e.message.should match _rx
    end

    it "enum works #frontier", wip: true do

      call_API :recursive, :path, 'not-there', :sub_action, :no_wai

      expect_not_OK_event :invalid_attribute_value,
        "invalid sub action (ick :no_wai), expecting { list | preview }"

      expect_failed
    end

    it "'list' only those files relevant to the path. emits no events, result is stream", wip: true do  # #old-wip:2015-04

      call_API :recursive, :sub_action, :list, :path, sidesystem_path_

      expect_no_events

      st = @result
      one = st.gets
      two = st.gets
      st.gets.should be_nil

      one.path.should match %r(/doc-test/core\.rb\z)
      two.path.should match %r(/generate/core\.rb\z)
    end

    it "'preview' adds a conditional property requirement", wip: true do

      call_API :recursive, :sub_action, :preview, :path, 'x'

      _em = expect_not_OK_event :missing_required_properties

      black_and_white( _em.cached_event_value ).should eql(
        "missing required attribute 'downstream'\n" )

      expect_failed
    end

    it "'preview' results in a stream of \"generation\"s", wip: true do  # #old-whip:2015-04

      downstream = build_IO_spy_downstream_for_doctest

      call_API :recursive, :sub_action, :preview, :path,

        sidesystem_path_,

        :downstream, downstream

      gen_stream = @result


      _gen = gen_stream.gets

      x = _gen.execute

      x.should eql nil

      ev = expect_neutral_event :current_output_path

      ev.to_event.path.should match %r( integration/final/top_spec\.rb \z)x

      ev = expect_neutral_event :wrote

      expect_no_more_events

      ( 28 .. 33 ).should be_include ev.to_event.line_count

      gen_ = gen_stream.gets

      gen_.output_path.should match %r( integration/core_spec\.rb \z)x

      x = gen_stream.gets

      x.should be_nil

      validate_content_of_the_generated_file_of_interest downstream

    end

    def validate_content_of_the_generated_file_of_interest io
      string_IO = io[ :buffer ]
      string_IO.rewind
      string_IO.gets.should eql "require_relative '../test-support'\n"
    end
  end
end