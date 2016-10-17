require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] autoloader reflection" do

    TS_[ self ]
    use :memoizer_methods

    context "hi." do

      shared_subject :_the_module do

        module X_a_r_Booseefus

          Foo = 1

          define_singleton_method :_this_, Autoloader_::Boxxy_::Reflection::Each_const_value_method

          BAR = 2

          self
        end
      end

      it "ok" do

        v_a = []

        _the_module._this_ do |x|
          v_a.push x
        end

        v_a == [ 1, 2 ] || fail
      end
    end
  end
end
