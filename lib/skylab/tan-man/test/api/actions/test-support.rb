require_relative '../test-support'

module Skylab::TanMan::TestSupport::API::Actions
  ::Skylab::TanMan::TestSupport::API[ Actions_TestSupport = self ] # #regret

  include CONSTANTS # for the spec itself

  module ModuleMethods
    def action_name action_name
      let :action_name do action_name end
    end
  end

  module InstanceMethods

    def api_invoke *params_h
      api_invoke_action action_name, *params_h
    end

    def api_invoke_from_tmpdir *params_h
      from_tmpdir do
        api_invoke(* params_h )
      end
    end

    def api_invoke_action action_name, *params_h
      @api_last_response = api.invoke action_name, *params_h
    end

    attr_reader :api_last_response # or the shorter `response` below

    def from_tmpdir &b
      TanMan::TestSupport::Services::FileUtils.cd( prepared_tanman_tmpdir, & b )
    end

    def lone_error regex
      r = api_last_response or fail 'sanity - where is api response?'
      r.should_not be_success
      r.events.length.should eql(1)
      r.events.first.message.should match(regex)
    end

    def lone_success regex
      r = api_last_response or fail 'sanity - where is api response?'
      r.should be_success
      r.events.length.should eql(1)
      r.events.first.message.should match(regex)
    end

    def response # careful!
      api_last_response
    end
  end
end

defined? ::RSpec and require_relative 'for-rspec'
