require_relative 'test-support'

describe 'With just-a-comment.css' do
  include ::Skylab::CssConvert::TestSupport::InstanceMethods

  it "should parse and unparse", wip:true do
    path = fixture_path('css/just-a-comment.css')
    node = parse_css_in_file(path)
    node.class.should == ::Skylab::CssConvert::CssParsing::CssFile::CssFile
    tree = node.tree
    tree.should match_the_structure_pattern(
      [:css_file, [:space, :white, :c_style_comment, :white]]
    )
    File.read(path).should == tree.unparse
  end
end
