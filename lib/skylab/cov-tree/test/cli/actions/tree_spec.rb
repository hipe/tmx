# encoding: utf-8
require_relative 'test-support'
require 'fileutils'

describe "#{ ::Skylab::CovTree } CLI action: tree" do
  extend ::Skylab::CovTree::TestSupport::CLI


  it "show a list of matched test files only." do
    args 'tree', '-l', CovTree.dir_pathname.to_s

    while pair = stack.shift
      type, str = pair
      if :payload == type
        str.should match(/cov-tree\/.+_spec\.rb\z/)
      else
        type.should eql(:info)
        str.should match(/\d test files total/)
        stack.should be_empty
        break
      end
    end

    result.should eql(true)
  end


  it "show a shallow tree of matched test files only." do
    args 'tree', '-t', CovTree.dir_pathname.to_s
    while pair = stack.shift
      type, str = pair
      if :payload == type
        if /\A[^ ]/ =~ str
          str.should match(/\/test\/\z/) # silly
        else
          str.should match(/_spec\.rb\z/)
        end
      else
        type.should eql(:info)
        str.should match(/\d test files total/)
      end
    end
  end


  it "Couldn't find test directory: foo/bar/[test|spec|features]" do
    args 'tree', CovTree.dir_pathname.join('models').to_s
    line.should match(/\ACouldn't find test directory.+\[test\|spec\|features/)
    result.should eql(nil)
  end


  it "LOOK AT THAT BEAUTIFUL COV TREE" do
    ::FileUtils.cd CovTree.dir_pathname.dirname.to_s do
      args 'tree', 'cov-tree'
    end
    line.should match(/\Acov-tree, cov-tree\/test +\[\+\|-\]\z/)
    line.should match(/\A ├api +\[ \|-\]\z/)
    l = line
    loop do
      l.include? 'tree_spec.rb' and break
      l = line or fail("didn't find tree_spec.rb anywhere in tree")
    end
    l.should match(/\A │ └tree\.rb, tree_spec\.rb  \[\+\|-\]\z/)
    types.uniq.should eql([:payload])
    result.should eql(true)
  end
end
