module Skylab::Face

  class API::Client

    # `API::Client` - experimental barebones impl.

    def build_action slug_str, param_h
      kls = api_actions_module.const_fetch slug_str
      kls.new self, param_h
    end
    public :build_action  # called e.g by another modality client

    Face::Services::ModuleAccessors.enhance self do

      private_methods do

        module_reader :api_actions_module, '../Actions' do
          extend MetaHell::Boxxy  # future i am sorry
        end

        module_reader :api_module, '..'

        module_reader :application_module, '../..'

      end
    end
  end
end
