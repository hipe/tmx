require_relative '../core'

module Skylab::GitViz::TestSupport

  module Constants
    GitViz_ = ::Skylab::GitViz
    o = GitViz_::Lib_
    TestSupport_ = o::Test_support[]
    TS_ = GitViz_::TestSupport
  end

  include Constants

  extend TestSupport_::Quickie

  TestSupport_::Regret[ self ]

  GitViz_ = GitViz_ ; TS__ = self

  module ModuleMethods
    def use i
      const_i = GitViz_::Name_.via_variegated_symbol( i ).as_const
      mod = nearest_test_node
      while true
        if mod.const_defined? const_i, false
          found_mod = mod.const_get const_i
          break
        end
        mod_ = mod.parent_anchor_module
        if mod_
          mod = mod_
        else
          found_mod = GitViz_::Test_Lib_.const_get const_i, false
          break
        end
      end
      found_mod[ self ] ; nil
    end
  end

  module InstanceMethods

    def debug!
      @do_debug = true ; nil
    end
    attr_reader :do_debug
    def debug_IO
      GitViz_::Lib_::Some_stderr_IO[]
    end

    def listener
      @listener ||= build_listener
    end

    def build_listener
      GitViz_::Callback_::Selective_listener.spy_proxy do |spy|
        spy.emission_a = @baked_em_a = []
        spy.inspect_emission_proc =
          method :inspect_emission_channel_and_payload
        spy.do_debug_proc = -> { do_debug }
        spy.debug_IO = debug_IO
      end
    end

    def inspect_emission_channel_and_payload i_a, x
      "#{ i_a.inspect }: #{ GitViz_::Test_Lib_::Strange[ x ] }"
    end

    def baked_em_a  # #hook-out: 'expect'
      @baked_em_a ||= build_baked_em_a
    end
  end

  module Testable_Client  # read [#015] the testable client narrative intro.

    DSL = -> mod do
      mod.extend Test_Node_Module_Methods_ ; nil
    end

    module Test_Node_Module_Methods_
    private
      def testable_client_class i, & p
        p_ = -> do  # #storypoint-20
          r = p[] ; p_ = -> { r } ; r
        end
        instance_methods_module.module_exec do
          define_method i do
            p_[]
          end
        end ; nil
      end
    end
  end

  Autoloader_ = GitViz_::Autoloader_

  Autoloader_[ self, :boxxy,  GitViz_.dir_pathname.join( 'test' ) ]

  module Messages
    PATH_IS_FILE = "path is file, must have directory".freeze
  end

  module VCS_Adapters  # ~ stowaway
    module Git
      Autoloader_[ Fixtures = ::Module.new ]

      Autoloader_[ self ]
    end
    Autoloader_[ self ]
  end
end
