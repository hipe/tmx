require File.dirname(__FILE__) + '/../testlib.rb' unless Object.const_defined? 'Hipe__CssConvert__Testlib'

describe 'With just-a-comment.css' do
  it "should parse and unparse" do
    path = fixture_path('css/just-a-comment.css')
    node = parse_css_in_file(path)
    node.class.should == ::Hipe::CssConvert::CssParsing::CssFile::CssFile
    tree = node.tree
    tree.should match_the_structure_pattern(
      [:css_file, [:space, :white, :c_style_comment, :white]]
    )
    File.read(path).should == tree.unparse
  end
end
