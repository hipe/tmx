require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Snag::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self ]

  extend TestSupport_::Quickie

  module ModuleMethods

    def use sym, * x_a

      if x_a.length.nonzero?
        rest = [ x_a ]
      end

      TS_.const_get(
        Callback_::Name.via_variegated_symbol( sym ).as_const, false
      )[ self, * rest ]

      NIL_
    end

    def with_invocation * i_a
    end

    def with_manifest s
    end

    def with_tmpdir_patch
    end

    def with_tmpdir
    end
  end

  module InstanceMethods

    def tmpdir
      @tmpdir ||= Memoize_.call :tmpdir do
        __build_tmpdir
      end
    end

    def __build_tmpdir

      TestSupport_.tmpdir.new(
        :path, Snag_.lib_.system.filesystem.tmpdir_pathname.
          join( 'snaggle' ).to_path,
        :be_verbose, do_debug,
        :debug_IO, debug_IO )
    end

    # ~ support & officious

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    def subject_API  # #hook-out for expect event
      Snag_::API
    end

    def black_and_white_expression_agent_for_expect_event  # ditto
      Snag_.lib_.brazen::API.expression_agent_instance
    end
  end

  Expect_My_CLI = -> do

    p = -> tcm do

      require TS_.dir_pathname.join( 'modality-integrations/expect-cli' ).to_path

      p = TS_::Expect_CLI.new_with(
        :subject_CLI, -> { Snag_::CLI },
        :program_name, 'sn0g',
        :generic_error_exitstatus,
          -> { Snag_.lib_.brazen::CLI::GENERIC_ERROR_ } )

      p[ tcm ]
    end

    -> tcm do
      p[ tcm ]
    end
  end.call

  Expect_Event = -> tcm, x_a=nil do
    Callback_.test_support::Expect_Event[ tcm, x_a ]
  end

  Expect_Stdout_Stderr = -> tcm do

    tcm.include TestSupport_::Expect_Stdout_Stderr::Test_Context_Instance_Methods
    tcm.send :define_method, :expect, tcm.instance_method( :expect )  # :+#this-rspec-annoyance
    NIL_
  end

  Fixture_files_ = -> do
    p = -> sym do
      h = {}

      _path = TS_.dir_pathname.join( 'fixture-files' ).to_path

      rx = /[-\.]/

      ::Dir.glob( "#{ _path }/[^.]*" ).each do | path |
        h[ ::File.basename( path ).gsub( rx, UNDERSCORE_ ).intern ] = path
      end

      p = h.method :fetch
      p[ sym ]
    end
    -> sym do
      p[ sym ]
    end
  end.call

  Fixture_trees_ = -> do
    h = {}
    -> sym do
      h.fetch sym do
        h[ sym ] = TS_.dir_pathname.join(
          'fixture-trees',
          Callback_::Name.via_variegated_symbol( sym ).as_slug
        ).to_path
      end
    end
  end.call

  Snag_ = ::Skylab::Snag

  Callback_ = Snag_::Callback_

  NIL_ = nil

  UNDERSCORE_ = '_'

end
