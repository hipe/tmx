require_relative '../core'
require_relative '../core'

::Skylab::Cull::Autoloader_.require_sidesystem :TestSupport

module Skylab::Cull::TestSupport

  ::Skylab::TestSupport::Regret[ TS_ = self ]

  module Constants
    Cull = ::Skylab::Cull
    Face = ::Skylab::Face
    TestSupport = ::Skylab::TestSupport
    PN_ = '(?:\./)?\.cullconfig'
  end

  include Constants

  Cull = Cull

  Face::TestSupport::CLI::Client[ self ]

  Lib_ = Cull::Lib_

  extend TestSupport::Quickie

  module Fixtures  # #stowaway
    module Directories
      Cull::Autoloader_[ self ]
    end
    module Patches
      Cull::Autoloader_[ self ]
    end
    Cull::Autoloader_[ self ]
  end

  module ModuleMethods

    include Constants

    def client_class
      Cull::CLI  # not actually!
    end

    def sandboxed_tmpdir
      TS_.sandboxed_tmpdir
    end
  end

  define_singleton_method :sandboxed_tmpdir, Cull::Callback_.memoize[ -> do
    _path = Lib_::System_tmpdir_pathname[].
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
        join( Lib_::Name_slugulate[ i ] ), false
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
      Cull::Lib_::FileUtils[].cd "#{ use_pn }" do |_dir|
        x = p.call
      end
      x
    end

    def sandboxed_tmpdir
      self.class.sandboxed_tmpdir
    end

    def load_fixture_into_tmpdir fixture_i, tmpdir
      _patch = "#{ Lib_::Name_slugulate[ fixture_i ] }.patch"
      _pn = TS_::Fixtures::Patches.dir_pathname.join _patch
      st = tmpdir.patch( _pn.read ).exitstatus
      if st.nonzero?
        fail "sanity - patch failed? (exited with status #{ st })"
      end
    end
  end
end
