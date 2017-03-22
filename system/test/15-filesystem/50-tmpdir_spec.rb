require_relative '../test-support'

module Skylab::System::TestSupport

  describe "[sy] - filesystem - tmpdir" do

    TS_[ self ]
    define_singleton_method :dangerous_memoize_, TestSupport_::DANGEROUS_MEMOIZE

    it "with no pathname - you get ::Dir.tmpdir for your system" do

      _tmpdir = Home_::Filesystem::Tmpdir.with
      _tmpdir.to_path.should eql ::Dir.tmpdir
    end

    it "relative path (don't!) - raises" do

      _tmpdir = _new_with :path, 'relative-path-no-see'

      begin
        _tmpdir.prepare
      rescue ::SecurityError => e
      end

      e.message.should match %r(\Aunsafe tmpdir name - \.\z)
    end

    it "relative path (don't!), but in pwd tmp/ - raises" do

      _tmpdir = _new_with :path, 'relpath-no-see', :be_verbose, true
      _from_here = sandbox_dir_

      e = nil
      fu_.cd _from_here do
        begin _tmpdir.prepare
        rescue ::SecurityError => e
        end
      end

      e.message.should match %r(\bunsafe tmpdir name - \.)
    end

    it "path that would exceed max_mkdirs - raises" do

      _path = ::File.join sandbox_dir_, 'ts-foo/ts-bar'

      _tmpdir = _new_with :path, _path

      begin _tmpdir.prepare
      rescue ::SecurityError => e
      end

      e.message.should match %r(\Awon't make more than 1 dirs .+ts-foo must exist)
    end

    it "path 1 lvl down - works" do

      current = ::File.join sandbox_dir_, 'ts-foo-1'

      # fu_.rmdir current  # ??

      _tmpdir = _new_with :path, current

      a = _tmpdir.prepare

      a.length.should eql(1)
      a.first.should eql current
      ::File.exist?( current ).should eql true

      fu_.rmdir current
    end

    it "path 2 lvls down, max_mkdirs is set to 2 - works" do

      dirname = ::File.join sandbox_dir_, 'ts-foo-2'
      subject_dir = ::File.join dirname, 'bar'

      _tmpdir = _new_with :path, subject_dir, :max_mkdirs, 2

      a = _tmpdir.prepare

      ::File.exist?( subject_dir ).should eql true

      a.length.should eql(1)
      a.first.should eql subject_dir

      fu = fu_
      fu.rmdir subject_dir
      fu.rmdir dirname
    end

    it "path 3 lvls down, 1 exists, max_dirs 2 - OK" do

      dirname = ::File.join sandbox_dir_, 'ts-foo-3'
      subject_dir = ::File.join dirname, 'foo/bar'

      fu_.mkdir dirname

      tmpdir = _new_with :path, subject_dir, :max_mkdirs, 2

      a = tmpdir.prepare
      a.length.should eql(1)
      a.first.should eql subject_dir

      fu = fu_
      fu.rmdir subject_dir
      fu.rmdir ::File.dirname subject_dir
      fu.rmdir dirname
    end

    it "1 lvl down, exists with a file in it - file gets BLOWN" do

      subject_dir = ::File.join sandbox_dir_, 'ts-dir-with-file'
      subject_file = ::File.join subject_dir, 'some-file'

      fu = fu_
      fu.mkdir subject_dir
      fu.touch subject_file

      tmpdir = _new_with :path, subject_dir

      ::File.exist?( subject_file ).should eql true

      tmpdir.prepare

      ::File.exist?( subject_dir ).should eql true
      ::File.exist?( subject_file ).should eql false

      fu.rmdir subject_dir
    end

    it "tmpdir path exists and is not a directory - raises" do

      subject_path = ::File.join sandbox_dir_, 'ts-some-file'
      fu = fu_

      fu.touch subject_path
      _tmpdir = _new_with :path, subject_path, :be_verbose, true

      begin _tmpdir.prepare
      rescue ::Errno::ENOTDIR => e
      end

      e.message.should match %r(\bNot a directory - .+ts-some-file)

      fu.rm subject_path
    end

    it "some arbitrary unsafe path - stops you b/c exceeds max mkdirs" do

      _tmpdir = _new_with :path, '/some/unholy/path'

      begin _tmpdir.prepare
      rescue ::SecurityError => e
      end

      e.message.should match %r{won't make more than 1.+some/unholy must ex}
    end

    it "same as above but you up the max_mkdirs - stops you b/c unsafe name" do

      _tmpdir = _new_with :path, '/some/unholy/path', :max_mkdirs, 4

      begin _tmpdir.prepare
      rescue ::SecurityError => e
      end

      e.message.should eql 'unsafe tmpdir name - /'
    end

    it "a path at lvl 1 from root - unsafe name - stops you" do

      _tmpdir = _new_with :path, '/unholy'

      begin _tmpdir.prepare
      rescue ::SecurityError => e
      end

      e.message.should match %r(\bunsafe tmpdir name - \/)
    end

    def _new_with * x_a
      Home_::Filesystem::Tmpdir.via_iambic x_a
    end

    dangerous_memoize_ :sandbox_dir_ do

      # check whether we need to create this "sandbox directory" max once
      # during all the tests in this file. it's OK to create & destroy nodes
      # within this sandbox, but don't ever remove this directory itself.

      # remember we are testing the Tmpdir which has the sole responsibilty
      # in this universe of doing `mkdir -p` for tmpdirs. so we don't engage
      # in clever bootstrapping silliness here - the parent dir of the below
      # dir must exist as a prerequisite for this test.

      path = services_.defaults.dev_tmpdir_path

      if ! ::File.exist? path
        fu_.mkdir path
      end

      path
    end
  end
end
