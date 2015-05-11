require_relative 'test-support'

module Skylab::Callback::TestSupport::Name::Guess_dir_path

  ::Skylab::Callback::TestSupport::Name[ self ]

  include Constants

  extend TestSupport_::Quickie

  module InstanceMethods
    def cleanpath x
      ::Pathname.new( x ).sub_ext( '' ).to_s  # copypasta nec.
    end
  end

  Guess_dir_ = Callback_::Name.lib.guess_dir

  # ( [#054] explains why we have fully qualified names below )

  describe "[ca] name guess-dir-path" do

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
# #posterity: the first "center of the universe" may have in this file
