require_relative '../core'
require_relative '../core'

::Skylab::Cull::Autoloader_.require_sidesystem :TestSupport

module Skylab::Cull::TestSupport

  ::Skylab::TestSupport::Regret[ Cull_TestSupport = self ]

  module CONSTANTS
    Cull = ::Skylab::Cull
    Face = ::Skylab::Face
    TestSupport = ::Skylab::TestSupport
    PN_ = '(?:\./)?\.cullconfig'
  end

  include CONSTANTS

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

    include CONSTANTS

    def client_class
      Cull::CLI  # not actually!
    end

    def sandboxed_tmpdir
      Cull_TestSupport.sandboxed_tmpdir
    end
  end

  define_singleton_method :sandboxed_tmpdir, Cull::Callback_.memoize[ -> do
    _path = Lib_::System_default_tmpdir_pathname[].
      join 'cull-sandboxes/cull-sandbox'
    TestSupport.tmpdir.new path: _path, max_mkdirs: 2
      # we have to go deep to escape the 3 dir limit
  end ]

  module InstanceMethods

    def from_inside_empty_directory &blk
      _from_inside blk, nil, false
    end

    def from_inside_a_directory_with fixture_i, &blk
      _from_inside blk, nil, true, fixture_i
    end

    def from_inside_fixture_directory i, &blk
      _from_inside blk, Cull_TestSupport::Fixtures::Directories.dir_pathname.
        join( Lib_::Name_slugulate[ i ] ), false
    end

    def _from_inside blk, dir_pn, do_use_fixture, fixture_i=nil
      if ! dir_pn
        tmpdir = sandboxed_tmpdir
        if do_debug
          do_set_prev = true
          prev = tmpdir.verbose
          tmpdir.debug!  # le meh
        end

        tmpdir.prepare

        do_use_fixture and _load_fixture fixture_i
      end

      r = nil
      Cull::Lib_::FileUtils[].cd "#{  dir_pn || tmpdir }" do |_dir|
        r = blk.call
      end

      if do_set_prev
        tmpdir.verbose = prev
      end
      r
    end

    def sandboxed_tmpdir
      self.class.sandboxed_tmpdir
    end

    def _load_fixture fixture_i
      _patch = "#{ Lib_::Name_slugulate[ fixture_i ] }.patch"
      pn = Cull_TestSupport::Fixtures::Patches.dir_pathname.join _patch
      st = sandboxed_tmpdir.patch( pn.read ).exitstatus
      st.zero? or fail "sanity - patch failed? (exited with status #{ st })"
      nil
    end
  end
end
