# frozen_string_literal: true

require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy town reports - preview selected', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :my_reports

    context 'weird name' do

      it 'says no' do
        _hi = _lines.first
        _hi == 'unrecognized grammar symbol "kwoptarggo".' || fail
      end

      it 'offers suggestions' do

        # we don't care to cover this to a level of detail so tight that
        # the exact constituency is asserted. it is enough just to assert
        # that what is expressed looks right, roughly.

        _hi = _lines.last
        _rest = %r(\Adid you mean '(.+)'\?\z).match( _hi )[1]
        _these = _rest.split %r(', '|' or ')
        count = 0 ; strange = nil
        _these.each do |type_s|
          if type_s.include? 'arg'
            count += 1
          else
            ( strange ||= [] ).push type_s
          end
        end
        # -- the below changes as necessary

        # #open [#049] flickering, probably because diminishing pool of aliases
        if 2 == count
          # (this happens when you run all tests in order)
          strange.nil? || fail
        elsif 5 == count
          # (this happens when you run only this file)
          # strange == %w(op_asgn kwbegin lvar) || fail
          h = {}
          strange.each do |s|
            h[s] = true
          end
          h.delete 'op_asgn' or fail
          h.delete 'kwbegin'
          h.delete 'lvar'
          if h.length.nonzero?
            fail
          end
        else
          fail
        end
      end

      shared_subject :_lines do
        _lines_of_parse_failure_by_call_subject_magnetic_by do |o|
          o.code_selector_string = %q{kwoptarggo(aa=='bb')}
        end
      end
    end

    context 'bad component' do

      it 'says no' do
        _hi = _lines.first
        _hi == %q(grammar symbol 'send' has no component "method_namezz".) || fail
      end

      it 'offers suggestions' do
        _hi = _lines.last
        _hi == %q(the only known component: 'method_name') || fail
      end

      shared_subject :_lines do
        _lines_of_parse_failure_by_call_subject_magnetic_by do |o|
          o.code_selector_string = %q{send(method_namezz=='bb')}
        end
      end
    end

    # context "operator literal mismatch"..

    context 'wahoo jimmy jam this shammy' do

      it 'first line talkin bout dat file' do
        _first_line = _tuple.first
        _first_line =~ /\Afile: [^[:space:]]/ || fail
      end

      it 'middle lines talkin bout those matches' do

        # assert that there is more than one code line talked about
        # assert that at least one of the lines talks about more than one feature
        # assert that each line number is always greater than the previous line number

        # NOTE - this was written before #here1, which might help clean this up

        middle_lines = _tuple[1]

        3 < middle_lines.length || fail

        seen_num_features = {}

        lowest_line = 0

        middle_lines.each do |line|

          md = /\A(?<num>\d+) feature( |s) on line[ ]+(?<lineno>\d+):[ ]+[^[:space:]]/.match line

          seen_num_features[ md[ :num ].to_i ] = nil

          lineno = md[ :lineno ].to_i

          lowest_line < lineno || fail
          lowest_line = lineno
        end

        1 < seen_num_features.length || fail
      end

      it 'last line talkin bout dat summary' do
        _last_line = _tuple.last
        _last_line =~ /\A# \(\d total match\(es\) in 1 file\(s\)\)\z/ || fail
      end

      shared_subject :_tuple do

        _path = TestSupport_::Fixtures.executable :for_simplecov

        st = _call_subject_magnetic_by do |o|

          o.argument_paths = [ _path ]

          o.code_selector_string = %q{send(method_name=='<<')}
        end

        first_line = st.gets
        middle_lines = st.to_a

        [ first_line, middle_lines, middle_lines.pop ]  # look
      end
    end

    it 'whine about how for this case we need the search string' do

      anticipate_ :error, :expression, :argument_error do |y|
        y == ['expecting unsanitized before string at end of macro string'] || fail
      end

      _x = _call_subject_magnetic_by do |o|
        o.argument_paths = [ Ruby_current_version_dir_[] ]
        o.macro_string = 'method:'
      end

      _x.nil? || fail
    end

    it %q[with macro, confirm that it doesn't let you also specify selector (or repl f)] do

      anticipate_ :error, :expression, :argument_error do |y|
        y << "when you use a macro you cannot also pass 'code_selector'"
      end

      _x = _call_subject_magnetic_by do |o|
        o.argument_paths = [ 'xx_dir' ]
        o.macro_string = 'method:xx_meth'
        o.code_selector_string = %q{send(method_name=='<<')}
      end

      _x.nil? || fail
    end

    context 'macro money' do

      it 'out of three files, 2 were hits' do
        _pages.length == 2 || fail
      end

      it 'number of features counts calls AND definitions NOT longer matches' do

        _pages.first[ :features_count ] == 2 || fail
      end

      it 'one definition, 4 calls (3 of which are nested/recursive), one needle in comment' do

        _pages.last[ :features_count ] == 5 || fail
      end

      it 'the multi-line part shows how many lines the match covers' do
        _d_a_a = _pages.last[ :lines_series ]
        d_a = _d_a_a.last
        ( d_a.fetch( 1 ) - d_a[ 0 ] ) == 5 || fail
      end

      it 'the summary' do
        _s = _pages.last.fetch :other
        _s == "# (7 total match(es) in 2 file(s))" || fail
      end

      shared_subject :_pages do

        _path = Fixture_tree_for_case_one_[]

        _st = _call_subject_magnetic_by do |o|
          o.argument_paths = [ _path ]
          o.macro_string = 'method:ravi_bhalla'
        end
        __build_this_one_index _st
      end
    end

    def __build_this_one_index st  # :#here1

      #  [
      #    { features_count: 3,
      #      lines_series: [ [1], [3,5], [7] ],
      #      other: "total: xx",
      #    },
      #    ..
      #  ]

      pages = []
      page_rx = /\Afile: [[:print:]]/

      begin
        line = st.gets
        line || break
        if page_rx =~ line
          pages.push( features_count: 0, lines_series:[] )
          redo
        end
        stats = pages.last
        md = /\A(\d+) features? +on lines? +(\d+)(?:-(\d+))?: +[[:print:]]/.match line
        if md
          stats[ :features_count ] += md[1].to_i
          range = [ md[2].to_i ]
          s = md[3]
          if s
            range.push s.to_i
          end
          stats[ :lines_series ].push range
          redo
        end
        stats[ :other ] && fail
        stats[ :other ] = line
        redo  # but actually probably you are done
      end while above
      pages
    end

    def _lines_of_parse_failure_by_call_subject_magnetic_by

      log = Common_.test_support::Want_Emission::Log.for self

      _x = _call_subject_magnetic_by do |o|
        o.listener = log.listener
        o.argument_paths = EMPTY_A_  # can be written with more stuff
        yield o
      end

      _x && fail

      em_a = log.flush_to_array
      1 == em_a.length || fail
      _expag = expression_agent
      _expag.calculate [], & em_a[0].expression_proc
    end

    def _call_subject_magnetic_by & p
      call_report_ p, :preview_selected
    end

    def expression_agent
      # (same as My_API -- .. -- .. -- )
      ::NoDependenciesZerk::API_InterfaceExpressionAgent.instance
    end

    # ==
    # ==
  end
end
