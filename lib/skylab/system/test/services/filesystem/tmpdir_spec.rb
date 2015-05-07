require_relative '../../test-support'

module Skylab::System::TestSupport

  describe "[sy] - services - filesystem - tmpdir" do

    extend TS_
    use :services_filesystem_tmpdir

    it "with no pathname - you get ::Dir.tmpdir for your system" do
      tmpdir = _subject.new
      tmpdir.to_path.should eql ::Dir.tmpdir
    end

    it "relative path (don't!) - raises" do
      tmpdir = _subject :path, 'TMPDIR-TEST-NEVER-SEE'
      begin
        tmpdir.prepare
      rescue ::SecurityError => e
      end
      e.message.should match %r(\Aunsafe tmpdir name - \.\z)
    end

    it "relative path (don't!), but in pwd tmp/ - raises" do
      tmpdir = _subject.new :path, 'TMPDIR-TEST-NEVER-SEE', :be_verbose, true
      from_here = anchor_
      e = nil
      fu_.cd from_here do
        begin tmpdir.prepare
        rescue ::SecurityError => e
        end
      end
      e.message.should match( /unsafe tmpdir name - \./ )
    end

    it "path that would exceed max_mkdirs - raises" do
      _path = anchor_.join 'ts-foo/ts-bar'
      tmpdir = _subject.new :path, _path
      begin tmpdir.prepare
      rescue ::SecurityError => e
      end
      e.message.should match %r(\Awon't make more than 1 dirs .+ts-foo must exist)
    end

    it "path 1 lvl down - works" do
      current = anchor_.join 'ts-foo-1'
      (clean = -> do
        fu_.rmdir current
      end)[ ]
      tmpdir = _subject.new :path, current
      a = tmpdir.prepare
      a.length.should eql(1)
      a.first.should eql(current.to_s)
      current.exist?.should eql(true)
      clean[ ]
    end

    it "path 2 lvls down, max_mkdirs is set to 2 - works" do
      parent = anchor_.join 'ts-foo-2'
      target = parent.join 'bar'
      (clean = -> do
        fu_.rmdir target
        fu_.rmdir parent
      end)[ ]
      tmpdir = _subject.new :path, target, :max_mkdirs, 2
      a = tmpdir.prepare
      target.exist?.should eql(true)
      a.length.should eql(1)
      a.first.should eql(target.to_s)
      clean[ ]
    end

    it "path 3 lvls down, 1 exists, max_dirs 2 - OK" do
      parent = anchor_.join 'ts-foo-3'
      target = parent.join 'foo/bar'
      (clean = -> do
        fu_.rmdir target
        fu_.rmdir target.dirname
        fu_.rmdir parent
      end)[ ]
      fu_.mkdir parent
      tmpdir = _subject.new :path, target, :max_mkdirs, 2
      a = tmpdir.prepare
      a.length.should eql(1)
      a.first.should eql(target.to_s)
      clean[ ]
    end

    it "1 lvl down, exists with a file in it - file gets BLOWN" do
      target = anchor_.join 'ts-dir-with-file'
      target_file = target.join 'some-file'
      (clean = -> do
        target_file.exist? and fu_.rm( target_file )
        fu_.rmdir target
      end)[ ]
      fu_.mkdir target
      fu_.touch target.join('some-file')
      tmpdir = _subject.new :path, target
      target_file.exist?.should eql(true)
      tmpdir.prepare
      target.exist?.should eql(true)
      target_file.exist?.should eql(false)
      clean[ ]
    end

    it "tmpdir path exists and is not a directory - raises" do
      target = anchor_.join 'ts-some-file'
      (clean = -> do
        target.exist? and fu_.rm( target )
      end)[ ]
      fu_.touch target
      tmpdir = _subject.new :path, target, :be_verbose, true
      begin tmpdir.prepare ; rescue ::Errno::ENOTDIR => e ; end
      e.message.should match( /Not a directory - .+ts-some-file/ )
      clean[ ]
    end

    it "some arbitrary unsafe path - stops you b/c exceeds max mkdirs" do
      tmpdir = _subject.new :path, '/some/unholy/path'
      begin tmpdir.prepare ; rescue ::SecurityError => e ; end
      e.message.should match( %r{won't make more than 1.+some/unholy must ex} )
    end

    it "same as above but you up the max_mkdirs - stops you b/c unsafe name" do
      tmpdir = _subject.new :path, '/some/unholy/path', :max_mkdirs, 4
      begin tmpdir.prepare ; rescue ::SecurityError => e ; end
      e.message.should eql('unsafe tmpdir name - /')
    end

    it "a path at lvl 1 from root - unsafe name - stops you" do
      tmpdir = _subject.new :path, '/unholy'
      begin tmpdir.prepare ; rescue ::SecurityError => e ; end
      e.message.should match( /unsafe tmpdir name - \// )
    end

    def _subject * x_a
      if x_a.length.zero?
        services_.filesystem.tmpdir
      else
        services_.filesystem.tmpdir( * x_a )
      end
    end
  end
end
