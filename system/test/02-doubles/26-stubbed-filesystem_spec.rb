require_relative '../test-support'

module Skylab::System::TestSupport

  describe "[sy] doubles - stubbed filesystem" do

    TS_[ self ]
    use :doubles_stubbed_filesystem

    it "loads" do
      subject_module_
    end

    it "client class can enhance by it (using `client`)" do

      _incomplete_client_class
    end

    it "client must implement this one hookout" do

      o = _incomplete_client_class.new

      _want_no_method :manifest_path_for_stubbed_FS do
        o.send :stubbed_filesystem
      end
    end

    it "client must implement this other hookout" do

      cls = ::Class.new
      subject_module_.enhance_client_class cls
      cls.send :define_method, :manifest_path_for_stubbed_FS do :_MPFSFS_ end

      o = cls.new
      _want_no_method :cache_hash_for_stubbed_FS do
        o.send :stubbed_filesystem
      end
    end

    it "the stubbed filesystem is memoized into the client" do

      mfs = _fs
      mfs or fail
      mfs.object_id == _fs.object_id or fail
    end

    it "`exist?` - that who exists in the manifest exists" do

      _fs.exist?( '/simple-absolut' ) or fail
    end

    it "`exist?` - that who does not does not" do

      _fs.exist?( 'does-not' ) and fail
    end

    it "`file?` - this minimal relative path just works (NO LEADING DOT)" do

      _fs.file? 'simple-relatif'
    end

    it "`file?` - this non-minimal relative path just works (NO LEADING DOT)" do

      _fs.file? 'compound/relatif'
    end

    it "`directory?` - if a node has children, it is a directory" do

      _want_is_directory '/compound'
    end

    it "`directory?` - also, if a node's entry ends in a '/' it is a dir" do

      _want_is_directory '/absolut/directory-hack/'
    end

    it "`directory?` - whether or not you use a trailing slash in arg path" do

      _want_is_directory '/absolut/directory-hack'
    end

    it "`directory?` - multiple trailing slashes !!??" do

      _want_is_directory 'relatif/directory-hack///'
    end

    it "`build_directory_object` when yes" do

      _x = _fs.build_directory_object '/compound'
      expect( _x.to_path ).to eql '/compound'
    end

    it "[same] when no ent" do

      begin
        _fs.build_directory_object '/no-such-path'
      rescue ::Errno::ENOENT => e
      end

      expect( e.message ).to eql(
        "No such file or directory @ MOCKED_dir_initialize - /no-such-path" )
    end

    it "[same] when not dir" do

      begin
        _fs.build_directory_object '/compound/absolut'
      rescue ::Errno::ENOTDIR => e
      end

      expect( e.message ).to eql(
        "Not a directory @ MOCKED_dir_initialize - /compound/absolut" )
    end

    def _want_is_directory path

      fs = _fs
      fs.directory?( path ) or fail
      fs.file?( path ) and fail
    end

    def _fs
      _good_client.send :stubbed_filesystem
    end

    def _want_no_method sym

      begin
        yield
      rescue ::NoMethodError => e
      end

      expect( e.name ).to eql sym
    end

    dangerous_memoize_ :_incomplete_client_class do

      cls = DSFS_01_Client_Class = ::Class.new

      subject_module_.enhance_client_class cls

      cls
    end

    dangerous_memoize_ :_good_client do
      _good_client_class.new
    end

    dangerous_memoize_ :_good_client_class do

      cls = DSFS_02_Client_Class = ::Class.new

      subject_module_.enhance_client_class cls

      h = {}
      cls.send :define_method, :cache_hash_for_stubbed_FS do
        h
      end

      path = at_ :COMMON_STUBBED_FS_MANIFEST_PATH_

      cls.send :define_method, :manifest_path_for_stubbed_FS do
        path
      end

      cls
    end
  end
end
