require_relative 'test-support'

describe "[cssc] with 'just-a-comment.css'" do

  Skylab::CSS_Convert::TestSupport[ self ]
  use :want_event

  it "should parse and unparse (PLACEHOLDER)" do

    _path = fixture_path_ 'css/just-charset.css'

    _pa = build_CSS_parser__

    sn = _pa.syntax_node_via_path _path

    expect( sn.singleton_class.ancestors[ 1 ] ).to eql(
      ::Skylab::CSS_Convert::CSS_::Grammar::CSS_Document::Stylesheet7 )

    expect( sn.elements[ 0 ].elements[ 1 ].elements[ 1 ].text_value ).to eql 'foo'

    if false  # in 2012 or before, maybe was:

    expect( node.class ).to eql Home_::CssParsing::CssFile::CssFile
    tree = node._to_final_parse_tree_
    expect( tree ).to match_the_structure_pattern(
      [:css_file, [:space, :white, :c_style_comment, :white]]
    )
    # ::File.read(path).should == tree.unparse  # xx
    end
  end
end
