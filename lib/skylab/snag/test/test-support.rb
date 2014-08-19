require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Snag::TestSupport

  ::Skylab::TestSupport::Regret[ self ]

  Snag_ = ::Skylab::Snag
  TestLib_ = ::Module.new
  TestSupport_ = ::Skylab::TestSupport

  module CONSTANTS
    Snag_ = Snag_
    TestSupport_ = TestSupport_
    TestLib_ = TestLib_
  end

  include CONSTANTS # in the body of child modules

  module TestLib_
    sidesys = Snag_::Autoloader_.build_require_sidesystem_proc
    Headless__ = sidesys[ :Headless ]
    Memoize = -> p do
      MetaHell__[]::FUN.memoize[ p ]
    end
    MetaHell__ = sidesys[ :MetaHell ]
    Tmpdir_pathname = -> do
      Headless__[]::System.defaults.tmpdir_pathname
    end
  end

  module InstanceMethods

    include CONSTANTS

    def debug!
      tmpdir.debug!
      @do_debug = true
    end

    attr_accessor :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    def from_tmpdir & p
      Snag_::Library_::FileUtils.cd tmpdir, verbose: do_debug, & p
    end

    -> x do
      define_method :tmpdir do x end
    end[ TestSupport_::Tmpdir.new TestLib_::Tmpdir_pathname[].join 'snaggle' ]

    -> x do
      define_method :manifest_file do x end
    end[ Snag_::API.manifest_file ]

  end

  # ~ business

  module InstanceMethods
    def with_API_max_num_dirs d
      Skylab::Snag::API::Client.setup -> o do
        o.max_num_dirs_to_search_for_manifest_file = d  # #open [#050]
      end ; nil
    end
  end

  # ~ tmpdir setup writing & reading

  module ModuleMethods

    def with_manifest s
      with_tmpdir do |o|
        pn = o.clear.write manifest_file, s
        memoize_last_pn pn
        @pn = pn ; nil
      end ; nil
    end

    def with_tmpdir_patch & p
      with_tmpdir do |o|
        _patch_s = instance_exec( & p )
        o.clear.patch _patch_s ; nil
      end
    end

    def with_tmpdir &p

      define_method :has_tmpdir do true end

      -> x do
        define_method :tmpdir_setup_identifier do x end
      end[ Produce_tmpdir_setup_identifier__[] ]

      define_method :__execute_the_tmpdir_setup__ do
        _td = tmpdir
        instance_exec _td, & p
        nil
      end ; nil
    end
  end

  Produce_tmpdir_setup_identifier__ = -> do
    d = 0 ; -> { d += 1 }
  end.call

  module InstanceMethods

    def setup_tmpdir_if_necessary
      is_setup_as = MUTEX__.setup_identifier
      if is_setup_as && is_setup_as == tmpdir_setup_identifier
        @pn = MUTEX__.pn
        if ! this_instance_wants_read_only  # taint setup so next one renews it
          MUTEX__.setup_identifier = nil
        end
      else
        do_setup_tmpdir
      end ; nil
    end

    def setup_tmpdir_read_only
      @this_instance_wants_read_only = true
      did_setup_tmpdir_read_only or do_setup_tmpdir_read_only ; nil
    end

    attr_reader :this_instance_wants_read_only

    def do_not_setup_tmpdir  # big hack
      MUTEX__.setup_identifier = tmpdir_setup_identifier
      @this_instance_wants_read_only = false ; nil
    end

    def did_setup_tmpdir_read_only
      tmpdir_setup_identifier == MUTEX__.setup_identifier
    end

    def do_setup_tmpdir_read_only
      MUTEX__.setup_identifier = tmpdir_setup_identifier
      do_setup_tmpdir ; nil
    end

    def memoize_last_pn pn
      MUTEX__.pn = pn
    end

    Mutex__ = ::Struct.new :setup_identifier, :pn
    MUTEX__ = Mutex__.new

    def do_setup_tmpdir
      __execute_the_tmpdir_setup__ ; nil
    end
  end
end
