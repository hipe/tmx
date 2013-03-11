# NOTE this file tests skylab.rb (specifically the central workhorse
# method of all of autoloading for the entire universe org-wide)
# and as such we cannot easily use lots of nerks that we otherwise
# would want to (like Quickie, Regret, and of course autoloading
# in general). But alas, the center of the universe has to be
# somewhere. TADA:

require_relative '../..'

module Skylab::MetaHell  # we borrow this name but nothing in it
end

module ::Skylab::MetaHell::TestSupport  # likewise this name

  Autoloader_ = ::Skylab::Autoloader

  module InstanceMethods
    def cleanpath x
      ::Pathname.new( x ).sub_ext( '' ).to_s  # copypasta nec.
    end
  end

  describe "#{ Autoloader_ } [..] `guess_dir`" do

    guess_dir = Autoloader_::Methods::FUN.guess_dir

    let :subject do
      guess_dir[ const, path, -> e { fail e } ]
    end

    context "infers a path based on simple heuristics." do

      include InstanceMethods

      def self.with path, const, dir, desc, *a

        describe "The dirpath for #{ const } calling from #{
            }#{ path } #{ desc }", *a do

          let :path do cleanpath path end

          let :const do const end

          it do
            should eql( dir )
          end
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

      let :subject do
        -> do
          guess_dir[ const, path, -> e { fail e } ]
        end
      end

      def self.bunk path, const, failmsg, *a

        describe "The msg of the exception thrown for #{ const } #{
            }from #{ path }", *a do

          let :path do cleanpath path end

          let :const do const end

          it do
            should raise_error( failmsg )
          end
        end
      end

      bunk "foo", 'Bar', /failed.*infer.*Bar.*foo/
    end
  end
end
