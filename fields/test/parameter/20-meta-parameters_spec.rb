require_relative '../test-support'

describe "[fi] P - meta-parameters", wip: true do

  extend Skylab::Fields::TestSupport
  use :parameter

  context "some built-in meta-meta-parameters can modify meta-parameters." do

    with do

      param :first_name

      meta_param :highly_sensitive, :boolean

      param :social_security_number, :highly_sensitive

      param :last_name
    end

    frame do

      it "a parameter that *was* modified with the meta-parameter says so" do

        _param = the_class_.parameters.fetch :social_security_number
        _param.highly_sensitive?.should eql true
      end

      it "a parameter that was not modified with the meta-parameter says so" do

        _param = the_class_.parameters.fetch :last_name
        _param.highly_sensitive?.should eql nil
      end

      it "but what of a parameter created before the meta-parameter existed?" do

        _param = the_class_.parameters.fetch :first_name
        _param.respond_to?( :highly_sensitive? ).should eql false
      end
    end
  end
end
