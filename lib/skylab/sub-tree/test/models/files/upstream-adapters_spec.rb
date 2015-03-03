require_relative '../../../test-support'  # #todo:change-this-at-step:8

module Skylab::SubTree::TestSupport

  describe "[st] API actions my-tree from stream", wip: true do

    it "expag loads" do
      SubTree_::API::Actions::My_Tree::EXPRESSION_AGENT_
    end

    it "expag renders a thing" do
      _s = SubTree_::API::Actions::My_Tree::EXPRESSION_AGENT_.calculate do
        a = [ par( 'foo_bar' ), par( 'biz' ) ]
        "#{ both( a ) }#{ and_ a } are ok."
      end
      _s.should eql 'both <foo bar> and <biz> are ok.'
    end

    it "reads from an open filehandle" do
      io = fixtures_dir_pn.join( _OFO ).open 'r'
      f = start_front_with_upstream io
      f.with_parameters :path_a, NIL_A_, :verbose, ( 3 if do_debug )
      r = f.flush
      r.should eql true
      @o.string.should eql PRETTY_
      io.should be_closed
    end

    _OFO = 'one-find.output'.freeze

    it "reads from a file" do
      f = start_front
      f.with_parameters :path_a, NIL_A_, :file, fixtures_dir_pn.join( _OFO )
      r = f.flush
      r.should eql true
      @o.string.should eql PRETTY_
    end

    it "fake stdin and file - can't read from both stdin and file" do
      f = start_front_with_upstream _MOCK_IO
      f.with_parameters :path_a, NIL_A_, :file, :fake_file
      r = f.flush
      r.should eql false
      @e.string.should eql( "can't read input from both <stdin> and <file>\n" )
      @o.string.length.should be_zero
    end

    it "file and one path - can't read from both path and file" do
      f = start_front
      f.with_parameters :path_a, [ :fake_path ], :file, :fake_file
      r = f.flush
      r.should eql( false )
      @e.string.should match( /can't.+both.+path.+and.+file/ )
    end

    it "all three - can't read from a, b, and c" do
      r = start_front_with_upstream( _MOCK_IO ).with_parameters(
        :path_a, [ :fake_path ], :file, :Fake_file
      ).flush
      r.should eql false
      @e.string.
        should eql "can't read input from <stdin>, <path> and <file>\n"
    end

    it "from path (using find) with funky path" do
      f = start_front.with_parameters :path_a, %w( not-there )
      r = f.flush
      @o.string.should be_empty
      @e.string.should match(
        /\Afind: not-there: No such file or directory \(exitstatus 1\)\n\z/ )
      r.should eql false
    end

    it "from good path (using find) - pretty (well done)" do
      f = start_front.with_parameters :path_a, %w( one ) ; r = nil
      SubTree_::Library_::FileUtils.cd fixtures_dir_pn do
        r = f.flush
      end
      @e.string.should be_empty
      @o.string.should eql PRETTY_
      r.should eql true
    end

    class Mock_IO_  # #change-this-at=step:8  etc. move up, w/e
      def closed?
        false
      end
      def close
      end
      def tty?
        false
      end
    end
    _MOCK_IO = Mock_IO_.new
  end
end
