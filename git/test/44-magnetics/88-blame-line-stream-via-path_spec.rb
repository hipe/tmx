# frozen_string_literal: true

require_relative '../test-support'

module Skylab::Git::TestSupport

  describe '[gi] magnetics - blame line stream via path' do

    # #coverpoint1.1

    TS_[ self ]
    use :memoizer_methods

    it 'loads' do
      _subject_module || fail
    end

    context 'against nonexistent path (LIVE)' do

      it 'fails - ONLY ONCE YOU gets for a thing' do
        x, ok = _tuple
        ok == false || fail
        x.nil? || fail
      end

      same = 128

      it 'gives you vendor exitstatus (fragile)' do
        _es = _tuple.fetch 2
        _es == same || fail
      end

      it 'emitted message with vendor exitstatus (FRAGILE)' do

        a = _tuple.last
        1 == a.length || fail
        em = a.first
        em.channel_symbol_array == [ :error, :expression, :system_error ] || fail
        _msg = em.to_black_and_white_line
        md = /\Afatal: '[^']+' is outside repository\b(?<rest>.+)\Z/.match _msg
        md || fail
        rest = md[:rest]
        md = /\bexitstatus: (?<es>\d+)/.match rest
        md || fail
        md[1].to_i == same || fail
      end

      shared_subject :_tuple do

        log = Common_.test_support::Want_Emission::Log.for self
        _listener = log.listener

        _path = no_ent_path_
        scn = _call_by(
          path: _path,
          ** __get_real_system,
          listener: _listener,
        )

        _x = scn.gets_one_git_blame_line

        _ok = scn.was_OK

        _a = log.flush_to_array

        if ! _ok  # ..
          _es = scn.nonzero_exitstatus
        end

        [ _x, _ok, _es, _a ]
      end
    end

    context '(work case 1 MOCKED)' do

      it 'succeeds' do
        _tuple.first == true || fail
      end

      it 'has 3 blame lines, each blalme line has the line, the lines look right' do
        _ = _blame_lines.map do |o|
          o.line
        end
        want_these_lines_in_array_ _ do |y|
          y << "module ChaCha\n"
          y << "\n"
          y << "endo\n"
        end
      end

      it 'blame line has path, path representation is efficient' do

        o1, o2 = _blame_lines
        o1.object_id == o2.object_id && fail
        o1.path == 'lonka/tonka.file' || fail
        o1.path.object_id == o2.path.object_id || fail
      end

      it 'blame line has line number, line numbers look right' do

        _d_a = _blame_lines.map do |o|
          o.lineno
        end
        _d_a == [ 1, 2, 3 ] || fail
      end

      it 'each blame line has the commit, the commits are efficient' do

        c1, c2, c3 = _three_commits

        c1.object_id == c2.object_id || fail
        c1.object_id == c3.object_id && fail
      end

      it 'these commits have the SHA string, represent it efficiently' do

        s1, s2, s3 = _three_commits.map do |ci|
          ci.SHA_string
        end

        s1 == 'f00faa7' || fail
        s3 == 'faaf007' || fail
        s1.object_id == s2.object_id || fail
      end

      it %q(these commits have the datetime (NOTE - it's `date_time`)) do

        dt1, dt2, dt3 = _three_commits.map do |ci|
          ci.date_time
        end
        dt1.strftime( '%Y' ) == '2016' || fail
        dt1.object_id == dt2.object_id || fail
        dt3 || fail
        dt1.object_id == dt3.object_id && fail
      end

      it 'these commits have the author name, represent it efficiently' do

        s1, _, s3 = _three_commits.map do |ci|
          ci.author_name
        end

        s1 == 'Kelly Marie Tran' || fail
        s1.object_id == s3.object_id || fail
      end

      def _first_and_last_commit
        a = _blame_lines
        [ a.first.commit, a.last.commit ]
      end

      shared_subject :_three_commits do
        _blame_lines.map do |o|
          o.commit
        end
      end

      def _blame_line
        _blame_lines.last
      end

      def _blame_lines
        _tuple.last
      end

      shared_subject :_tuple do

        _ = Home_.lib_.system_lib::Doubles::StubbedSystem::MockedThree

        _mocked_three = _.hash_via_definition(

          given_command: [ 'git', 'blame', /\A(?<path>.+)\z/ ],

          do_this: -> sout, _serr, md do

            path = %r(\A/[^/]+/).match( md[ :path ] ).post_match
              # meh chop off leading path parts to make it look like a
              # repo path. not important

            auth = 'Kelly Marie Tran'  # 3 parts. not just first last

            sout << "f00faa7 #{ path } (#{ auth }        2016-10-13 12:13:03 -0400   1) module ChaCha\n"
            sout << "f00faa7 #{ path } (#{ auth }        2016-10-13 12:13:03 -0400   2) \n"
            sout << "faaf007 #{ path } (#{ auth }        2017-01-02 03:04:05 -0500   3) endo\n"

            0
          end,
        )

        scn = _call_by(
          path: '/chachonka/lonka/tonka.file',
          ** _mocked_three,
        )

        _blame_lines = __flush_blames scn

        _ok = scn.was_OK

        [ _ok, _blame_lines ]
      end
    end

    def __flush_blames scn

      blame_lines = []
      begin
        blame_o = scn.gets_one_git_blame_line
        blame_o || break
        blame_lines.push blame_o
        redo
      end while above
      blame_lines
    end

    def _call_by ** hh
      _subject_module.statisticator_by( ** hh )
    end

    def __get_real_system
      {
        piper: ::IO,
        spawner: ::Kernel,
        waiter: ::Process,
      }
    end

    def _subject_module
      Home_::Magnetics::BlameLineStream_via_Path
    end

    # ==

    # ==
    # ==
  end
end
# #born.
