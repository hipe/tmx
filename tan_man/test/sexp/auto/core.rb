module Skylab::TanMan::TestSupport

  module Sexp::Auto

    def self.[] tcc

      Sexp[ tcc ]
      tcc.extend Module_Methods___
      tcc.include Instance_Methods___
    end

    module Module_Methods___

      def it_unparses_losslessly *tags
        it SAME___, *tags do
          unparse_losslessly
        end
      end

      SAME___ = "unparses losslessly"

      def it_yields_the_stmts *items

        tags = if items.last.respond_to? :each_pair
          [ items.pop ]
        end

        it "yields the #{ items.length } items", *tags do

          a = result.stmt_list.stmts

          a.length.should eql items.length

          a.each_with_index do | x, d |
            a.fetch( d ).to_s.should eql items.fetch( d )
          end
        end
      end
    end

    module Instance_Methods___

      def assemble_fixtures_path_

        _tail = "sexp/grammars/#{ grammar_pathpart_ }/fixtures"

        ::File.join TS_.dir_path, _tail
      end
    end
  end
end
