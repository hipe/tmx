module Skylab::MetaHell::Autoloader::Autovivifying

  module Recursive
    def self.extended mod
      mod.extend Recursive::ModuleMethods
      mod._autoloader_init caller[0]
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

    normalize = -> const do
      const.to_s.gsub('_', '').downcase
    end

    define_method :_case_insensitive_const_get do
      normalized = normalize[ self.const ]
      find = -> do
        mod.autoloader_original_constants.detect do |c|
          normalized == normalize[ c ]
        end
      end
      correct = -> const do
        if const and const != self.const
          self.const = const
        end
      end
      found = find.call           # in the existing consts, do i exist (fuzzy)?
      if found                    # if i am found, make my casing correct
        correct[ found ]
      else                        # else load the file, and repeat the same
        load -> { correct[ find.call ] } # thing again immediately after
      end                         # you load it, so that our check is ok.
      mod.const_get self.const, false
    end

  protected

    def load_file after=nil
      super
      o = mod.const_get const, false
      if ! o.respond_to? :autoloader_original_const_defined?
        if ::TypeError != (o.singleton_class rescue ::TypeError) # else final
          o.extend module_methods_module   # "recursive" (infectious)
          o.dir_path = normalized
          o._autoloader_init nil
        end
      elsif ! o.dir_path
        o.dir_path = normalized
      end
      nil
    end

    def module_methods_module
      Recursive::ModuleMethods
    end
  end
end
