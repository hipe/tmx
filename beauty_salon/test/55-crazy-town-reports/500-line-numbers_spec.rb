require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy town reports - line numbers', ct: true do

    TS_[ self ]
    use :memoizer_methods

    it 'subject magnetic loads' do
      _subject_magnetic || fail
    end

    it 'the "file paths" report (the equivalent of `ping`) - just echos the paths, no parse' do

      same = %w( floofie flaffie )

      # -
        _st = _call_subject_magnetic_by do |o|

          o.report_name = 'echo-file-paths'

          o.file_path_upstream = Home_::Stream_[ same ]
        end
      # -

      _actual = _st.to_a
      _actual == same || fail
    end

    context 'line numbers against one file (the one fixture codefile we have)' do

      it 'the first line looks like a comment line, expresses the filename' do
        first_line = _tuple[0]
        /\A# \(file: ./ =~ first_line or fail
      end

      it 'every feature is of a set of expected features' do
        features_seen = _tuple[1]
        # (the below list generated with the use of the trick at #spot1.2)
        %i(
          block
          block_pass
          call
          case
          cdecl
          class
          defn
          dstr
          evstr
          gvar
          if
          lit
          lvar
          module
          nil
          str
        ).each do |sym|
          features_seen.delete( sym ) or fail "feature not seen: '#{ sym }'"
        end
        xtra = features_seen.keys
        if xtra.length.nonzero?
          fail "unexpected features: '#{ xtra * ', ' }'"
        end
      end

      it 'every next line number is greater than or equal to the previous one (EXCEPT SOME)' do

        # NASTY - generally, assert that each next line number in your
        # stream (table) is greater than or equal to each previous line
        # number. ok, that's fine. however:
        #
        # if-else chains appear to be parsed as sort of like recursive
        # "trinary" trees, rather than as flat lists. so code like this:
        #
        #     if A ; B
        #     elsif C ; D
        #     else E ; end
        #
        # parses like this:
        #
        #     (if, A, B,
        #       ( if, C, D, E )
        #     )
        #
        # so that as you add each additional `elsif`, the tree grows
        # downward instead of outward (so that the final `else` is always
        # associated with the deepest `if`, as opposed to being the final
        # element of the rootmost `if` (which, how could it be?)).
        #
        # ok, that's also fine. BUT: it also appears that each subordinate
        # `if` tree that is "generated" from this syntactic de-sugaring
        # expresses as its line number something like the last line that
        # is touched by the whole (root) `if` structure..
        #
        # (we haven't investigated this deeply for lack of need.)
        #
        # in practice we hope we can avoid this tripping us up;
        # but we want to crystalize this peculiarity here with some #eyeblood..

        table = _tuple[2]
        20 < table.length || fail  # whatever - more than the number of unique features (at writing 52)

        is_subsequent = -> do  # expect one `if`, then another `if`, then no more
          is_subsequent = -> { is_subsequent = -> { fail } ; true }
          false
        end

        prev = 0
        table.each_with_index do |(kw, lineno), _d|

          direction = prev <=> lineno

          if :if == kw
            # hi.
            if is_subsequent[]
              -1 == direction || fail  # this second `if` is "jumping ahead"
              # to act like it is further down than it actually is. don't
              # let it mess up the broader pattern we are asserting. YUCK!
              next
            end
          end

          case direction
          when -1 ; prev = lineno
          when 0  ; NOTHING_
          when 1  ; fail
          end
        end
      end

      shared_subject :_tuple do

        _path = TestSupport_::Fixtures.executable :for_simplecov

        st = _call_subject_magnetic_by do |o|

          o.report_name = 'line-numbers'

          o.file_path_upstream = Common_::Stream.via_item _path

          o.filesystem = ::File
        end

        first_line = st.gets
        features_seen = {}
        table = []

        begin
          line = st.gets
          line || break
          md = /\A(?<sym_sym>[a-z]+(?:_[a-z]+)*) (?<lineno>\d+)$/.match line
          md || fail
          k = md[ :sym_sym ].intern
          features_seen[ k ] = true
          table.push [ k, md[ :lineno ].to_i ]
          redo
        end while above

        [ first_line, features_seen, table ]
      end
    end

    def _call_subject_magnetic_by

      _subject_magnetic.call_by do |o|
        o.filesystem = NOTHING_
        o.listener = NOTHING_
        yield o
      end
    end

    def _subject_magnetic
      Home_::CrazyTownMagnetics_::Result_via_ReportName_and_Arguments
    end

    # ==
    # ==
  end
end
