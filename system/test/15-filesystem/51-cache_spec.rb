require_relative '../test-support'

module Skylab::System::TestSupport

  Tmpdir_controller_[].prepare_if_not_exist  # tests assume this, cleanup if not
  # Tmpdir_controller_[].UNLINK_FILES_RECURSIVELY_  # (undoes above, see what breaks), :#here

  describe "[sy] - services - filesystem - bridges - cache (manual)" do

    TS_[ self ]

    it "loads" do
      # #lends-coverage to [#fi-008.8]
      _subject_module
    end

    it "won't apply to a toplevel module #scary-test" do

      _rx = %r(\bcan't operate on toplevel module - #{ ::Skylab.name }\b)

      begin
        _subject_module[ ::Skylab ]
      rescue _subject_module::RuntimeError => e
      end

      e.message =~ _rx || fail
    end

    context "will apply to any non-top level module" do

      before :all do

        module X_f_c_Foo10
          Home_::Filesystem::Cache[ self ]
        end
      end

      it "the module now responds to `cache_path`" do
        X_f_c_Foo10.should be_respond_to :cache_path
      end

      it "but if you try to access this pn, it fails bc no parent complies #fragile-test" do

        # (this breaks if TS_ responds to the API method.)

        _rx = %r(\Anone of the \d+ parent module\(s\) responded to `cac)

        begin
          X_f_c_Foo10.cache_path
        rescue _subject_module::RuntimeError => e
        end

        e.message =~ _rx || fail
      end
    end

    context "`cache_path_proc_via_module` -" do

      before :all do

        module X_f_c_Foo20

          def self.cache_path
            Tmpdir_[]
          end

          module BarBaz
            _p = Home_.services.filesystem.cache.cache_path_proc_via_module self
            define_singleton_method :cache_path, _p
          end
        end
      end

      it "if parent directory not exist - raises #fragile: before next test" do

        tmp = Tmpdir_controller_[]
        if tmp.exist?
          tmp.UNLINK_FILES_RECURSIVELY_
        end

        _rx = %r(No such file or directory )

        begin
          X_f_c_Foo20::BarBaz.cache_path
        rescue ::Errno::ENOENT => e
        ensure
          tmp.prepare
        end

        e.message =~ _rx || fail
      end

      it "the nested client module builds its `cache_path` isomoprhically" do

        X_f_c_Foo20::BarBaz.cache_path.should eql ::File.join( Tmpdir_[], 'bar-baz' )
      end
    end

    context "(with `abbrev` filenames can't look weird)" do

      before :all do

        module X_f_c_Foo30

          def self.cache_path
            Tmpdir_[]
          end

          module Weezy_Deezy
            Home_::Filesystem::Cache[ self, :abbrev, "zoipey/../doipey" ]
          end
        end
      end

      it "raises lazily" do

        _rx = %r(\Afilename contains invalid characters - ['"]zoipey)

        begin
          X_f_c_Foo30::Weezy_Deezy.cache_path
        rescue _subject_module::RuntimeError => e
        end

        e.message =~ _rx || fail
      end
    end

    it "if you want a filename other than what is inferred, use `abbrev`" do

      module Foo2
        def self.cache_path
          Tmpdir_[]
        end
        Bar = ::Module.new
      end

      _p = Home_.services.filesystem.cache.cache_path_proc_via_module(
        Foo2::Bar,
        :abbrev, 'some-other-filename',
      )

      _p[].should eql ::File.join( Tmpdir_[], 'some-other-filename' )
    end

    context "- hopping modules" do

      before :all do

        module X_f_c_Foo3

          def self.cache_path
            Tmpdir_[]
          end

          module Bar
            module Baz
              _p = Home_.services.filesystem.cache.cache_path_proc_via_module self
              define_singleton_method :cache_path, _p
            end
          end
        end
      end

      it "the (locally) topmost module knows its associated path" do
        X_f_c_Foo3.cache_path.should eql Tmpdir_[]
      end

      it "but this intermediate module has no associated path" do
        X_f_c_Foo3::Bar.respond_to?( :cache_path ).should eql false
      end

      it "but yet this here, innermost module SKIPS OVER the intermediate step" do

        X_f_c_Foo3::Bar::Baz.cache_path.should eql ::File.join( Tmpdir_[], 'baz' )
      end
    end

    def _subject_module
      Home_::Filesystem::Cache
    end
  end
end
