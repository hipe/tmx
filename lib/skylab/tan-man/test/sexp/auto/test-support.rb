require_relative '../test-support' # TMPDIR

module ::Skylab::TanMan::Sexp::Auto::TestSupport
  def self.extended mod
    mod.module_eval do
      extend ModuleMethods
      include InstanceMethods
    end
  end
  module ModuleMethods
    def it_should_unparse_losslessly *tags
      it("should unparse losslessly", *tags) do
        _result = client.parse_file input_path
        _str_a = input_pathname.read
        _str_b = _result.unparse
        _str_a.should eql(_str_b)
      end
    end
    def using_input input_pathpart, *tags, &b
      context("using input #{input_pathpart}", *tags) do
        let(:input_pathpart) { input_pathpart }
        instance_eval(&b)
      end
    end
    def using_grammar grammar_pathpart, *tags, &b
      context("using grammar #{grammar_pathpart}", *tags) do
        grammars = ::Skylab::TanMan::Sexp::TestSupport::Grammars
        pn = grammars.dir_pathname.join(grammar_pathpart)
        let(:input_pathname) { pn.join("fixtures/#{input_pathpart}") }
        let(:client) do
          const = "Grammar#{grammar_pathpart}".intern
          grammars.constants.include?(const) or
            load pn.join('client').to_s
          grammars.const_get(const).new(nil, $stdin, $stderr)
        end
        instance_eval(&b)
      end
    end
  end
  module InstanceMethods
    include ::Skylab::TanMan::Sexp::Inflection::InstanceMethods
    def input_path ; input_pathname.to_s end
  end
end
