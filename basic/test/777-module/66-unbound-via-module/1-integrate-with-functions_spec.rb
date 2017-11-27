require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] module - as - unbound: kernel integration (assumed func)" do

    TS_[ self ]
    use :future_expect
    use :module_as_unbound

    context "kernel integration - setup 1" do

      it "kernel builds" do
        kernel_one_
      end

      it "level 1 - call a toplevel function (integration)" do

        future_expect_only :info, :expression, :wazoozie

        _x = kernel_one_.call :node_four_which_is_function,
          :arg1, :xx, & fut_p

        future_is_now

        expect( _x ).to eql "(4 says: pong: xx)"
      end

      it "level 2 - call a function one level down" do

        future_expect_only :hi_from_5

        _x = kernel_one_.call :node_one_which_is_module,
          :node_5_func, :arg1, :zeep, & fut_p

        future_is_now

        expect( _x ).to eql "(5 says: pong: zeep)"
      end

      it "level 3 - modules within modules" do

        future_expect_only :hi_from_7

        _x = kernel_one_.call :node_two_which_is_class,
          :node_6_mod, :node_7_func, :arg1, :wizzie, & fut_p

        future_is_now

        expect( _x ).to eql "(7 says: pong: wizzie)"
      end
    end
  end
end
