# (below comment is kept for #posterity although we have since broken
# the regressibility of this test in the interest of getting complete
# coverage testing thru quickie)

# NOTE this file tests skylab.rb (specifically the central workhorse
# method of all of autoloading for the entire universe org-wide)
# and as such we cannot easily use lots of nerks that we otherwise
# would want to (like Quickie, Regret, and of course autoloading
# in general). But alas, the center of the universe has to be
# somewhere. TADA:

require_relative 'test-support'

module Skylab::MetaHell::TestSupport::AL_

  module InstanceMethods
    def cleanpath x
      ::Pathname.new( x ).sub_ext( '' ).to_s  # copypasta nec.
    end
  end

  Guess_dir_ = ::Skylab::Autoloader::Guess_dir_

  # ( [#041] explains why we have fully qualified names below )

  describe "#{ ::Skylab::Autoloader } [..] `guess_dir`" do


    context "infers a path based on simple heuristics." do

      include InstanceMethods

      def self.with path, const, dir, desc, *a

        it "The dirpath for #{ const } called from #{ path } #{ desc }", *a do
          act = Guess_dir_[ const, cleanpath( path ), -> e { fail e } ]
          act.should eql( dir )
        end
      end

      with "foo", "Foo", "foo", "(conventional atomic case)"

      with "foo/bar", "Foo::Bar", 'foo/bar', "(conventional, plural)"

      with "foo/bar", "Foo", "foo", "(peek one level up atomic case)"

      with "C:\>///foo/foo", "Foo", "C:\>/foo", "(double deuce edge case)"

      with "tan-man/models/config", "TanMan::Models::Config",
             "tan-man/models/config", "(longer conventional case)"

      with "treemap/r/client", "Treemap::R", "treemap/r", "(peek one level up)"

      with "appkin", "Appkin::Nodule", "appkin/nodule",
             "(infer one level down, atomic case)"

      with "tm/cli", "TM::CLI::Actions", "tm/cli/actions",
             "(infer one level down, representative case)"

      with "sl/issue/api", "SL::Issue::Models", "sl/issue/models",
             "(one up and one down)"

      with 'sl/test-support/test-support', 'SL::TestSupport',
             'sl/test-support', "(double deuce)"

      with 'a/b/some-lib/client.rb', "Baz::SomeLib::CSV::Action",
              'a/b/some-lib/csv/action', '(deeper)'

      with "poo/bah", "Poo::Bah::Bizzle::Bazzle::HTTPAuth",
             'poo/bah/bizzle/bazzle/http-auth', '(infer 3 deep)'
    end

    context "fails" do

      include InstanceMethods

      def self.bunk path, const, failmsg, *a

        it "The msg of the exception thrown for #{ const } from #{ path }", *a do

          -> do

            Guess_dir_[ const, cleanpath( path ), -> e { fail e } ]

          end.should raise_error( failmsg )
        end
      end

      bunk "foo", 'Bar', /failed.*infer.*Bar.*foo/
    end
  end
end
