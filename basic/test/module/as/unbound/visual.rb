module Skylab::Basic::TestSupport_Visual

  class Module::As::Unbound

    def initialize i, o, e, argv
      @ioe_argv = [ i, o, e, argv ]
    end

    def receive_parent_ _bound_parent, _my_const,  _my_slug
      nil
    end

    def produce_executable_
      self
    end

    def execute

      i, sout, e, argv = remove_instance_variable :@ioe_argv

      require_relative '../../../test-support'

      o = ::Object.new
      sc = o.singleton_class

      _TS = ::Skylab::Basic::TestSupport

      _TS::Use_[ nil, :module_as_models_support, sc ]

      _kernel = o.kernel_one_

      _pn_s_a = [ 'fake', 'name' ]

      _CLI = ::Skylab::Brazen::CLI.new i, sout, e, _pn_s_a, :back_kernel, _kernel

      _x = _CLI.invoke argv

      e.puts "(exited with: #{ _x.inspect })"

      :_no_see_
    end
  end
end
