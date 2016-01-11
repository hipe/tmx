require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] parameters - 02 meta parameters intro" do

    TS_[ self ]
    use :memoizer_methods

    context "(context)" do

      shared_subject :_params do

        _build_parameters(
          awesome: :flag,
          do_ignore_case: :known_known,
          ignore_case: [ :flag_of, :do_ignore_case ],
          path: [ :singular_of, :paths ],
          paths: nil,
        )
      end

      it "nothing" do
        _against :paths, :hi
        @paths.should eql :hi
      end

      it "known known" do
        _against :do_ignore_case, :momma
        kn = @do_ignore_case
        kn.is_known_known or fail
        kn.value_x.should eql :momma
      end

      it "flag" do

        _against :awesome
        @awesome or fail
      end

      it "flag of" do

        _against :ignore_case
        kn = @do_ignore_case
        kn.is_known_known or fail
        kn.value_x or fail
      end

      it "singular of" do

        _against :path, :xx
        @paths.should eql [ :xx ]
      end
    end

    context "(context 2)" do

      shared_subject :_params do

        _build_parameters(
          ruby_regexp: :optional,
        )
      end

      it "setting it works" do
        _against :ruby_regexp, :hi
        @ruby_regexp.should eql :hi
      end

      it "but when it is not set.." do
        _against
        instance_variable_defined?( :@ruby_regexp ).should eql true
        @ruby_regexp.should be_nil
      end
    end

    def _build_parameters h
      Home_::Parameters[ h ]
    end

    def _against * x_a
      _ = _params
      _x = _.init self, x_a  # EGAGS
      _x and fail
    end
  end
end
