require_relative 'test-support'

describe "[cssc] with 'just-a-comment.css'" do

  extend ::Skylab::CSS_Convert::TestSupport

  it "should parse and unparse"
  if false
    path = fixture_path 'css/just-a-comment.css'
    node = parse_css_in_file path
    node.class.should.eql( CSSC_::CssParsing::CssFile::CssFile )
    tree = node.tree
    tree.should match_the_structure_pattern(
      [:css_file, [:space, :white, :c_style_comment, :white]]
    )
    ::File.read(path).should == tree.unparse
  end
end
