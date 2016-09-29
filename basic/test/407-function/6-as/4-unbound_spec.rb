require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] function - as - unbound" do

    TS_[ self ]
    use :future_expect

    context "kernel integration - setup 1" do

      it "kernel builds" do
        _kernel
      end

      it "no such action" do

        future_expect_only :error, :no_such_action do | ev |
          ev.action_name.should eql :waz_tangle
        end

        _x = _kernel.call :waz_tangle, & fut_p

        future_is_now

        _x.should eql false
      end

      it "calls OK" do

        future_expect :ohai, :ohey do | ev |
          ev.should eql [ :Two, :One ]
        end

        _x = _kernel.call :some_func_one, :arg_a, :One, :arg_b, :Two, & fut_p

        future_is_now

        _x.should eql :wahoo
      end

      dangerous_memoize_ :_kernel do

        module FaA_KI_1

          module Models_  # the default source for unbound models

            Some_func_one = -> arg_a, arg_b, bound, & oes_p do

              oes_p.call :ohai, :ohey do
                [ arg_b, arg_a ]
              end

              :wahoo
            end

            Some_func_two = -> _  do
              self._NOT_USED
            end
          end
        end

        Home_.lib_.brazen::Kernel.new FaA_KI_1
      end
    end
  end
end
