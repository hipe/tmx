module Skylab::Treemap

  class CLI::Stylus
    include Skylab::Porcelain::Bleeding::Styles
    def action_attributes
      @api_action.attributes
    end
    attr_reader :active
    def bad_value value
      pre value.inspect
    end
    def do_stylize= bool
      if @active != (b = !! bool)
        singleton_class.send(:alias_method, :stylize, b ? :orig_stylize : :plain)
        @active = b
      end
      bool
    end
    def initialize
      @active = true
    end
    alias_method :orig_stylize, :stylize
    def option_syntax_options
      @cli_action.option_syntax.options
    end
    def param name, render_method=nil
      s =
      if option_syntax_options.key?(name)
        option_syntax_options[name].send(render_method || :long_name)
      elsif action_attributes.key?(name)
        action_attributes[name].label
      else
        name.to_s
      end
      pre s
    end
    def plain(s, *a)
      s
    end
    def wire! cli_action, api_action
      @api_action = api_action
      @cli_action = cli_action
      self
    end
    def value value
      pre value.inspect
    end
  end
end

