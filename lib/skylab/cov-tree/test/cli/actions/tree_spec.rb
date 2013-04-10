# encoding: utf-8
require_relative '../test-support'

module Skylab  # [#ts-010]
# ..
describe "#{ CovTree } CLI action: tree" do  # Quickie maybe..

  extend CovTree::TestSupport::CLI

  text = -> x do
    txt = x.payload_x
    ::String === txt or fail "expected text had #{ txt.class }"
    txt
  end

  it "show a list of matched test files only." do
    cd CovTree.dir_pathname.dirname do         # cd to lib/skylab ..
      argv 'tree', '-l', './cov-tree'          # and ask about this subproduct
    end                                        # itself. (yes this is a self-
                                               # referential test ^_^)

                                               # each one of the returned
    while e = emission_a.shift                    # events that is a payload
      if :payload == e.stream_name             # should be a "line" that is
        text[ e ].should match( %r{ \A \./cov-tree\/.+_spec\.rb \z }x ) # a path
      else                                     # that is relative to where
        e.stream_name.should eql( :info )      # we ran it from. This last
        text[ e ].should match(/\d test files total/) # event should be an :info
        emission_a.should be_empty                # that tells us the number of
        break                                  # files.
      end
    end

    result.should eql( 0 )
  end

  it "show a shallow tree of matched test files only." do
    argv 'tree', '-t', CovTree.dir_pathname.to_s
    while e = emission_a.shift
      if :payload == e.stream_name
        if /\A[^ ]/ =~ text[ e ]
          text[ e ].should match(/\/test\/\z/) # silly
        else
          text[ e ].should match(/_spec\.rb\z/)
        end
      else
        e.stream_name.should eql( :info )
        text[ e ].should match(/\d test files total/)
      end
    end
  end

  it "Couldn't find test directory: foo/bar/[test|spec|features]" do
    argv 'tree', CovTree.dir_pathname.join('models').to_s
    line.should match(/\ACouldn't find test directory.+\[test\|spec\|features/)
    result.should eql( 1 )
  end


  it "LOOK AT THAT BEAUTIFUL COV TREE" do
    cd CovTree.dir_pathname.dirname.to_s do
      argv 'tree', 'cov-tree'
    end
    line.should match(/\Acov-tree, cov-tree\/test +\[\+\|-\]\z/)
    line.should match(/\A ├api +\[ \|-\]\z/)
    l = line
    loop do
      l.include? 'tree_spec.rb' and break
      l = line or fail("didn't find tree_spec.rb anywhere in tree")
    end
    l.should eql( ' │ │ └tree.rb, tree_spec.rb  [+|-]' ) # we hate happiness
    names.uniq.should eql([:payload])
    result.should eql( 0 )
  end
end
# ..
end
