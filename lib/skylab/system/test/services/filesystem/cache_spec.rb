require_relative '../../test-support'

module Skylab::System::TestSupport

  module Svcs_FS_Cche___  # (modules are added to here during tests)

    subject_front = -> do
      Home_.services.filesystem.cache
    end

    Subject__ = -> *a do

      if a.length.zero?
        subject_front[]
      else
        _p = subject_front[].cache_pathname_proc_via_module( * a )
        a.first.define_singleton_method :cache_pathname, _p
        nil
      end
    end

    TMPDIR_PATH__ = ::Pathname.new ::File.join( TS_.tmpdir_path_, 'woo-wee' )

    # <-

  TS_.describe "[sy] - services - filesystem - cache (manual)" do

    extend TS_

    it "loads" do
      Subject__[]
    end

    it "won't apply to a toplevel module #scary-test" do
      _rx = %r(\bcan't operate on toplevel module - #{ ::Skylab.name }\b)
      -> do
        Subject__[ ::Skylab ]
      end.should raise_error ::ArgumentError, _rx
    end

    context "will apply to any non-top level module #fragile-test" do

      before :all do

        module Wiz_Waz
          Subject__[ self ]
        end
      end

      it "the module now responds to `cache_pathname`" do
        Wiz_Waz.should be_respond_to :cache_pathname
      end

      it "but if you try to access this pn, it fails bc no parent complies" do
        _rx = %r(\Anone of the \d+ parent module\(s\) responded to `cac)
        -> do
          Wiz_Waz.cache_pathname
        end.should raise_error _rx
      end
    end

    context "filenames can't look weird" do

      before :all do
        module Wiff_Waff
          def self.cache_pathname
            TMPDIR_PATH__
          end

          module Weezy_Deezy
            Subject__[ self, :abbrev, "zoipey/../doipey" ]
          end
        end
      end

      it "raises" do
        tmpdir_pn.prepare
        _rx = %r(\Afilename contains invalid characters - ['"]zoipey)
        -> do
          Wiff_Waff::Weezy_Deezy.cache_pathname
        end.should raise_error ::ArgumentError, _rx
      end
    end

    context "but then get busy when everything is right" do

      before :all do
        module Woo_Wee
          def self.cache_pathname
            TMPDIR_PATH__
          end

          module BarBaz
            Subject__[ self ]
          end
        end
      end

      it "if parent directory not exist - raises #fragile: before next test" do
        pn = tmpdir_pn
        if pn.exist?
          pn.UNLINK_FILES_RECURSIVELY_
        end
        _rx = %r(No such file or directory .+/woo-wee\z)
        -> do
          Woo_Wee::BarBaz.cache_pathname
        end.should raise_error ::Errno::ENOENT, _rx
      end

      it "if parent directory exists, ok have at it #after-above" do
        pn = tmpdir_pn
        pn.prepare
        pn_ = Woo_Wee::BarBaz.cache_pathname
        pn_.to_path.should match %r(\[sy\]/woo-wee/bar-baz\z)
        pn.should be_exist
      end
    end

    context "`abbrev` with good filename" do

      before :all do
        module Hiff_Heff
          def self.cache_pathname
            TMPDIR_PATH__
          end

          module Wip_Nizzle
            Subject__[ self, :abbrev, 'zee_dee-doo-789' ]
          end
        end
      end

      it "ok" do
        tmpdir_pn.prepare
        pn = Hiff_Heff::Wip_Nizzle.cache_pathname
        pn.to_path.match( %r([^/]{4}/[^/]+/[^/]+\z) )[ 0 ].
          should eql "[sy]/woo-wee/zee_dee-doo-789"
        pn.should be_exist
      end
    end

    def tmpdir_pathname_path
      TMPDIR_PATH__.to_path
    end

    def tmpdir_pn
      @tmpdir_pn ||= bld_tmpdir_pn
    end

    def bld_tmpdir_pn
      services_.filesystem.tmpdir(
        :path, tmpdir_pathname_path,
        :be_verbose, do_debug,
        :debug_IO, debug_IO,
        :max_mkdirs, 6 )  # make the `hl` dir if necessary
    end
  end
# ->
  end
end
