# encoding: utf-8
require_relative '../test-support'

describe "#{ ::Skylab::CovTree } CLI action: tree" do
  extend ::Skylab::CovTree::TestSupport::CLI


  it "show a list of matched test files only." do

    cd CovTree.dir_pathname.dirname do         # cd to lib/skylab ..
      args 'tree', '-l', './cov-tree'          # and ask about this subproduct
    end                                        # itself. (yes this is a self-
                                               # referential test ^_^)


    while pair = stack.shift                   # each one of the returned
      type, str = pair                         # events that is a payload
      if :payload == type                      # should be a "line" that is
        str.should match( %r{ \A \./cov-tree\/.+_spec\.rb \z }x ) # a path
      else                                     # that is relative to where
        type.should eql(:info)                 # we ran it from. This last
        str.should match(/\d test files total/) # event should be an :info
        stack.should be_empty                  # that tells us the number of
        break                                  # files.
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
    cd CovTree.dir_pathname.dirname.to_s do
      args 'tree', 'cov-tree'
    end
    line.should match(/\Acov-tree, cov-tree\/test +\[\+\|-\]\z/)
    line.should match(/\A ├api +\[ \|-\]\z/)
    l = line
    loop do
      l.include? 'tree_spec.rb' and break
      l = line or fail("didn't find tree_spec.rb anywhere in tree")
    end
    l.should eql( ' │ │ └tree.rb, tree_spec.rb  [+|-]' ) # we hate happiness
    types.uniq.should eql([:payload])
    result.should eql(true)
  end
end
