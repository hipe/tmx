require_relative 'test-support'

describe "[cssc] when parsing directives" do

  extend ::Skylab::CSS_Convert::TestSupport
  use :expect_event

  it "should parse platonic ideal" do

    tree = parse_directives_in_file_ fixture_path_ '001-platonic-ideal.txt'

    tree.first.should eql(:merge_statement)
    itf, sif, su, ls = tree.children(
      :in_the_folder, :styles_in_files, :styles_under, :merge_list)
    itf[:path].should eql("test/fixtures/css")
    sif[:left].should eql("documentation.css")
    sif[:right].should eql("pygments.css")
    su[:left].should eql(".highlight")
    su[:right].should eql(".pre")
    ls.size.should eql(4)
    [['.keyword','.k'],['.default','.nc'],['.keyword','.p'],['.keyword', nil]].
      should eql ls[0..3].map{ |x| [x[:left], x[:right]] }
  end

  it "should parse with a minimal set of directives" do

    tree = parse_directives_in_file_ fixture_path_ '002-minitessimal.txt'

    tree[:in_the_folder].should eql(false)
    tree[:styles_under].should eql(false)
    ["red.css", "blue.css"].should eql(
      tree[:styles_in_files].children(:left, :right))
    md = tree[:merge_list]
    md.length.should eql(1)
    md.first.first.should eql(:catchall_pairing)
  end
end
