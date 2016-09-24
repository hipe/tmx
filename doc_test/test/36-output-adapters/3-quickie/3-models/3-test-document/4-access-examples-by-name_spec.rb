require_relative '../../../../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] output adapters - [quickie test document] - access by name" do

    TS_[ self ]
    use :memoizer_methods
    use :output_adapters_quickie
    use :test_document_shorthand

    context '(context)' do

      it "i am the first test in this document. can you see me?" do

        eg = first_example_node_  # WAHOOTEY

        eg.nodes.fetch(2).line_string == "        eg = first_example_node_  # WAHOOTEY\n" || fail

        _ = eg.document_unique_identifying_string
        _ == "i am the first test in this document. can you see me?" || fail
      end

      it "can you access this second test by name?" do

        _s = "can you access this second test by name?"

        qeg = first_qualified_example_node_with_identifying_string_ _s
        qeg || fail
        _eg = qeg.example_node
        _eg.nodes.fetch( -2 ).line_string.include?( "OUCH_MY_BRAIN" ) || fail
      end

      it "can you access \"this\" third test? (it has quotes)" do

        _s = 'can you access "this" third test? (it has quotes)'

        _qeg = first_qualified_example_node_with_identifying_string_ _s

        _eg = _qeg.example_node

        _eg.nodes.fetch( -2 ).line_string.include?( 'HECK_YEAH' ) || fail
      end
    end

    context '(context 2)' do

      it "what about over here, can you get to this one in another context?" do

        s = "what about over here"

        _qeg = to_qualified_example_node_stream_.flush_until_detect do |o|
          x = o.example_node.document_unique_identifying_string
          if x.respond_to? :ascii_only?
            x.include? s
          end
        end

        _eg = _qeg.example_node

        _eg.nodes.fetch( -2 ).line_string.include?( 'NICE_WORK' ) || fail
      end
    end

    shared_subject :test_document_ do

      fh = ::File.open __FILE__
      x = output_adapter_test_document_parser_.parse_line_stream fh
      fh.close
      x
    end
  end
end
