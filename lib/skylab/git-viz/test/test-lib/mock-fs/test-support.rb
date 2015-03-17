require_relative '../test-support'

module Skylab::GitViz::TestSupport::Test_Lib::Mock_FS

  ::Skylab::GitViz::TestSupport::Test_Lib[ TS_ = self ]

  include Constants

  Mock_FS_Parent_Module__ = GitViz_::Test_Lib_

  extend TestSupport_::Quickie

  GitViz_::Autoloader_[ Fixtures = ::Module.new ]

  module ModuleMethods
    def memoize i, &p  # this is used for OCD reasons, but can be problematic
      p_ = -> ctx do
        r = ctx.instance_exec( & p ) ; p_ = -> _ { r } ; r
      end
      define_method i do
        p_[ self ]
      end
    end
  end

  module InstanceMethods
    def test_context
      @test_context ||= build_test_context
    end
    def build_test_context
      test_context_class.new
    end
    def expect_absolute
      @pn.should be_absolute
      @pn.relative?.should eql false
    end
    def expect_relative
      @pn.should be_relative
      @pn.absolute?.should eql false
    end
    def fugue path_s, & exp_p
      pn = build_pathname_from_string path_s
      pn_ = ::Pathname.new path_s
      r = exp_p[ pn ] ; r_ = exp_p[ pn_ ]
      "#{ r }".should eql "#{ r_ }"
    end
    def build_pathname_from_string path_s
      Mock_FS_Parent_Module__::Mock_FS::Pathname__.
        new path_s, Mock_mock_FS__
    end
  end

  Mock_mock_FS__ = -> do
    p = -> do
      r = class Mock_Mock_FS__
        def initialize
          @self_ref = -> { self }
          @h = ::Hash.new do |h, k|
            h[ k ] = Mock_FS_Parent_Module__::Mock_FS::Pathname__.
              new k, @self_ref
          end ; nil
        end
        def touch_pn x
          @h[ x ]
        end
        self
      end.new ; p = -> { r } ; r
    end ; -> { p[] }
  end.call

  BUILD_CACHE_METHOD_ = -> do
    h = {}
    -> do
      h
    end
  end

  COMMON_MOCK_FS_MANIFEST_PATH_ =
    TS_.dir_pathname.join( 'fixtures/paths.manifest' ).to_path
end
