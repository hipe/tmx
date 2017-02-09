require_relative '../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] API - mondrian" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_emission_fail_early

    it "you can see just a list of the would-be nodes to load" do

      head_path = Home_.dir_path
      j = -> * s_a do
        ::File.join head_path, * s_a
      end
      _thing_1 = j[ 'magnetics-', 'node-for-tr*' ]
      _thing_2 = j[ 'magnetics', 'ascii-matrix*' ]

      call(
        :list_nodes_to_load,
        :path, _thing_1, :path, _thing_2,
        :head_const, Home_.name,
      )

      st = execute
      a = st.to_a

      ::File.basename(a[0]) == 'magnetics-' || fail
      ::File.basename(a[1]) == 'node-for-treemap-via-recording' || fail
      ::File.basename(a[2]) == 'magnetics' || fail
      ::File.basename(a[3]) == 'ascii-matrix-via-shapes-layers' || fail
      4 == a.length || fail
    end

    def expression_agent
      _interface_library::API_InterfaceExpressionAgent.instance
    end

    def subject_API

      # it's kind of gross to be using CLI-style arguments in tests when
      # we're not testing anything CLI-specific. however we have no "need"
      # for an API-style interface for the subject operation, yet. so
      # here's how we can cobble one together:

      X_oper_mon_PretendingToBe_API_Module___.new do |p, x_a|

        if do_debug
          x_a[ 0, 0 ] = [ :verbose ]  # gotta go in front
        end

        _Mondrian = _subject_library
        _Interface = _interface_library
        _scn = _Interface::API_ArgumentScanner.new x_a, & p
        op = _Mondrian::Operation__.new _scn, debug_IO

        _ok = _Interface::ParseArguments_via_FeaturesInjections.define do |o|
          o.argument_scanner = _scn
          o.add_primaries_injection op.class::PRIMARIES, op
        end.flush_to_parse_primaries

        _ = _ok && op.execute
        _  # hi.
      end
    end

    class X_oper_mon_PretendingToBe_API_Module___

      # hack to pretend we are an API module that does "invocation" model

      def initialize & p
        @__runny_money = p
      end

      def invocation_via_argument_array a, & p
        @__argument_array = a ; @__listener = p
        self
      end

      def execute
        remove_instance_variable( :@__runny_money ).call(
          remove_instance_variable( :@__listener ),
          remove_instance_variable( :@__argument_array ),
        )
      end
    end

    # ==

    def _interface_library
      _subject_library::Interface__
    end

    # ==

    def _subject_library
      Home_::Mondrian_[]
    end

    # ==
  end
end
