require_relative '../../../skylab'

describe Skylab::Autoloader do
  def cleanpath path
    path.sub(/\.rb$/, '')
  end
  context "infers a path based on simple heuristics." do
    let(:subject) { Skylab::Autoloader.guess_dir(const, path) { |e| fail(e) } }
    def self.with path, const, dir, comment, *a
      describe("The dirpath for #{const} calling from #{path} #{comment}", *a) do
        let(:path) { cleanpath path }
        let(:const) { const }
        it { should eql(dir) }
      end
    end
    with "tan-man/models/config.rb", "TanMan::Models::Config", "tan-man/models/config", "(same folder)"
    with "treemap/r/client.rb", "Treemap::R", "treemap/r", "(peek one level up)"
    with "tm/cli.rb", "TM::CLI::Actions", "tm/cli/actions", "(infer one level down)"
    with "sl/issue/api.rb", "SL::Issue::Models", "sl/issue/models", "(one up and one down)"
    with 'sl/test-support/test-support.rb', 'SL::TestSupport', 'sl/test-support', "(double deuce)"
    with 'foo', 'Foo', 'foo', '(shallow path)'
  end
  context "may fail" do
    let(:subject) do
      -> {  Skylab::Autoloader.guess_dir(const, path) { |e| fail(e) } }
    end
    def self.bunk path, const, failmsg, *a
      describe("The msg of the exception thrown for #{const} from #{path}", *a) do
        let(:path) { cleanpath path }
        let(:const) { const }
        it { should raise_error(failmsg) }
      end
    end
    bunk "foo", 'Bar', /failed.*infer.*Bar.*foo/
    bunk "poo/bah", "Poo::Bah::Bizzle::Bazzle", /failed.*Bazzle.*poo\/bah/
  end
end

