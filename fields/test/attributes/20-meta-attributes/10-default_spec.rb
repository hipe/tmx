require_relative '../../test-support'

module Skylab::Fields::TestSupport

  if false
  context 'and "foo" either does or doesn\'t have "default: \'anything\'"' do

    let :foo do
      the_class_.parameters.fetch :foo
    end

    context 'if you gave "foo" the property "default: :wazoo"' do

      with do
        param :foo, :default, :wazoo
      end

      frame do

        it '"foo.has_default?" is true' do
          foo.has_default?.should eql(true)
        end

        it '"foo.default_value" is :wazoo' do
          foo.default_value.should eql(:wazoo)
        end
      end
    end

    context "if you did not give it any default assignment" do

      with do
        param :foo
      end

      frame do

        it '"foo.has_default?" is false-ish' do
          foo.has_default?.should be_nil
        end

        it '"foo.default_value" raises a NoMethodError' do

          foo = send :foo
          foo.instance_variable_defined? :@_default_proc and fail  # avoid warning
          foo.instance_variable_set :@_default_proc, nil

          -> { foo.default_value }.should raise_error(::NoMethodError)
        end
      end
    end

    context "if you give it a false-ish (nil or false) default value" do

      with do
        param :foo, :default, nil
      end

      frame do

        it '"foo.has_default?" is true' do
          foo.has_default?.should eql(true)
        end

        it '"foo.default_value" is accurate' do
          foo.default_value.should be_nil
        end
      end
    end
  end
  end
end
