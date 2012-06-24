require_relative '../../../../skylab'

describe Skylab::Autoloader::Inflection do
  include subject.call
  context "Pathify tries to turn constants into path fragments:" do
    let(:subject) { pathify const }
    def self.yerp const, tgt_path, comment, *a
      context "pathifying #{const.inspect} #{comment}", *a do
        let(:const) { const }
        specify { should eql(tgt_path) }
      end
    end
    yerp '', '', '(the empty case)'
    yerp "Foo", 'foo', "(the atomic case)"
    yerp "FooBar", 'foo-bar', '(two part single token camel case)'
    yerp "FB", 'fb', '(atomic adjacent upcase)'
    yerp "CSV::API", 'csv/api', '(this is why we do it this way)'
    yerp "HTTPRequest", "httprequest", "(however it could stand to be smarter)"
    yerp "Catch22Pickup", 'catch22pickup', '(numbers whatever this might change)'
    yerp "a::b", 'a/b', '(atomic separators case)'
    yerp "Foo::BarBaz:::Biff", 'foo/bar-baz/:biff', '(garbage in garbage out)'
  end
  context "Constantize tries to turn path fragments into constants" do
    let(:subject) { constantize path }
    def self.yerp path, tgt_const, comment, *a
      context "constantizing #{path.inspect} #{comment}", *a do
        let(:path) { path }
        specify { should eql(tgt_const) }
      end
    end
    yerp '', '', '(the empty case)'
    yerp 'a', 'A', '(atomic letter)'
    yerp 'SomePath/that-is/99times/fun', 'SomePath::ThatIs::99Times::Fun', '(might allow for some invalid const names)'
    yerp 'foo-bar/baz/.rb', 'FooBar::Baz::', '(will strip extension names of .rb only)'
    yerp 'yerp/hoopie-doopie.py', 'Yerp::HoopieDoopiepy', '(but only .rb)'
    yerp 'one/////two', 'One::Two', '(corrects multiple slashes)'
  end
end
