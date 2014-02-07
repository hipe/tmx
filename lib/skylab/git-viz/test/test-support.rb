require_relative '../core'

module Skylab::GitViz::TestSupport

  module CONSTANTS
    GitViz = ::Skylab::GitViz
    o = GitViz::Lib_
    TestSupport = o::TestSupport[]
    TS_ = GitViz::TestSupport
  end

  include CONSTANTS

  extend TestSupport::Quickie

  GitViz = GitViz ; TS__ = self

  TestSupport::Regret[ self ]

  module ModuleMethods
    def use i
      const_i = GitViz::Name_.from_variegated_symbol( i ).as_const
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
          found_mod = GitViz::Test_Lib_.const_get const_i, false
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
      GitViz::Lib_::Some_stderr_IO[]
    end

    def listener
      @listener ||= build_listener
    end

    def build_listener
      GitViz::Callback_::Listener::Spy_Proxy.new do |spy|
        spy.emission_a = @baked_em_a = []
        spy.inspect_emission_proc =
          method :inspect_emission_channel_and_payload
        spy.do_debug_proc = -> { do_debug }
        spy.debug_IO = debug_IO
      end
    end

    def inspect_emission_channel_and_payload i_a, x
      "#{ i_a.inspect }: #{ GitViz::Test_Lib_::Inspect[ x ] }"
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

  module Messages
    PATH_IS_FILE = "path is file, must have directory".freeze
  end

  _pn = GitViz.dir_pathname.join 'test'
  GitViz::Autoloader_[ self, :boxxy, _pn ]

end
