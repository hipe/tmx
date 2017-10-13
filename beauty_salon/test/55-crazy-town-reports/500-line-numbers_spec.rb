# frozen_string_literal: true

require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy town reports - line numbers', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :my_reports

    it 'API const loads' do
      Home_::API || fail
    end

    it 'the "file paths" report (the equivalent of `ping`) - just echos the paths, no parse' do

      same = %w( floofie flaffie )

      # -
        _st = _call_subject_magnetic_by do |o|

          o.report_name = :echo_file_paths

          o.argument_paths = same
        end
      # -

      _actual = _st.to_a
      _actual == same || fail
    end

    context 'line numbers against one file (the one fixture codefile we have)' do  # #testpoint2.11

      it 'the first line looks like a comment line, expresses the filename' do
        first_line = _tuple[0]
        /\A# \(file: ./ =~ first_line or fail
      end

      it 'every feature is of a set of expected features' do
        features_seen = _tuple[1]
        # (the below list generated with the use of the trick at #doc1.1)
        %i(
          arg
          args
          begin
          block_pass
          case
          casgn
          cbase
          class
          const
          def
          dstr
          gvar
          if
          int
          lvar
          module
          nil
          send
          str
          sym
          when
        ).each do |sym|
          features_seen.delete( sym ) or fail "feature not seen: '#{ sym }'"
        end
        xtra = features_seen.keys
        if xtra.length.nonzero?
          fail "unexpected features: '#{ xtra * ', ' }'"
        end
      end

      it 'every next line number is greater than or equal to the previous one' do

        # (at #history-A.1 we had to do a NASTY accomodation to a weirdness
        #  that happend with the old library. the weirdness appears to be
        #  fixed now, but if you're curious, see the historypoint for a
        #  longwinded explanation.)

        table = _tuple[2]
        20 < table.length || fail  # whatever - more than the number of unique features (at writing 79)

        count_of_items_without_lineno = 0
        prev = 0
        table.each do |(_kw, lineno)|

          if ! lineno
            count_of_items_without_lineno += 1
            1 < count_of_items_without_lineno && fail
            next
          end

          direction = prev <=> lineno

          case direction
          when -1 ; prev = lineno
          when 0  ; NOTHING_
          when 1  ; fail
          end
        end
      end

      shared_subject :_tuple do

        _path = TestSupport_::Fixtures.executable :for_simplecov
        st = __line_numbers_line_stream_for_path _path

        first_line = st.gets
        features_seen = {}
        table = []

        begin

          line = st.gets
          line || break

          md = /\A
            (?<sym_sym>[a-z]+(?:_[a-z]+)*)
            [ ]
            (?:
              (?<line_range>
                (?<from>\d+)
                (?: - (?<to> \d+ ) )?
              )
              |
              (?:
                \(
                  (?<comment> [^)]+ )
                \)
              )
            )
          \z/x.match line

          md || fail
          k = md[ :sym_sym ].intern
          features_seen[ k ] = true
          a = [ k ]
          if md[ :line_range ]
            a.push md[ :from ].to_i
            s = md[ :to ]
            if s
              a.push s.to_i
            end
          end
          table.push a
          redo
        end while above

        [ first_line, features_seen, table ]
      end
    end

    def __line_numbers_line_stream_for_path path

      _call_subject_magnetic_by do |o|

        o.report_name = :line_numbers

        o.argument_paths = [ path ]
      end
    end

    def _call_subject_magnetic_by & p
      call_report_ p, NOTHING_  # see how it's used
    end

    # ==
    # ==
  end
end
# #history-A.1: begin refactoring from 'ruby_parser' to 'parser'
