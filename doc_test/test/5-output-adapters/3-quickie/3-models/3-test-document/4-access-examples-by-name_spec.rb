require_relative '../../../../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] output adapters - [quickie test document] - access by name" do

    TS_[ self ]
    use :memoizer_methods
    use :output_adapters_quickie

    context '(context)' do

      it "i am the first test in this document. can you see me?" do

        eg = _doc.first_example_node  # WAHOOTEY

        eg.nodes.fetch(2).line_string == "        eg = _doc.first_example_node  # WAHOOTEY\n" || fail

        _ = eg.identifying_string
        _ == "i am the first test in this document. can you see me?" || fail
      end

      it "can you access this second test by name?" do

        _s = "can you access this second test by name?"

        hi = _doc.first_example_node_with_identifying_string _s

        hi || fail

        hi.nodes.fetch( -2 ).line_string.include?( "OUCH_MY_BRAIN" ) || fail
      end

      it "can you access \"this\" third test? (it has quotes)" do

        _s = 'can you access "this" third test? (it has quotes)'

        _hi = _doc.first_example_node_with_identifying_string _s

        _hi.nodes.fetch( -2 ).line_string.include?( 'HECK_YEAH' ) || fail
      end
    end

    context '(context 2)' do

      it "what about over here, can you get to this one in another context?" do

        s = "what about over here"
        _hi = _doc.to_example_node_stream.flush_until_detect do |eg|
          eg.identifying_string.include? s
        end

        _hi.nodes.fetch( -2 ).line_string.include?( 'NICE_WORK' ) || fail
      end
    end

    shared_subject :_doc do

      fh = ::File.open __FILE__
      x = output_adapter_test_document_parser_.parse_line_stream fh
      fh.close
      x
    end
  end
end
