require_relative '../../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] collection adapters - git config - mutable - macros and edges" do

    TS_[ self ]
    use :memoizer_methods
    use :collection_adapters_git_config_mutable

    it "marshal correctly with backslashes" do

      doc = _build_new_empty_document

      _sect = doc.sections.touch_section 'sub.sect', 'se-ct'

      _sect[ :two_characters ] = '\b'

      _actual = doc.write_bytes_into []

      expect_these_lines_in_array_with_trailing_newlines_ _actual do |y|
        y << '[se-ct "sub.sect"]'
        y << 'two-characters = \\\\b'
      end

      # the value that was
      # input as two characters (the backslash character then the 'b' character)
      # became three: a backslash, a backslash, 'b'
    end

    it "unmarshal correctly with backslashes" do  # :#cov1.4

      _cfg_path = fixture_path_ '00-escape.cfg'

      doc = subject_module_.parse_document_by do |o|
        o.upstream_path = _cfg_path
        o.listener = Home_::CollectionAdapters::GitConfig::LISTENER_THAT_RAISES_ALL_NON_INFO_EMISSIONS_
      end

      _sect = doc.sections.first

      a = _sect.assignments.to_stream_of_assignments.to_a

      scn = Home_::Scanner_[ a ]

      o = -> sym, & p do
        asmt = scn.gets_one
        asmt.external_normal_name_symbol == sym || fail
        p[ asmt.value ]
      end

      o.call :three_characters do |s|
        s.length == 3 || fail
        s == ( '\\' '\\' 'b' ) || fail
      end

      o.call :two_characters do |s|
        s.length == 2 || fail
        s == ( '\\' 'b' ) || fail
      end

      o.call :combine_these do |s|
        s == 'foobiff bazbar' || fail
      end
    end

    context "add comments, get stream of lines" do

      # (as used in [br])

      it "you can add a comment with this one method" do
        _doc || fail
      end

      it "use this one method to get a stream of lines" do

        _actual = _doc.to_line_stream

        expect_these_lines_in_array_with_trailing_newlines_ _actual do |y|
          y << "# hello mother"
        end
      end

      shared_subject :_doc do

        doc = _build_new_empty_document
        doc.add_comment 'hello mother'
        doc
      end
    end

    def _build_new_empty_document
      subject_module_.new_empty_document
    end
  end
end
# #tombstone-A: the `write` macro is gone
