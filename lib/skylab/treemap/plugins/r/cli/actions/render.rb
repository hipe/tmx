module Skylab::Treemap

  class Plugins::R::CLI::Actions::Render < Plugins::R::CLI::Action
    # for the future, and used in validation of action names

    def load_attributes_into o                 # called by the api action
      o.attribute :the_rscript_is_the_payload, stop_at: :script_eventpoint,
        stop_is_induced: true, is_adapter_parameter: true
      nil
    end

    def load_options_into cli_action  # (was [#014])
      cli_action.option_parser do |o|
        o.separator ''
        o.separator "#{ hdr 'r-specific-options:' }"  # (was [#050])
        o.on '--r-script', 'output to stdout the generated r script, stop.' do
          @param_h[:the_rscript_is_the_payload] = true
        end
      end
    end
  end
end
