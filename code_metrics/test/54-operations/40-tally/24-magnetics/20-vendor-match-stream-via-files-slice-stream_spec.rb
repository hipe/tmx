require_relative '../../../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] tally - magnetics - vendor match stream via file slice stream" do

    TS_[ self ]
    use :memoizer_methods
    use :want_event
    use :operations_tally_magnetics

    it "loads" do
      _subject
    end

    it "for now, we can't yet handle tags etc" do

      o = _begin_session
      o.pattern_strings = [ '[#foo-999]' ]
      _ok = o.execute
      _ok.should eql false

      _em = want_not_OK_event

      _act = _em.to_black_and_white_line

      _act =~ %r(\Ainvalid pattern, must look [a-z ]+: "\[#foo-999\]"\z) || fail
    end

    it "but money is money" do

      _st = ___build_slice_stream

      o = _begin_session
      o.files_slice_stream = _st
      this = 'EMPTY_P_'
      o.pattern_strings = [ this, 'DO_NOT_FIND___' ]

      st = o.execute

      x = st.gets
      x_ = st.gets

      st.upstream[].exit  # this leaves the finish execution path uncovered but meh

      x.lineno.should be_respond_to :bit_length
      x_.path or fail

      [ x, x_ ].each do | x__ |
        x__.line_content.should be_include this
      end
    end

    def ___build_slice_stream
      o = begin_files_slice_stream_session_
      o.paths = [ the_asset_directory_for_this_project_ ]
      o.name_patterns = [ '*.rb' ]
      o.execute
    end

    def _begin_session
      o = _subject.new( & handle_event_selectively_ )
      o.system_conduit = Home_.lib_.open_3
      o
    end

    def _subject
      magnetics_module_::Vendor_Match_Stream_via_Files_Slice_Stream
    end
  end
end
