require_relative '../../../test-support'

module Skylab::System::TestSupport

  describe "[sy] - filesystem - sessions - tmpfile sessioner" do

    extend TS_

    it "won't create more directories than it is allowed to" do

      o = _common_setup_two
      o.create_at_most_N_directories 1
      begin
        o.session
      rescue => e
      end

      e.should be_kind_of ::Errno::ENOENT
    end

    it "creates those directories since necessary" do

      o = _common_setup_two

      path_a = o.__resolve_directory

      ::File.basename( path_a.first ).should eql 'one'
      ::File.basename( path_a.last ).should eql 'two'
    end

    it "get busy" do

      _o = _common_setup_two
      _expect_good_session _o
    end

    it "convoluted proof of rollover" do

      _during_crazy_thing do | o |

        o.max_number_of_simultaneous_tmpfiles 2

        _expect_good_session o

      end
    end

    it "convoluted proof of limit hit" do

      _during_crazy_thing do | o |

        o.max_number_of_simultaneous_tmpfiles 1

        begin
          o.session
        rescue ::RuntimeError => e
        end
        e.message.should match %r(\Areached max number of simultaneous\b)
      end
    end

    def _during_crazy_thing

      sess = _common_setup_two
      2 == sess.__resolve_directory.length or fail

      _exe_path = Home_::TestSupport.dir_pathname.join( 'fixture-bin/omg' ).to_path
      i, o, _e, t = Home_.lib_.open3.popen3 _exe_path

      _tmpdir_path = sess.instance_variable_get :@_tmpdir_path
      _file_path = ::File.join _tmpdir_path, '0'

      i.puts _file_path
      i.flush

      _s = o.gets
      s = "OK, locked file: "
      s = _s[ 0, s.length ] or fail

      x = yield sess

      i.puts "xyzzy"
      s = o.gets
      "goodbye (xyzzy).\n" == s or fail( s )
      t.value.exitstatus.zero? or fail
      x
    end

    def _common_setup_two

      td = memoized_tmpdir_.clear
      o = _subject.new

      o.tmpdir_path ::File.join( td.path, 'one/two' )
      o.create_at_most_N_directories 2
      o.using_filesystem services_.filesystem

      o
    end

    def _expect_good_session o

      hold_on_to_fh = nil
      _x = o.session do | fh |

        fh.write 'x.'
        fh.flush
        fh.stat.size.should eql 2
        hold_on_to_fh = fh
        :_hi_
      end

      _x.should eql :_hi_
      hold_on_to_fh.closed?.should eql true
    end

    def _subject
      Home_::Services___::Filesystem::Sessions_::Tmpfile_Sessioner
    end
  end
end
