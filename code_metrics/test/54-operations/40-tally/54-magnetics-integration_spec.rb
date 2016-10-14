require_relative '../../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cme] models - 4 - 3 performer integration" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event

    shared_subject :_state do

      _path = Fixture_tree_two_[]

      _ignore_path = ::File.join Fixture_tree_two_[], 'Server.scala'

      _words = %w( String Wazoozle )

      big_string = ""

      p = -> line do
        big_string.concat line
      end

      if do_debug
        orig_p = p
        sout = TestSupport_.lib_.stdout
        p = -> line do
          sout << line  # this works only because we delimit our lines
          orig_p[ line ]
        end
      end

      _yielder = ::Enumerator::Yielder.new( & p )

      call_API( :tally,
        :stdout, _yielder,
        :name, [ '*.scala' ],  # comment out to fail one test
        :ignore_path, [ _ignore_path ],  # comment out to fail another test
        :path, [ _path ],
        :word, _words,
      )

      _State.new(
        remove_instance_variable( :@result ),
        big_string,
      )
    end

    it "succeeds" do
      _state.result.should eql true
    end

    it "does not include the file filtered out because extension" do

      _state.big_string.include?( 'some.java' ).should eql false
    end

    it "does not include the file filtered out b.c ignore path" do

      _state.big_string.include?( 'Server.scala' ).should eql false
    end

    it "the associations look right" do

      _rx = /^.+\n.+\n.+\n\z/
      _md = _rx.match _state.big_string
      _act = _md[ 0 ]

      _exp = <<-HERE.gsub! %r(^[ ]{8}), EMPTY_S_
          bucket1->feature0 [label="(2x)"]
          bucket2->feature0 [label="(5x)"]
        }
      HERE

      _act.should eql _exp
    end

    dangerous_memoize :_State do
      x = ::Struct.new :result, :big_string
      Models_4_3_Struct = x
      x
    end
  end
end
