require_relative '../../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] API - synchronize - compond compound" do

    TS_[ self ]
    use :fixture_files
    use :my_API

    context "create (no existing test file)" do

      call_by do

        _asset = fixture_file_ '25-compound-compound.kd'  # #coverpoint5-6

        my_API_common_generate_(
          asset_line_stream: ::File.open( _asset ),
        )
      end

      shared_subject :document_node_tuple_ do

        a = only_describe_node_via_result_.immediates :context_node
        2 == a.length || fail
        a_ = []
        a_ << ( filter_endcaps_and_blank_lines_common_ a[0].nodes )
        a_ << ( filter_endcaps_and_blank_lines_common_ a[1].nodes )
      end

      it "const def 1" do
        _class 'X_xkcd_Foo', _at( 0, 0 )
      end

      it "const def 2" do
        _class 'X_xkcd_Bar', _at( 1, 0 )
      end

      it "test 1" do
        _test "test one", "X_xkcd_Foo.foo", _at( 0, 1 )
      end

      it "test 2" do
        _test "test two", "X_xkcd_Bar.bar", _at( 1, 1 )
      end
    end

    context "multiline" do

      call_by do

        _asset = fixture_file_ '26-compound-edge.kd'

        my_API_common_generate_(
          asset_line_stream: ::File.open( _asset ),
        )
      end

      shared_subject :document_node_tuple_ do
        n_significant_nodes_from_only_context_node_via_result_ 3
      end

      it "const definition" do

        want_unindented_at_ 0, <<-HERE
          before :all do
            class X_xkcd_Bar
              xx
            end
          end
        HERE
      end

      it "shared subject" do

        want_unindented_at_ 1, <<-HERE
          shared_subject :p do
            foo = X_xkcd_Bar.new

            p = -> *a do
              line 1/2
              line 2/2
            end

            p
          end
        HERE
      end

      it "first test" do

        want_unindented_at_ 2, <<-HERE
          it "description for the first test" do
            expect( p[ 1, 2, 3 ] ).to eql "no: 3 for 1..2"
          end
        HERE
      end
    end

    # -- custom assertions

    def _class s, nodes
      _exp = "        class #{ s }\n"
      nodes[1].line_string == _exp || fail
    end

    def _test dsc, const, nodes

      _exp = "      it \"#{ dsc }\" do\n"
      nodes[0].line_string == _exp || fail

      _exp = "        expect( #{ const } ).to"
      _act = nodes[1].line_string[ 0, _exp.length ]
      _act == _exp || fail
    end

    def _at d, d_
      _ctx = document_node_tuple_.fetch d
      _ctx.fetch( d_ ).nodes
    end
  end
end
