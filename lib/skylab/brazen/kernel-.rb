module Skylab::Brazen

  class Kernel_  # [#015]

    def initialize mod
      @module = mod
    end

    def retrieve_unbound_action_via_normalized_name i_a
      i_a.reduce self do |m, i|
        scn = m.get_unbound_action_scan
        while cls = scn.gets
          _i = cls.name_function.as_lowercase_with_underscores_symbol
          i == _i and break( found = cls )
        end
        found or raise ::KeyError, "not found: #{ i } in #{ m }"
      end
    end

    def get_action_scan
      get_unbound_action_scan.map_by do |cls|
        cls.new
      end
    end

    def get_unbound_action_scan
      get_model_scan.expand_by do |item|
        item.get_unbound_upper_action_scan
      end
    end

  private

    def get_model_scan
      mod = models_mod
      i_a = mod.constants
      i_a.sort!  # #note-35
      d = -1 ; last = i_a.length - 1
      Entity_[].scan do
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
