module Skylab::MetaHell::Autoloader::Autovivifying

  module Recursive
    def self.extended mod
      mod.extend Recursive::ModuleMethods
      mod._autoloader_init! caller[0]
    end
  end


  module Recursive::ModuleMethods
    include Autovivifying::ModuleMethods

    def case_insensitive_const_get const # experiment
      _const_missing(const)._case_insensitive_const_get
    end

    def _const_missing_class
      Recursive::ConstMissing
    end
  end


  class Recursive::ConstMissing < Autovivifying::ConstMissing

    def _case_insensitive_const_get
      const_normalized = const.to_s.downcase
      find_f = -> do
         mod.autoloader_original_constants.detect do |c|
          const_normalized == c.to_s.downcase
        end
      end
      found = find_f.call
      if ! found
        self.after_require_f = -> do
          found = find_f.call
          if found and found != const
            self.const = found        # correct ourself!
          end
        end
        load
      end                             # either use the const as it was corrected
      mod.const_get const, false      # above, or trigger error as normal
    end

  protected

    def load_file
      super
      o = mod.const_get const, false
      if ! o.respond_to? :autoloader_original_const_defined?
        o.extend module_methods_module   # "recursive" (infectious)
        o.dir_path = normalized
        o._autoloader_init! nil
      end
      nil
    end

    def module_methods_module
      Recursive::ModuleMethods
    end
  end
end
