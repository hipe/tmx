module Skylab::MetaHell
  # apologies to rspec : it has many great things with let() being the greatest

  module Let
    # minimal memoizer.
    def self.extended mod
      mod.extend Let::ModuleMethods
      mod.send :include, InstanceMethods
    end
  end

  module Let::ModuleMethods
    def let name, &initial_f
      define_method name do
        __memoized.fetch name do |k|
          __memoized[k] = instance_exec &initial_f
        end
      end
    end
  end

  module Let::InstanceMethods
    def __memoized
      @__memoized ||= { }
    end
  end
end
