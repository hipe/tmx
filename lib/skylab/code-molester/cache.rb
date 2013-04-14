module Skylab::CodeMolester

  module Cache

    define_singleton_method :pathname, &
      ( Headless::IO::Cache.build_cache_pathname_function_for self do
        abbrev 'cm'
      end )
  end
end
