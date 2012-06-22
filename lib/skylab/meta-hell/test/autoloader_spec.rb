require_relative '../../../skylab'

describe Skylab::Autoloader do
  context "infers a path based on simple heuristics." do
    let(:subject) { Skylab::Autoloader.guess_dir(const, path) }
    def self.with path, const, dir, comment=nil, *a
      describe("The dirpath for #{const} calling from #{path} #{comment}", *a) do
        let(:path) { path.sub(/\.rb$/, '') }
        let(:const) { const }
        it { should eql(dir) }
      end
    end
    with "tan-man/models/config.rb", "TanMan::Models::Config", "tan-man/models/config", "(same folder)"
    with "treemap/r/client.rb", "Treemap::R", "treemap/r", "(peek one level up)"
    with "tm/cli.rb", "TM::CLI::Actions", "tm/cli/actions", "(infer one level down)"
    with "sl/issue/api.rb", "SL::Issue::Models", "sl/issue/models", "(one up and one down)"
    with 'sl/test-support/test-support.rb', 'SL::TestSupport', 'sl/test-support', "(double deuce)"
  end
end

