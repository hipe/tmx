module Skylab::TanMan::TestSupport

  module Sexp

    def self.[] tcc
      tcc.extend Module_Methods___
      tcc.include Instance_Methods___
      tcc.include self
    end

    module Module_Methods___

      def using_grammar _GRAMMAR_PATHPART_ , *tags, & p

        context "using grammar #{ _GRAMMAR_PATHPART_ }", *tags do

          define_method :grammar_pathpart_ do
            _GRAMMAR_PATHPART_
          end

          dangerous_memoize :fixtures_path_ do

            assemble_fixtures_path_
          end

          module_exec( & p )
        end
      end
    end

    module Instance_Methods___

      def fixtures_path_
        self._SOMETHING
      end

      def node_s_a
        @result.nodes
      end

      def grammars_module_
        Here_::Grammars
      end
    end

    module Grammars
      Autoloader_[ self ]
    end

    class Grammar

    end

    Here_ = self
  end
end
