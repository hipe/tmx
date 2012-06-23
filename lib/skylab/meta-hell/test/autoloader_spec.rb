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
    with "foo", "Foo", "foo", "(conventional atomic case)"
    with "foo/bar", "Foo::Bar", 'foo/bar', "(conventional, plural)"
    with "foo/bar", "Foo", "foo", "(peek one level up atomic case)"
    with "C:\>///foo/foo", "Foo", "C:\>/foo", "(double deuce edge case)"
    with "tan-man/models/config", "TanMan::Models::Config", "tan-man/models/config", "(longer conventional case)"
    with "treemap/r/client", "Treemap::R", "treemap/r", "(peek one level up)"
    with "appkin", "Appkin::Nodule", "appkin/nodule", "(infer one level down, atomic case)"
    with "tm/cli", "TM::CLI::Actions", "tm/cli/actions", "(infer one level down, representative case)"
    with "sl/issue/api", "SL::Issue::Models", "sl/issue/models", "(one up and one down)"
    with 'sl/test-support/test-support', 'SL::TestSupport', 'sl/test-support', "(double deuce)"
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

