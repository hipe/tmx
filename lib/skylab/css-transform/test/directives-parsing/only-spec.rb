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
end
