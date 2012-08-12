require_relative 'test-support'

describe "#{::Skylab::CssConvert} when parsing directives" do
  include ::Skylab::CssConvert::TestSupport::InstanceMethods

  it "should parse platonic ideal", f:true do
    # cli_instance.io_adapter.debug!
    tree = parse_directives_in_file(fixture_path('001-platonic-ideal.txt'))
    tree.first.should == :merge_statement
    itf, sif, su, ls = tree.children(
      :in_the_folder, :styles_in_files, :styles_under, :merge_list)
    itf[:path].should == "test/fixtures/css"
    sif[:left].should == "documentation.css"
    sif[:right].should == "pygments.css"
    su[:left].should == ".highlight"
    su[:right].should == ".pre"
    ls.size.should == 4
    [['.keyword','.k'],['.default','.nc'],['.keyword','.p'],['.keyword', nil]].
      should == ls[0..3].map{ |x| [x[:left], x[:right]] }
  end

  it "should parse with a minimal set of directives" do
    tree = parse_directives_in_file(fixture_path('002-minitessimal.txt'))
    tree[:in_the_folder].should == false
    tree[:styles_under].should == false
    ["red.css", "blue.css"].should eql(
      tree[:styles_in_files].children(:left, :right))
    md = tree[:merge_list]
    md.size.should == 1
    md.first.first.should == :catchall_pairing
  end
end
