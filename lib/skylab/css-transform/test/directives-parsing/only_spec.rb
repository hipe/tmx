require File.dirname(__FILE__) + '/../testlib.rb' unless Object.const_defined? 'Hipe__CssConvert__Testlib'

describe 'directives parsing' do
  it "should parse platonic ideal" do
    tree = parse_directives_in_file(fixture_path('001-platonic-ideal.txt'))
    tree.node_type.should == :merge_statement
    itf, sif, su, ls = tree.children(:in_the_folder, :styles_in_files, :styles_under, :merge_list)
    itf[:path].should == "test/fixtures"
    sif[:left].should == "documentation.css"
    sif[:right].should == "pygments.css"
    su[:left].should == ".highlight"
    su[:right].should == ".pre"
    ls.size.should == 4
    [['.keyword','.k'],['.default','.nc'],['.keyword','.p'],['.keyword', nil]].should ==
      ls[0..3].map{|x| [x[:left], x[:right]]}
  end

  it "should parse with a minimal set of directives", :minimal => true do
    tree = parse_directives_in_file(fixture_path('002-minitessimal.txt'))
    tree[:in_the_folder].should == false
    tree[:styles_under].should == false
    ["red.css", "blue.css"].should == tree[:styles_in_files].children(:left, :right)
    md = tree[:merge_list]
    md.size.should == 1
    md.first.node_type.should == :catchall_pairing
  end
end
