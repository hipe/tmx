require_relative 'test-support'

module Skylab::Git::TestSupport

  describe "[gi] checker" do

    TS_[ self ]
    use :memoizer_methods
    use :want_event

    context "(context)" do

      it "no block, unversioned (out of repo) = false" do

        _ = _subject _unversioned_B_path
        _ == false or fail
      end

      it "no block, unversioned (in repo) = false" do

        _ = _subject _unversioned_A_path
        _ == false or fail
      end

      it "no block, modified = false" do

        _ = _subject _modified_path
        _ == false or fail
      end

      it "no block, unchanged = true" do

        _ = _subject _unchanged_path
        _ == true or fail
      end

      it "block, unversioned (out of repo) - expresses no repo" do

        _ = _subject_ _unversioned_B_path
        _ == false or fail

        _be_this = be_emission_beginning_with :error, :expression do |y|

          y.fetch( 0 ) == "not in a git repository - #{
            }(pth \"/tmp/unversioned-B.file\")" or fail
        end

        only_emission.should _be_this
      end

      it "block, unversioned (in repo) - expresses file has not been added" do

        _ = _subject_ _unversioned_A_path
        _ == false or fail

        _be_this = be_emission_beginning_with :error, :expression do |y|

          y[ 0 ] == "file is not under version control - #{
            }(pth \"/fake/repo/somedir/unversioned-A.file\")" or fail
        end

        only_emission.should _be_this
      end

      it "block, modified - expresses \"file changed since index\"" do

        _ = _subject_ _modified_path
        _ == false or fail

        _be_this = be_emission_beginning_with :error, :expression do |y|

          _rx = %r(\Afile changed since index .+ \(pth "[^"]+/modified\.file"\)\z)

          y.first =~ _rx or fail
        end

        only_emission.should _be_this
      end

      it "block, unchanged" do

        _ = _subject_ _unchanged_path
        _ == true or fail

        want_no_emissions
      end

      def emission_array

        # eek - because we're not using memoized states and we're always expecting only

        remove_instance_variable( :@event_log ).flush_to_array
      end

      def _unversioned_A_path
        '/fake/repo/somedir/unversioned-A.file'
      end

      def _unversioned_B_path
        '/tmp/unversioned-B.file'
      end

      def _modified_path
        '/fake/repo/somedir/modified.file'
      end

      def _unchanged_path
        '/fake/repo/somedir/unchanged.file'
      end

      shared_subject :_long_runner do

        sess = _subject_module::Session.begin

        _path = ::File.join Fixture_data_path_[], 'story-1.snippet.rb'

        sc = __snippet_based_system_conduit_via_path _path

        sess.system_conduit = sc

        sess.finish
      end
    end

    def __snippet_based_system_conduit_via_path path
      Home_.lib_.system_lib::Doubles::Stubbed_System::Snippet_Based.via_path(
        path )
    end

    def _subject path
      _long_runner.check path
    end

    def _subject_ path

      _long_runner.check path, & event_log.handle_event_selectively
    end

    def _subject_module
      Home_::Check
    end
  end
end
