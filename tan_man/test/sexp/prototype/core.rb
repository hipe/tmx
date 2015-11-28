module Skylab::TanMan::TestSupport

  module Sexp::Prototype

    def self.[] tcc
      Sexp[ tcc ]
      tcc.include Instance_Methods___
    end

    module Instance_Methods___

      def assemble_fixtures_path_

        _tail = "sexp/prototype/grammars/#{ grammar_pathpart_ }/fixtures"

        ::File.join TS_.dir_pathname.to_path, _tail
      end

      def grammars_module_
        Grammars
      end
    end

    module Grammars
      Home_::Autoloader_[ self ]
    end
  end
end
