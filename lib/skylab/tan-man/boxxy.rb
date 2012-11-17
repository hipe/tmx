module Skylab::TanMan
  module Boxxy end
  module Boxxy::Methods
    include MetaHell::Autoloader::Autovivifying::Recursive::ModuleMethods

    def self.extended mod
      mod._boxxy_init! caller[0]
    end

    def _boxxy_init! caller_str
      _autoloader_init! caller_str
    end

    def const_fetch path_a, &name_error
      names = ::Array === path_a ? path_a.dup : [path_a]
      names.reduce self do |mod, name|
        const = constantize name
        if ! (mod.autoloader_original_const_defined?(const, false) or
              mod.const_probably_loadable? const
        ) then
          name_error ||= -> _, _ do
            raise ::NameError.exception(
              "uninitialized constant #{mod}::#{const}")
          end
          return name_error[ mod, const ]
        end
        mod.case_insensitive_const_get const
      end
    end

    def const_fetch_all *a, &b
      a.map do |const_signifier|
        const_fetch const_signifier, &b
      end
    end
  end
end
