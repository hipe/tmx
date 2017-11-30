require_relative '../../../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] tally - magnetics - digraph" do

    # this test is based around trying to generate a document that is
    # structurally similar to [#013]/document-1.

    # NOTE - to debug the generated document visually, turn debugging on
    # before the performer performs (like as the first line in `_state`).
    # this will multiplex the output to std*out*. whether running one test
    # or many, it should only output the document once (because memoization).
    # if you redirect the stdout to a file, you can try opening the generated
    # document in graph viz.

    TS_[ self ]
    use :memoizer_methods
    use :operations_tally_magnetics

    it "loads" do
      _subject
    end

    shared_subject :_state do

      o = _subject.new

      o.document_label = 'wazoozle'
      o.features_section_label = 'Wazoozle'
      o.bucket_tree_section_label = 'Wizzie feature tree'

      o.graph_structure = ___build_mock

      o.upstream_line_yielder = _start_upstream_line_yielder

      o.execute
      _flush_state
    end

    it "document label on line 3" do
      expect( _state.lines.fetch 2 ).to match %r(\A[ ]{2}label="wazoozle"$)
    end

    it "features label on line 6" do
      expect( _state.lines.fetch 5 ).to match %r(\A[ ]{4}label="Wazoozle"$)
    end

    it "label for feature tree" do
      expect( _state.big_string ).to match %r(^[ ]{4}label="Wizzie feature tree"$)
    end

    it "the last assocation" do
      expect( _state.lines.fetch( -2 ) ).to match %r(^[ ]{2}bucket2->feature3$)
    end

    it "one feature item" do
      expect( _state.big_string ).to match %r(^[ ]{4}feature3 \[label="method 3"\]$)
    end

    it "the last bucket item" do
      expect( _state.big_string ).to match %r(^[ ]{8}bucket4 \[label="jimmy jam"\]$)
    end

    def ___build_mock

      o = _other_module
      _Graph_Structure = o::Graph_Structure___
      _Feat = o::Feature___
      _OG = o::Occurrence_Group___

      a = []

      single = [ nil ].freeze

      a.push _OG.new( :feature1, :bucket1, [nil, nil] )
      a.push _OG.new( :feature2, :bucket2, single )
      a.push _OG.new( :feature2, :bucket3, single )
      a.push _OG.new( :feature2, :bucket4, single )
      a.push _OG.new( :feature3, :bucket1, single )
      a.push _OG.new( :feature3, :bucket2, single )

      _occurrence_groups = a

      a = []

      a.push _Feat.new :feature1, "method 1"
      a.push _Feat.new :feature2, "method 2"
      a.push _Feat.new :feature3, "method 3"
      a.push _Feat.new :feature4, "method not used"

      _features = a

      _bucket_tree = ___build_bucket_tree

      _Graph_Structure.new(
        _occurrence_groups,
        _features,
        _bucket_tree,
      )
    end

    def ___build_bucket_tree

      _LB = _other_module::Leaf_Bucket___

      t = Home_.lib_.basic::Tree::Mutable.new

      o = -> path, x do

        _p = -> do
          x
        end

        t.touch_node path, :leaf_node_payload_proc, _p
      end

      o[ '/foo/bar/file-1', _LB.new( :bucket1, 'file 1' ) ]
      o[ '/foo/bar/file-3', _LB.new( :bucket3, 'file 3' ) ]
      o[ '/foo/bar/file-2', _LB.new( :bucket2, 'file 2' ) ]

      o[ '/foo/bar/wizlo/bazlo/jj', _LB.new( :bucket4, 'jimmy jam' ) ]

      t
    end

    def _other_module
      magnetics_module_::Graph_Structure_via_Match_Stream
    end

    def _subject
      magnetics_module_::Digraph_via_Graph_Structure_and_Parameters
    end

    # --

    def _start_upstream_line_yielder

      a = []

      p = -> delimited_line do
        a.push delimited_line
      end

      if do_debug
        up = p
        stdout = TestSupport_.lib_.stdout  # ..
        p = -> delimited_line do
          stdout.write delimited_line
          up[ delimited_line ]
        end
      end

      @_lines = a

      ::Enumerator::Yielder.new do | delimited_line |
        p[ delimited_line ]
      end
    end

    def _flush_state
      a = remove_instance_variable :@_lines
      _State.new a.join( EMPTY_S_ ), a
    end

    dangerous_memoize :_State do
      ::Struct.new :big_string, :lines
    end
  end
end
