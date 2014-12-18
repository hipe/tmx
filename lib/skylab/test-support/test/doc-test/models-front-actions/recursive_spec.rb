require_relative '../test-support'

module Skylab::TestSupport::TestSupport::DocTest

  describe "[ts] doc-test - [ actions ] - recursive " do

    # TestLib_::Mock_FS[ self ]
    TestLib_::Expect_event[ self ]

    extend TS_

    it "path is required" do
      _rx = /\Amissing required property 'path'\z/
      -> do
        call_API :recursive  # (worked)
      end.should raise_error ::ArgumentError, _rx
    end

    it "enum works #frontier" do
      call_API :recursive, :path, 'not-there', :sub_action, :no_wai
      expect_not_OK_event :invalid_property_value,
        "invalid sub_action (ick :no_wai), expecting { list | preview }"
      expect_failed
    end

    it "'list' only those files relevant to the path. emits no events, result is stream" do

      call_API :recursive, :sub_action, :list, :path, Subject_[].dir_pathname.to_path

      expect_no_events

      st = @result
      one = st.gets
      two = st.gets
      st.gets.should be_nil

      ::File.basename( one.path ).should eql 'core.rb'
      ::File.basename( two.path ).should eql 'generate.rb'
    end

    it "'preview' adds a conditional property requirement" do

      call_API :recursive, :sub_action, :preview, :path, 'x'

      ev = expect_not_OK_event :missing_required_properties

      black_and_white( ev ).should eql "missing required property 'downstream'"

      expect_failed

    end

    it "'preview' results in a stream of \"generation\"s" do

      downstream = build_IO_spy_downstream_for_doctest

      call_API :recursive, :sub_action, :preview, :path,

        Subject_[].dir_pathname.to_path,

        :downstream, downstream

      gen_stream = @result


      _gen = gen_stream.gets

      x = _gen.execute

      x.should eql true

      ev = expect_neutral_event :current_output_path

      ev.to_event.path.should match %r( integration/final/top_spec\.rb \z)x

      ev = expect_neutral_event :wrote

      expect_no_more_events

      ( 43 .. 45 ).should be_include ev.to_event.line_count

      gen_ = gen_stream.gets

      gen_.manifest_entry.path.should match %r( actions/generate\.rb \z)x

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
