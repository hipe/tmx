module Skylab::Brazen

  class Kernel_

    class << self

      def wrap_scanner s, & p
        Scanner_Wrapper__.new s, p
      end
    end

    def initialize mod, name_str
      @module = mod
      @name_string = name_str
    end

    def get_action_scanner
      mscn = get_model_scanner
      ascn = nil
      Callback_::Scn.new do
        while true
          if ! ascn
            mdl = mscn.gets
            mdl or break
            ascn = mdl.get_action_scanner
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

    class Scanner_Wrapper__
      def initialize scn,  p
        @scn = scn ; @p = p
      end
      def gets
        if x = @scn.gets
          @p[ x ]
        end
      end
    end
  end
end
