module Skylab::Brazen

  class Kernel_

    def initialize mod, name_str
      @module = mod
      @name_string = name_str
    end

    def get_action_scanner
      actions_mod = acts_module
      i_a = actions_mod.constants ; d = 0 ; len = i_a.length
      Scanner_.From_Block do
        if d < len
          i = i_a.fetch d ; d += 1
          actions_mod.const_get( i, false ).new self
        end
      end
    end

    def acts_module
      @acts_module ||= @module::Actions_
    end
  end
end
