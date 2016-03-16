require_relative '../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] attributes - meta attributes" do

    TS_[ self ]
    use :memoizer_methods
    use :attributes

    context "(context)" do

      given_the_attributes_ do

        attributes_(
          awesome: :flag,
          do_ignore_case: :known_known,
          ignore_case: [ :flag_of, :do_ignore_case ],
          path: [ :singular_of, :paths ],
          paths: nil,
        )
      end

      it "nothing" do
        against_ :paths, :hi
        @paths.should eql :hi
      end

      it "known known" do
        against_ :do_ignore_case, :momma
        kn = @do_ignore_case
        kn.is_known_known or fail
        kn.value_x.should eql :momma
      end

      it "flag" do
        against_ :awesome
        @awesome or fail
      end

      it "flag of" do

        against_ :ignore_case
        kn = @do_ignore_case
        kn.is_known_known or fail
        kn.value_x or fail
      end

      it "singular of" do

        against_ :path, :xx
        @paths.should eql [ :xx ]
      end
    end

    context "(context 2)" do

      given_the_attributes_ do

        attributes_(
          ruby_regexp: :optional,
        )
      end

      it "setting it works" do
        against_ :ruby_regexp, :hi
        @ruby_regexp.should eql :hi
      end

      it "but when it is not set.." do
        against_
        instance_variable_defined?( :@ruby_regexp ).should eql true
        @ruby_regexp.should be_nil
      end
    end

    context "an unrecognized meta-attribute" do

      given_the_attributes_ do

        attributes_(
          zoozie: :floozie_poozie,
        )
      end

      it "does not fail at definition time" do
        the_attributes_
      end

      it "does fail (raises exception) at definition parsing time" do

        attrs = the_attributes_

        _rx = /\Ainvalid meta attribute 'floozie_poozie', expecting \{ #{
          }[a-z_]+(?: \| [a-z_]+){3,20} \}\z/

        begin
          attrs.index_
        rescue ::ArgumentError => e
        end

        e.message.should match _rx
      end
    end
  end
end
