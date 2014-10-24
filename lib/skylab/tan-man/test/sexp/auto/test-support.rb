require_relative '../test-support'

::Skylab::TestSupport::Quickie.enable_kernel_describe

module Skylab::TanMan::TestSupport::Sexp::Auto

  ::Skylab::TanMan::TestSupport::Sexp[ self ]

  module ModuleMethods

    def it_unparses_losslessly *tags
      it "unparses losslessly", *tags do
        result.unparse.should eql some_input_string
      end
    end

    def it_yields_the_stmts *items
      tags = ::Hash === items.last ? [items.pop] : [ ]
      it "yields the #{items.length} items", *tags do
        a = result.stmt_list.stmts
        a.length.should eql(items.length)
        a.each_with_index do |x, i|
          a[i].to_s.should eql(items[i])
        end
      end
    end
  end
end
