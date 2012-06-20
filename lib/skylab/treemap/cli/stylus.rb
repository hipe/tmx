module Skylab::Treemap

  class CLI::Stylus
    include Skylab::Porcelain::Bleeding::Styles
    def initialize
      @active = true
    end
    attr_reader :action_attributes
    attr_reader :active
    alias_method :and, :oxford_comma
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
    alias_method :orig_stylize, :stylize
    def option_syntax= os
      @option_syntax_options = nil
      @option_syntax = os
    end
    def option_syntax_options
      @option_syntax_options ||= begin
        unless @option_syntax.respond_to?(:options)
          @option_syntax.extend CLI::OptionSyntaxReflection
        end
        o = @option_syntax.options.dup # being careful
        o[:help] ||= CLI::OptionSyntaxReflection::OptionReflection.new(:help, 'help', 'h')
        o
      end
    end
    def or a
      oxford_comma(a, ' or ')
    end
    def param name, render_method=nil
      s =
      if option_syntax_options.key?(name)
        option_syntax_options[name].send( render_method || :long_name )
      elsif action_attributes.key?(name)
        action_attributes[name].label
      else
        name
      end
      pre s
    end
    def plain(s, *a)
      s
    end
    def wire! cli_action_meta, api_action_meta
      @action_attributes = api_action_meta.attributes
      self.option_syntax = cli_action_meta.option_syntax
      self
    end
  end
end

