require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Namespace::NIS

  ::Skylab::Face::TestSupport::CLI::Namespace[ NIS_TS = self ]

  CONSTANTS::Common_setup_[ self ]

  describe "[fa] CLI - namespace NIS (normalized invocation strings)" do

    extend NIS_TS

    context "some context" do
      with_body do
        namespace :'data-source' do
          def add x
            "sure:(#{ x })"
          end
        end
      end

      it "wins.", wip:true do
        r = invoke 'data-source', 'add', 'foo'
        r.should eql( 'sure:(foo)' )
        client.instance_variable_get( :@mechanics ).tap do
        end.normal_last_invocation_string.should eql(
          "wtvr data-source add" )
      end
    end
  end
end
