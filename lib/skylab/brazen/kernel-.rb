module Skylab::Brazen

  class Kernel_

    def initialize mod
      @module = mod
    end

    def get_action_scanner
      mscn = get_model_scanner
      ascn = nil

      Brazen_::Entity.scan.new do
        while true
          if ! ascn
            mdl = mscn.gets
            mdl or break
            ascn = mdl.get_upper_action_scan
            ascn or next
          end
          x = ascn.gets
          x and break
          ascn = nil
        end
        x
      end
    end

  private

    def get_model_scanner
      mod = models_mod
      i_a = mod.constants
      d = -1 ; last = i_a.length - 1
      Callback_::Scn.new do
        if d < last
          mod.const_get i_a.fetch( d += 1 ), false
        end
      end
    end

    def models_mod
      @module.const_get :Models_, false
    end
  end
end
