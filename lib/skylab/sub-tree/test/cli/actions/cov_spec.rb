# encoding: utf-8

require_relative 'test-support'

module Skylab::SubTree::TestSupport::CLI::Actions::Cov

  ::Skylab::SubTree::TestSupport::CLI::Actions[ self ]

  include CONSTANTS

  PN_.class

  CMD_ = 'cov'.freeze

  RELATIVE_TESTDIR_NO_DOT_ = "#{ PN_ }/test"

  Abs_testdir_ = -> do
    SubTree.dir_pathname.join( 'test' ).to_s
  end

  # (this used to be home to "dark hack" [#ts-010] but we modernized it)

# lose indent 1x
describe "#{ SubTree } CLI action: tree" do   # Quickie compatible !

  extend SubTree::TestSupport::CLI

  text = -> x do
    txt = x.payload_x
    ::String === txt or fail "expected text had #{ txt.class }"
    txt
  end

  srbrx, srbrx2 = -> do
    rx = ::Regexp.escape TestSupport::FUN._spec_rb[]
    [ /#{ rx }\z/, %r{\A\./#{ PN_ }/.+#{ rx }\z} ]
  end.call

  it "show a list of matched test files only." do
    cd SubTree.dir_pathname.dirname do         # cd to lib/skylab ..
      argv CMD_, '-l', "./#{ PN_ }/test"       # and ask about this subproduct
    end                                        # itself. (yes this is a self-
                                               # referential test ^_^)
                                               # each one of the returned
    while e = emission_a.shift                 # events that is a payload
      if :payload == e.stream_name             # should be a "line" that is
        text[ e ].should match( srbrx2 )       # a path
      else                                     # that is relative to where
        e.stream_name.should eql( :info )      # we ran it from. This last
        text[ e ].should match(/\d test files total/) # event should be an :info
        emission_a.should be_empty              # that tells us the number of
        break                                  # files.
      end
    end

    result.should eql( 0 )
  end

  it "show a shallow tree of matched test files only." do
    argv CMD_, '-s', Abs_testdir_[]
    while e = emission_a.shift
      if :payload == e.stream_name
        if /\A[^ ]/ =~ text[ e ]
          text[ e ].should match(/\/test\/\z/) # silly
        else
          text[ e ].should match( srbrx )
        end
      else
        e.stream_name.should eql( :info )
        text[ e ].should match(/\d test files total/)
      end
    end
  end

  it "Couldn't find test directory: foo/bar/[test|spec|features]" do
    argv CMD_, SubTree.dir_pathname.join('models').to_s
    line.should match(/\ACouldn't find test directory.+\[test\|spec\|features/)
    result.should eql( 1 )
  end

  FIXTRS_ = SubTree.dir_pathname.join( 'test-fixtures' )

  context "basic" do

    it "one" do
      cd FIXTRS_.to_s do
        argv CMD_, 'one'
      end
      line = shift_raw_line
      line.should match( /\Aone, test[ ]+\e\[#{ WHITE_ }m\[\+\|-\]\e\[0m\z/ )
      line = shift_raw_line
      line.should eql( " └foo.rb, foo_spec.rb  \e[#{ GREEN_ }m[+|-]\e[0m" )
    end

    WHITE_ = 37 ; GREEN_ = 32

    def shift_raw_line
      @emit_spy.emission_a.shift.payload_x
    end
  end

  ::Skylab::TestSupport::Stderr_[].puts( ::Skylab::Headless::CLI::Pen::FUN.stylize[ "    <<< SKIPPING COV TREE INTEGRATION >>>", :red ] )
  false and it "LOOK AT THAT BEAUTIFUL COV TREE" do
    debug!
    cd SubTree.dir_pathname.dirname.to_s do
      argv CMD_, RELATIVE_TESTDIR_NO_DOT_
    end
    line.should match(/\A#{ PN_ }, (?:#{ PN_ }\/)?test +\[\+\|-\]\z/)
    line.should match(/\A ├api +\[ \|-\]\z/)
    l = line
    loop do
      l.include? 'cov_spec.rb' and break
      l = line or fail("didn't find tree_spec.rb anywhere in tree")
    end
    names.uniq.should eql( [ :payload ] )
    result.should eql( 0 )
  end
end
# gain indent 1x
end
