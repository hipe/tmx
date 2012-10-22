require_relative '../test-support' # TMPDIR

module ::Skylab::TanMan::Sexp::Auto::TestSupport
  def self.extended mod
    mod.module_eval do
      extend ModuleMethods
      include InstanceMethods
      let :input_string do
        input_pathname.read
      end
    end
  end
  module ModuleMethods
    include ::Skylab::TanMan::Sexp::TestSupport::ModuleMethods
    def it_unparses_losslessly *tags
      it("unparses losslessly", *tags) do
        str_expected = input_pathname.read
        result = client.parse_file input_path
        str_actual = result.unparse
        str_actual.should eql(str_expected)
      end
    end
    def it_yields_the_stmts *items
      tags = ::Hash === items.last ? [items.pop] : [ ]
      it "yields the #{items.length} items", *tags do
        result = client.parse_file input_path
        a = result.stmt_list.stmts
        a.length.should eql(items.length)
        a.each_with_index do |x, i|
          a[i].to_s.should eql(items[i])
        end
      end
    end
  end
  module InstanceMethods
    include ::Skylab::TanMan::Sexp::TestSupport::InstanceMethods
    include ::Skylab::TanMan::Sexp::Inflection::InstanceMethods
  end
end
