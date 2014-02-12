require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Client::Namespace::NIS

  ::Skylab::Face::TestSupport::CLI::Client::Namespace[ self, :CLI_party ]

  describe "[fa] CLI client namespace NIS (normalized invocation strings)" do

    extend TS__

    context "some context" do
      with_body do
        namespace :'data-source' do
          def add x
            "sure:(#{ x })"
          end
        end
      end

      it "wins." do
        r = invoke 'data-source', 'add', 'foo'
        r.should eql( 'sure:(foo)' )
        client.instance_variable_get( :@mechanics ).tap do
        end.normal_last_invocation_string.should eql(
          "wtvr data-source add" )
      end
    end
  end
end
