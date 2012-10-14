require_relative '../test-support' # TMPDIR

module ::Skylab::TanMan::Sexp::Auto::TestSupport
  def self.extended mod
    mod.module_eval do
      extend ModuleMethods
      include InstanceMethods
      let :input_string do
        input_pathname.read
      end
      let :result do
        client.parse_file input_path
      end
    end
  end
  module ModuleMethods
    include ::Skylab::Autoloader::Inflection::Methods
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
    def using_input input_path_stem, *tags, &b
      context("using input #{input_path_stem}", *tags) do
        let(:input_path_stem) { input_path_stem }
        let(:input_string) { input_pathname.read }
        instance_eval(&b)
      end
    end
    PATHPART_RX = /\A(?<num>\d+(?:-\d+)*)(?:-(?<rest>.+))?\z/
    def using_grammar grammar_pathpart, *tags, &b
      context("using grammar #{grammar_pathpart}", *tags) do
        grammars = ::Skylab::TanMan::Sexp::TestSupport::Grammars
        pn = grammars.dir_pathname.join grammar_pathpart
        let(:input_pathname) { pn.join("fixtures/#{input_path_stem}") }
        let(:client) do
          # hack to allow more complext names like "60-content-pattern"
          md = PATHPART_RX.match(grammar_pathpart)
          const = ["Grammar#{md[:num].gsub('-', '_')}",
            ("_#{ constantize md[:rest] }" if md[:rest]) ].join('').intern
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
