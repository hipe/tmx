module Skylab::TanMan::TestSupport

  module Sexp::Auto

    def self.[] tcc

      Sexp[ tcc ]
      tcc.extend Module_Methods___
      tcc.send :define_method, :assemble_fixtures_path_, Sexp::ASSEMBLE_FIXTURES_PATH_METHOD_DEFINITION_
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
  end
end
