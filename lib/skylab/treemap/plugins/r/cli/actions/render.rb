module Skylab::Treemap

  class Plugins::R::CLI::Actions::Render < Plugins::R::CLI::Action
    # for the future, and used in validation of action names

    def load_attributes_into o                 # called by the api action
      o.attribute :the_rscript_is_the_payload, stop_at: :script_eventpoint,
        stop_is_induced: true, is_adapter_parameter: true
      nil
    end

    def load_options_into cli_action           # [#014.4] k.i.w.f
      cli_action.option_syntax.define! do |o|  # #todo near [#014] rename to add_definition
        s = cli_action.send :stylus  # [#050] - - stylus wiring is bad and wrong - this will be fixed when `self` is fixed
        separator ''
        separator s.hdr 'r-specific options:'
        on '--r-script', 'output to stdout the generated r script, stop.' do
          o[:the_rscript_is_the_payload] = true
        end
      end
      nil
    end
  end
end
