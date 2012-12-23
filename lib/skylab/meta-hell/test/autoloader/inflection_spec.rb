require_relative '../../../../skylab'

describe Skylab::Autoloader::Inflection do
  include ::Skylab::Autoloader::Inflection::Methods


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
    yerp "CSV::API", 'csv/api', '(this is what acronyms look like)'
    yerp "HTTPAuth", "http-auth", '(but wait, look at this, magic! TLA at beginning)'
    yerp 'topSecretNSA', 'top-secret-nsa', '(TLA at end)'
    yerp 'WillIAm', 'will-i-am', '(ok, really guys?)'
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
    yerp 'SomePath/that-is/99times/fun', 'SomePath::ThatIs::99Times::Fun',
      '(might allow for some invalid const names)'
    yerp 'underscores_too', 'UnderscoresToo', '(handles underscores too?)'
    yerp 'foo-bar/baz/.rb', 'FooBar::Baz::', '(will strip extension names of .rb only)'
    yerp 'yerp/hoopie-doopie.py', 'Yerp::HoopieDoopiepy', '(but only .rb)'
    yerp 'one/////two', 'One::Two', '(corrects multiple slashes)'
    yerp 'path Here This::Is::This', 'PathHereThisIsThis', '(but what about this BS)'
  end


  context "Constantize tries to turn method-looking symbols into constants" do

    def self.o in_str, out_str, comment, *tags
      it "#{ comment } - #{ in_str.inspect } becomes #{
        } #{ out_str.inspect }", *tags do
        o = constantize in_str
        o.should eql( out_str )
      end
    end

    o :cs_style, "CsStyle", 'normal nerk with underscore'
    o :c_style, "C_Style", 'tricky nerk with only one letter nerk'
  end
end



describe "#{ ::Skylab::Autoloader::Inflection }::FUN methodize" do

  o = -> in_s, out_s, *t do
    it "#{in_s} #{out_s}", *t do
      ::Skylab::Autoloader::Inflection::FUN.methodize[ in_s ].should eql(out_s)
    end
  end

  o[ 'a b', :a_b ]

  o[ 'AbcDef', :abc_def ]

  o[ 'NASASpaceStation', :nasa_space_station ]

  o[ 'abc-def--hij', :abc_def_hij ]

  o[ 'F!@#$%^&*Oo', :f_oo ]

end
