module Skylab::Treemap
  class CLI::Stylus
    include Bleeding::Styles

    alias_method :treemap_original_stylize, :stylize

    def do_stylize= bool
      bool = !! bool              # normalizing it is necessary for the below
      if bool != @is_hot
        singleton_class.send :alias_method, :stylize,
          ( bool ? :treemap_original_stylize : :plain )
        @is_hot = bool
      end
      bool
    end

    def escape_path x
      if ::Pathname === x
        if x.absolute?
          x2 = x.relative_path_from ::Pathname.pwd
          if x2.to_s.length < x.to_s.length
            x = x2
          end
        end
      end
      "#{ x }"
    end

    def ick value                 # decorate an incorrect value
      pre value.inspect
    end

    alias_method :kbd, :pre

    def param x, render_method=nil             # generic rendering of params
      # [#011] this whole mess needs a design overhaul. what is the stylus
      # then, if it needs to have the cli and api actions inside of it!?
      ::Symbol === x or x = x.normalized_name
      str = nil
      if (( cli_option = @cli_action.options.fuzzy_fetch( x ) { } ))
        str = cli_option.send( render_method || :render )
      elsif (( attr = @api_action.formal_attributes.fetch( x ) { } ))
        str = attr.label_string
      else
        str = x.to_s
      end
      pre str
    end

    def plain s, *a
      s
    end

    def set_last_actions api_action, cli_action # [#011] unacceptable
      # [#011] this whole mess is unacceptable - used in `params`
      @api_action = api_action
      @cli_action = cli_action
      self
    end

    def val x                     # decorate a 'value'
      pre x.inspect
    end

  protected

    def initialize
      @is_hot = true              # a cli stylus that is not hot does not use
                                  # ascii escape sequences in its styling.
                                  # (#feature-point [#019])
    end
  end
end
