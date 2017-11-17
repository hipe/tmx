require_relative '../../../../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] output adapters - quickie - [ test document replacement ]" do

    TS_[ self ]
    use :memoizer_methods
    use :runs
    use :output_adapters_quickie
    use :test_document_shorthand

    context '(context)' do

      it "replace my lines with something else" do  # #testpoint

        # (above line is intentionally blank)
        _product || fail
        # (next two lines are intentionally blank)


      end

      shared_subject :_margin do
"      ".freeze  # LOOK
      end

      it "the beginning and ending line still look the same" do

        a = _product.nodes

        s = _margin
        _exp = "#{ s }it \"replace my lines with something else\" do  # #testpoint\n"
        _exp_ = "#{ s }end\n"

        a[ 0 ].line_string == _exp || fail
        a[ -1 ].line_string == _exp_ || fail
      end

      it "the leading and trailing blank lines use those of the test doc" do

        a = _product.nodes
        a[ 1 ].is_blank_line || fail
        a[ -3 ].is_blank_line || fail
        a[ -2 ].is_blank_line || fail
      end

      it "the new test lines look right including the substitution" do

        a = _product.nodes
        s = "#{ _margin }  "  # #indent eek
        a[ 2 ].line_string == "#{ s }some code la la\n" || fail
        a[ 3 ].line_string == "#{ s }( fo.wobble bar ).should eql :baz\n" || fail
        7 == a.length || fail
      end

      shared_subject :_product do

        # get the existing example:

        qeg = __qualified_example_via_regex %r(\breplace my lines\b)

        _replace_example_constituent_lines_with_this qeg, <<-HERE
          #     some code la la
          #     fo.wobble bar  # => :baz
          #
        HERE
        # the final "blank" line above is intentional (won't be used)

        qeg.example_node
      end
    end

    it "(for now it does NOT pick up the formatting in the asset document)" do

      _s = <<-HERE
        it 'zizzo' do
        end
        # above block intentionally has no body lines
      HERE

      _st = line_stream_via_string_ _s
      doc = output_adapter_test_document_parser_.parse_line_stream _st

      qeg = first_qualified_example_node_with_identifying_string_in_of_ doc, 'zizzo'

      _replace_example_constituent_lines_with_this qeg, <<-HERE
        #     hi  # => :hey
        #
        #
        #
      HERE
      # the above etc has intentionally 3 trailing blank lines.
      # NOTE that for now the syntax makes it impossible to lead with
      # blank lines in a code run..

      _exp = <<-HERE
        it 'zizzo' do
          hi.should eql :hey
        end
      HERE

      _exp_st = line_stream_via_string_ _exp

      _act_st = qeg.example_node.to_line_stream

      want_actual_line_stream_has_same_content_as_expected_ _act_st, _exp_st
    end

    def __qualified_example_via_regex rx

      eg = to_qualified_example_node_stream_.flush_until_detect do |o|
        rx =~ o.example_node.document_unique_identifying_string
      end
      eg or fail
      eg
    end

    def _replace_example_constituent_lines_with_this qeg, big_s

      _cr = code_run_via_big_string_ big_s

      _cx = real_default_choices_

      _xx = _cr.to_content_line_stream_given__( _cx, & Want_no_emission_ )

      qeg.example_node.replace_constituent_lines _xx

      NIL_
    end

    shared_subject :test_document_ do

      fh = ::File.open __FILE__
      x = output_adapter_test_document_parser_.parse_line_stream fh
      fh.close
      x
    end
  end
end
