module Skylab::TanMan::TestSupport

  module Sexp

    def self.[] tcc
      tcc.extend Module_Methods___
      tcc.include Instance_Methods___
      tcc.include self
    end

    module Prototype
      def self.[] tcc
        Sexp[ tcc ]
        tcc.send :define_method, :assemble_fixtures_path_, ASSEMBLE_FIXTURES_PATH_METHOD_DEFINITION_
      end
    end

    ASSEMBLE_FIXTURES_PATH_METHOD_DEFINITION_ = -> do
      _head = TS_::Sexp::Grammars.dir_path
      _mid = grammar_pathpart_
      ::File.join _head, _mid, FIXTURES_ENTRY_
    end

    module Module_Methods___

      def using_grammar _GRAMMAR_NUMBERISH_ , *tags, & p

        context "using grammar #{ _GRAMMAR_NUMBERISH_ }", *tags do

          define_method :grammar_pathpart_ do
            _GRAMMAR_NUMBERISH_
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
      _path = ::File.join TS_.dir_path, 'fixture-grammars'
      Autoloader_[ self, _path ]
    end

    class Grammar

    end

    Here_ = self
  end
end
# #tombstone: "grammar" node (base class for test grammars)
