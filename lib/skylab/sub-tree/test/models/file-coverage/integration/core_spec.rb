# encoding: utf-8

require_relative '../test-support'

module Skylab::SubTree::TestSupport::Models_File_Coverage

  # <-

describe "[st] CLI actions cov", wip: true do

  _PN = 'xyzzy3'

  text = -> x do
    txt = x.payload_x
    ::String === txt or fail "expected text had #{ txt.class }"
    txt
  end

  srbrx, srbrx2 = -> do
    rx = ::Regexp.escape TestSupport_.spec_rb
    [ /#{ rx }\z/, %r{\A\./#{ _PN }/.+#{ rx }\z} ]
  end.call

  test_files_in_hub_rx = %r(\b\d+ test files in hub\b)

  test_files_in_total_rx = %r(\b\d+ test files in all\b)

  def expect_no_more_lines
    @emit_spy.emission_a.length.zero? or fail "expected no more lines"
  end

  # (the following two are moved in here from a higher node. unintegrated)

  it "2.2 : `-h rec`       : 1) usage 2) desc 3) opts" do
    argv '-h', _CMD
    line.should match(/\Ausage: #{ PN_ } #{ _CMD }/i)
    line.should match( /^$/ )
    line.should match(/\Adescription:?\z/i)
    line.should match(/\A *see crude/i)
    line.should match(/\A +\*/)
    line.should match(/\A +\*/)
    line.should match( /^$/ )
    line.should match(/\Aoptions:?\z/i)
    l = line
    loop do
      l.should match(/\A  /)
      l = line or break
    end
    names.uniq.should eql( [ :help ] )
    result.should eql( 0 )
  end

  it "2.3 : `-h rec more`  : msg / usage / invite" do
    argv '-h', _CMD, 'wat'
    line.should match( /\bignoring: "wat"/ )
    line.should match( /\Ausage: #{ PN_ } / )
    # ..meh
    names.uniq.should eql( [ :info, :help ] )
    result.should eql( 0 )
  end

  it "show a list of matched test files only." do

    # cd into lib/skylab and ask about this subproduct itself. (yes this is
    # a self-referential test ^_^) each one of the returned events that is a
    # payload should be a "line" that is a path that is relative to where we
    # ran it from. This last event should be an :info that tells us the
    # number of files.

    cd SubTree_.dir_pathname.dirname do
      argv CMD_, '-l', "./#{ PN_ }/test"
    end

    scn = Callback_::Stream.via_nonsparse_array emission_a
    em = scn.gets
    em.stream_symbol.should eql :payload

    begin

      s = text[ em ]
      s.should match srbrx2

      em = scn.gets
      if :payload == em.stream_symbol
        redo
      end

      em.stream_symbol.should eql :info
      s = text[ em ]
      s.should match test_files_in_hub_rx

      em = scn.gets
      if :payload == em.stream_symbol
        redo
      end
    end while false

    em.stream_symbol.should eql :info
    text[ em ].should match test_files_in_total_rx

    em = scn.gets
    em.should be_nil

    result.should eql 0
  end

  it "show a shallow tree of matched test files only." do
    argv CMD_, '-s', Abs_testdir_[]
    scn = Callback_::Stream.via_nonsparse_array emission_a
    em = scn.gets
    em.stream_symbol.should eql :payload
    text[ em ].should match %r(\A/.+/test\z)  # first line is test dir abspath
    em = scn.gets
    em.stream_symbol.should eql :payload
    begin
      text[ em ].should match srbrx
      em = scn.gets
      if :payload == em.stream_symbol
        redo
      end
    end while false
    em.stream_symbol.should eql :info
    text[ em ].should match test_files_in_hub_rx
    em = scn.gets
    em.stream_symbol.should eql :info
    text[ em ].should match test_files_in_total_rx
    em = scn.gets
    em.should be_nil
    result.should eql 0
  end

  it "Couldn't find test directory: foo/bar/[test|spec|features]" do
    a = CMD_, SubTree_.dir_pathname.join( 'models' ).to_s
    argv( * a )
    # NOTE :+#bad-test direcotry is relatived to whatever CWD is
    line.should match %r(\bCouldn't find test directory: .+/models/\[test\|spec\|features\b)
    result.should eql SubTree_::CLI::EXITSTATUS_FOR_ERRROR__
  end

  FIXTRS_ = SubTree_.dir_pathname.join( 'test-fixtures' )

  context "basic" do

    it "one" do
      cd FIXTRS_.to_s do
        argv CMD_, 'one'
      end
      line = shift_raw_line
      line.should match( /\Aone, test[ ]+\e\[#{ WHITE_ }m\[\+\|-\]\e\[0m\z/ )
      line = shift_raw_line
      line.should eql( " └foo.rb, foo_spec.rb  \e[#{ GREEN_ }m[+|-]\e[0m" )
      expect_no_more_lines
    end

    WHITE_ = 37 ; GREEN_ = 32

    def shift_raw_line
      @emit_spy.emission_a.shift.payload_x
    end
  end

  false and it "LOOK AT THAT BEAUTIFUL COV TREE" do
    cd SubTree_.dir_pathname.dirname.to_s do
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

  def build_client
    build_client_for_both
  end

end

# ->

end

# :+#tombstone: this used to be home to [#ts-010] "dark hack"
