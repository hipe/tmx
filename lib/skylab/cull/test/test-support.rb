require_relative '../core'
require_relative '../core'

::Skylab::Cull::Autoloader_.require_sidesystem :TestSupport

module Skylab::Cull::TestSupport

  ::Skylab::TestSupport::Regret[ TS_ = self ]

  module Constants
    Cull_ = ::Skylab::Cull
    Face = ::Skylab::Face
    TestSupport = ::Skylab::TestSupport
    PN_ = '(?:\./)?\.cullconfig'
  end

  include Constants

  Cull_ = Cull_

  Face::TestSupport::CLI::Client[ self ]

  LIB_ = Cull_._lib

  extend TestSupport::Quickie

  module Fixtures  # #stowaway
    module Directories
      Cull_::Autoloader_[ self ]
    end
    module Patches
      Cull_::Autoloader_[ self ]
    end
    Cull_::Autoloader_[ self ]
  end

  module ModuleMethods

    include Constants

    def client_class
      Cull_::CLI  # not actually!
    end

    def sandboxed_tmpdir
      TS_.sandboxed_tmpdir
    end
  end

  define_singleton_method :sandboxed_tmpdir, Cull_::Callback_.memoize[ -> do
    _path = LIB_.system_tmpdir_pathname.
      join 'cull-sandboxes/cull-sandbox'
    TestSupport.tmpdir.new :path, _path, :max_mkdirs, 2
      # we have to go deep to escape the 3 dir limit
  end ]

  module InstanceMethods

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def from_inside_empty_directory &blk
      _from_inside blk, nil, false
    end

    def from_inside_a_directory_with fixture_i, &blk
      _from_inside blk, nil, true, fixture_i
    end

    def from_inside_fixture_directory i, & p
      _from_inside p, TS_::Fixtures::Directories.dir_pathname.
        join( LIB_.name_slugulate i ), false
    end

    def _from_inside p, dir_pn, do_use_fixture, fixture_i=nil
      if dir_pn
        use_pn = dir_pn
      else
        use_pn = sandboxed_tmpdir
        if do_debug != use_pn.be_verbose
          use_pn = use_pn.with :be_verbose, do_debug
        end
        use_pn.prepare
        do_use_fixture and load_fixture_into_tmpdir fixture_i, use_pn
      end

      x = nil
      Cull_._lib.file_utils.cd "#{ use_pn }" do |_dir|
        x = p.call
      end
      x
    end

    def sandboxed_tmpdir
      self.class.sandboxed_tmpdir
    end

    def load_fixture_into_tmpdir fixture_i, tmpdir
      _patch = "#{ LIB_.name_slugulate fixture_i }.patch"
      _pn = TS_::Fixtures::Patches.dir_pathname.join _patch
      st = tmpdir.patch( _pn.read ).exitstatus
      if st.nonzero?
        fail "sanity - patch failed? (exited with status #{ st })"
      end
    end
  end
end
