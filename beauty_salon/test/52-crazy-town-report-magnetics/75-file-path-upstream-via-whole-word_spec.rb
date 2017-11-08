# frozen_string_literal: true

require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town report magnetics - file path upstream via whole word', ct: true do

    TS_[ self ]
    use :memoizer_methods

    it 'when you use a crazy-looking fixed string' do
      _msgs = _error_messages_via_fixed_string 'not#valid'
      expect_these_lines_in_array_ _msgs do |y|
        y << 'currently, your name pattern must contain only letters, numbers and underscores'
        y << '(bad character: "#")'
      end
    end

    it 'fixed string empty' do
      _msgs = _error_messages_via_fixed_string EMPTY_S_
      _msgs == [ 'name pattern cannot be the empty string.' ] || fail
    end

    context %q(when one of the directories doesn't exist) do

      it 'whines directly from find' do
        _lines.fetch( 0 ) =~ /\Afind: [^ ]+ No such file or directory\b/ || fail
      end

      it 'gives nonzero exitstatus' do
        _lines.fetch( 0 ) =~ / \(exitstatus: 1\)\z/ || fail
      end

      shared_subject :_lines do
        _error_messages_via_dir _no_ent_dir
      end
    end

    context '(normal)' do

      it 'the variety of directories is represented' do
        _index.seen_dirname.length == 2 || fail
      end

      it 'the files we expected to find were found' do
        h = _index.count_via_basename
        h[ '500-expression-grouping' ] || fail
        h[ 'la-la-010' ] || fail
        h[ 'la-la-020' ] || fail
      end

      it 'when there is more than one match in a file, the file appears only once' do
        _index.count_via_basename[ 'la-la-020' ] == 1 || fail
      end

      shared_subject :_index do

        _pcs = _call_by do |o|
          o.set_whole_word_match_fixed_string 'fixed_string1'
          o.add_dir Ruby_current_version_dir_[]
          o.add_dir Fixture_function_dir_[]
          o.set_name_pattern _common_name_pattern
          o.listener = -> * { no }
        end

        __build_this_one_index_via_stream _pcs
      end
    end

    it %q(when one of the directories isn't a directory - it's OK (also no matches at all)) do

      pcs = _call_by do |o|
        o.set_whole_word_match_fixed_string "unique_string_#{}in_this_file"
        o.add_dir __FILE__
        o.set_name_pattern _common_name_pattern
        o.listener = nil
      end

      _line = pcs.gets_one_stdout_line
      _ok = pcs.was_OK
      _line.nil? || fail
      _ok || fail
    end

    def __build_this_one_index_via_stream pcs

      seen_dirname = {}
      count_via_basename = ::Hash.new 0

      begin
        path = pcs.gets_one_stdout_line
        path || break

        _stem = Stem_via_filesystem_path_[ path ]

        _dn = ::File.dirname path
        _bndn = ::File.basename _dn

        count_via_basename[ _stem ] += 1
        seen_dirname[ _bndn ] = true
        redo
      end while above

      pcs.was_OK || fail

      X_rm_fpuvfs_Struct.new count_via_basename.freeze, seen_dirname.freeze
    end

    X_rm_fpuvfs_Struct = ::Struct.new :count_via_basename, :seen_dirname

    def _error_messages_via_fixed_string needle_s

      _expect_early_error_messages_when_call_by do |o|
        o.set_whole_word_match_fixed_string needle_s
        o.add_dir _no_ent_dir
        o.set_name_pattern _common_name_pattern
      end
    end

    def _error_messages_via_dir path

      _expect_early_error_messages_when_call_by do |o|
        o.set_whole_word_match_fixed_string 'must_be_valid'
        o.add_dir path
        o.set_name_pattern _common_name_pattern
      end
    end

    def _expect_early_error_messages_when_call_by

      log = Common_.test_support::Expect_Emission::Log.for self
      _x = _call_by do |o|
        yield o
        o.listener = log.listener
      end

      _x.nil? || fail  # false would be OK too
      em_a = log.flush_to_array
      1 == em_a.length || fail
      em = em_a.first
      em.to_black_and_white_lines  # better: express_into_under
    end

    memoize :_common_name_pattern do
      "#{ Home_::GLOB_STAR_ }#{ Autoloader_::EXTNAME }".freeze
    end

    def _no_ent_dir
      TestSupport_::Fixtures.directory :not_here
    end

    def _call_by
      subject_magnetic_.call_by do |o|
        yield o
        o.piper = ::IO
        o.spawner = ::Kernel
        o.process_waiter = ::Process
      end
    end

    def subject_magnetic_
      Home_::CrazyTownReportMagnetics_::FilePathUpstream_via_WholeWord
    end
  end
end
# #born.
