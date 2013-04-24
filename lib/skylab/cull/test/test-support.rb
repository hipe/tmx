require_relative '../core'
require 'skylab/face/test/cli/test-support'

module Skylab::Cull::TestSupport

  ::Skylab::TestSupport::Regret[ Cull_TestSupport = self ]

  ::Skylab::Face::TestSupport::CLI[ self ]

  module CONSTANTS
    Cull = ::Skylab::Cull
    TestSupport = ::Skylab::TestSupport
  end

  include CONSTANTS

  extend TestSupport::Quickie

  module ModuleMethods

    include CONSTANTS

    def client_class
      Cull::CLI  # not actually!
    end

    def tmpdir
      Cull_TestSupport.tmpdir
    end
  end

  -> do
    tmpdir = nil
    define_singleton_method :tmpdir do
      tmpdir ||= TestSupport::Tmpdir.new(
        path: ::Skylab.tmpdir_pathname.join( 'cull-sandboxes/cull-sandbox' ),
        max_mkdirs: 2  # we go deep
      )
    end
  end.call

  module InstanceMethods

    def from_inside_empty_directory &blk
      _from_inside blk, false
    end

    def from_inside_a_directory_with fixture_i, &blk
      _from_inside blk, true, fixture_i
    end

    def _from_inside blk, do_use_fixture, fixture_i=nil
      r = do_set_prev = nil ; tmpdir = self._tmpdir

      if do_debug
        do_set_prev = true
        prev = tmpdir.verbose
        tmpdir.debug!  # le meh
      end

      tmpdir.prepare

      do_use_fixture and _load_fixture fixture_i

      Headless::Services::FileUtils.cd "#{ tmpdir }" do |_dir|
        r = blk.call
      end

      if do_set_prev
        tmpdir.verbose = prev
      end

      r
    end

    def _tmpdir
      @_tmpdir ||= self.class.tmpdir
    end

    def _load_fixture fixture_i
      pn = Cull_TestSupport::Fixtures::Patches.
        dir_pathname.join "#{ Headless::Name::FUN.slugulate[ fixture_i ] }.patch"

      st = _tmpdir.patch( pn.read ).exitstatus
      st.zero? or fail "sanity - patch failed? (exited with status #{ st })"
      nil
    end
  end
end
