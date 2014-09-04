require_relative '../test-support'

module Skylab::TanMan::TestSupport::API::Actions

  ::Skylab::TanMan::TestSupport::API[ TS_ = self ] # #regret

  include CONSTANTS # for the spec itself

  module ModuleMethods
    def action_name action_name
      let :action_name do action_name end
    end
  end

  module InstanceMethods

    def api_invoke *param_h
      api_invoke_action action_name, *param_h
    end

    def api_invoke_from_tmpdir *param_h
      from_tmpdir do
        api_invoke(* param_h )
      end
    end

    def api_invoke_action action_name, *param_h
      @api_last_response = api.invoke action_name, *param_h
    end

    attr_reader :api_last_response # or the shorter `response` below

    def from_tmpdir &b
      TestLib_::File_utils[].cd prepared_tanman_tmpdir, & b
    end

    def lone_error regex
      r = api_last_response or fail 'sanity - where is api response?'
      r.success?.should eql( false )
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
