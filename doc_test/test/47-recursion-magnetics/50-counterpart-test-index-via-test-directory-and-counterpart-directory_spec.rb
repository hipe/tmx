require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] recursion mags - counterpart test index via [..]" do

    TS_[ self ]
    use :memoizer_methods
    use :want_event
    use :recursion_magnetics

    it "loads" do
      _subject_mag
    end

    it "noent - emits the message as-is from find" do

      _against_expecting_error the_noent_directory_

      want_emission :error, :find_error do |em|

        _lines = black_and_white_lines em
        line = _lines.fetch(0)
        # at #history-B.1, GNU find uses a single quote around the pathname
        line.include? 'No such file or directory' or fail
        line.include? 'not-here.d' or fail
      end
    end

    context "the (effectively) empty directory" do

      shared_subject :_index do

        _test_dir = the_empty_directory_
        _against _test_dir, '/watanabi/fatanabi'
      end

      it "builds" do
        _index || fail
      end

      context "zoopie" do

        shared_subject :_details do
          _asset_path = '/watanabi/fatanabi/woobie-foobie-/noobie-choobie--.ko'
          _ind = _index
          _ind.details_via_asset_path _asset_path
        end

        it "knows it is not real" do
          _details.is_real && fail
        end

        it "comes up with a path that is not real" do
          _abs = _details.to_path
          _act = Safe_localize_[ _abs, the_empty_directory_ ]
          _act == "woobie-foobie/noobie-choobie_speg.ko" || fail  # #path
        end
      end

      alias_method :_name_conventions, :tite_fake_name_conventions_
    end

    context "moneytackulous" do

      shared_subject :_index do

        _test_dir = my_real_test_directory_
        _counterpart_dir = my_real_counterpart_directory_
        _against _test_dir, _counterpart_dir
      end

      it "builds" do
        _index || fail
      end

      context "when there IS a corresponding test, it finds it and says so" do

        shared_subject :_details do
          _ind = _index
          _ind.details_via_asset_path __subject_magnetic_would_be_asset_path
        end

        it "the details it results in say that a real path was found" do
          _details.is_real || fail
        end

        it "against all odds the correct path is found" do

          _act = _details.to_path
          _exp = normalize_real_test_file_path__ __FILE__  # have a look
          _act == _exp || fail
        end
      end

      context "when there IS a corresponding test dir, but no file" do

        shared_subject :_details do

          _asset_path = "#{ some_real_magnetics_directory_ }/jimbie-joobie--.rb"
            # use a real-looking extension here because etc.; #path

          _ind = _index
          _ind.details_via_asset_path _asset_path
        end

        it "knows the path is imaginary" do
          _details.is_real && fail
        end

        it "uses the real directory" do
          _abs = _details.to_path
          _act = Safe_localize_[ _abs, my_real_test_directory_ ]
          _act == "47-recursion-magnetics/jimbie-joobie_spec.rb" || fail
        end
      end

      alias_method :_name_conventions, :selfsame_name_conventions_
    end

    def _against_expecting_error test_dir

      el = event_log

      el.set_hash_of_terminal_channels_to_ignore( find_command_args: true )

      _p = el.handle_event_selectively

      _result = _subject_mag[ test_dir, :_nvr_, _name_conventions, _sc, & _p ]

      want_failure_value _result
      NIL
    end

    def _against td, cd  # assume no error ergo no emissions ergo no listener
      _subject_mag[ td, cd, _name_conventions, _sc ]
    end

    def _sc
      the_real_system_
    end

    alias_method :_name_conventions, :tite_fake_name_conventions_

    def _subject_mag
      Home_::RecursionMagnetics_::CounterpartTestIndex_via_TestDirectory_and_CounterpartDirectory
    end

    memoize :__subject_magnetic_would_be_asset_path do
      _head = ::File.join(
        Home_::RecursionMagnetics_.dir_path,
        'counterpart-test-index-via-test-directory-and-counterpart-directory',
      )
      "#{ _head }#{ Autoloader_::EXTNAME }"
    end
  end
end
# #history-B.1: target Ubuntu not OS X
