require_relative 'ivars-with-procs-as-methods/test-support'

module Skylab::MetaHell::TestSupport::Ivars_with_Procs_as_Methods

  describe "[mh] ivars with procs as methods (manual regression)" do

    it "normative - ok" do

      Manual_Foo = Subject_[].new :wiznippple do

        def initialize
          d = 0
          @wiznippple = -> { d += 1 }
        end
      end

      foo = Manual_Foo.new
      foo.wiznippple.should eql 1
      foo.wiznippple.should eql 2
    end
  end
end
