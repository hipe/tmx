require_relative '../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] quickie service" do

    # testing a test framework can certainly present Gödel-lian paradoxes:
    #
    # in order to both achieve good coverage *and* improve the quality of
    # code, we are undergoing this almost full rewrite by re-introducing
    # (while restructuring) our "asset code" line-by-line while following
    # (more or less) "three laws" TDD, and (eventually) checking our
    # coverage with code-coverage tools.
    #
    # in the earliest phase of this rebuild there is, of course, no working
    # quickie in our runtime. using (for example) the latest stable quickie
    # to drive the tests of the development-time quickie is not an option,
    # because we have only one (ruby) runtime, and we have to run the tests
    # in the same runtime as the asset code they are testing.
    #
    # but as soon as we reach the point where quickie could run the body of
    # an example (and we don't mean predicates (no `should`, no `eql`), we
    # just mean the ability to evaluate the body of an `it` block); we refer
    # to this as quickie becoming "self-supporting" because (in theory) it
    # is at this point that we can use quickie to run its own tests..
    #
    # (EDIT: show where this change happens)
    #
    # the reason this is possible without being as meaningless as it sounds
    # is this: in those self-testable tests we only use mechanisms that have
    # been covered by previous tests. so each next test uses what is "proven"
    # to be working by the tests before it. it's a bit like how it's
    # possible to cut metal with metal -- you use a harder metal to cut a
    # softer metal. in this weird analogy, the features covered by previous
    # tests are like the harder metal.
    #
    # so when something is broken it is essential that you either use rspec
    # or run the tests in their "regression order" and focus only on the
    # first failing test.
    #
    # the above explanation is all mostly a mental exercise: when this is
    # finished rspec and quickie can be used equally well to run these. the
    # abve pertains only to development- and regression- time.

    TS_[ self ]
    use :memoizer_methods
    use :the_method_called_let
    use :quickie

    it "loads" do
      subject_module_ || fail
    end

    # ==

    context "`enable_kernel_describe`" do

      context "in a runtime where `describe` is already defined" do

        it "does NOT alter its meaning" do
          rt = build_runtime_
          rt.__enable_kernel_describe
          # (absence of failure is success)
        end

        def kernel_module_
          ke = begin_mock_module_
          ke.have_method_defined :describe
          ke
        end

        def toplevel_module_
          :_no_see_ts_
        end
      end

      context "in a runtime where `describe` is NOT already defined" do

        it "quickie defines this method on the kernel" do
          rt = build_runtime_
          rt.__enable_kernel_describe
          kernel_module_.finish
        end

        let :kernel_module_ do
          ke = begin_mock_module_
          ke.have_method_not_defined :describe
          ke.expect_to_have_method_defined :describe
          ke
        end

        def toplevel_module_
          NOTHING_
        end
      end
    end

    # ==

    touch_service = :_touch_quickie_service

    context "touch the quickie service - autonomous start" do

      it 'the "service" can "start" itself directly by using globals' do

        _state.first == :hello_once || fail
      end

      it "subsequent attempts to access the service access the memoized instance" do

        _rt = _state.last
        _wat = _rt.send touch_service
        _wat == :hello_once || fail
      end

      shared_subject :_state do

        rt = build_runtime_
        seen = false
        hack_runtime_to_build_this_service_ rt do
          seen && fail
          seen = true ; :hello_once
        end
        _wat = rt.send touch_service
        [ _wat, rt ]
      end

      def toplevel_module_
        toplevel_module_with_rspec_not_loaded_
      end

      def kernel_module_
        ke = begin_mock_module_
        ke.have_method_not_defined :should
        ke.expect_to_have_method_defined :should
        ke
      end
    end

    # ==

    context "start the quickie service - can be started as a traditional CLI (STUB)" do

      it "the service is started by being injected with a client" do

        _svc = _state.first
        _svc.instance_variable_get( :@_client ).
          instance_variable_get( :@_stderr ) == :_no_see_ts_ || fail
      end

      shared_subject :_state do

        rt = build_runtime_
        _svc = hackishly_start_service_ rt
        [ _svc ]
      end

      def toplevel_module_
        toplevel_module_with_rspec_not_loaded_
      end

      def kernel_module_
        ke = begin_mock_module_
        ke.expect_to_have_method_defined :should
        ke
      end
    end

    # ==

    context "enhance a test support module to have a `describe` (the common way)" do

      subject_method = :__enhance_test_support_module_with_the_method_called_describe

      context "if r.s is already loaded," do

        it "stays out of the way" do

          rt = build_runtime_

          hackishly_start_service_ rt

          _NOT_A_MODULE = :z

          rt.send subject_method, _NOT_A_MODULE
        end

        def kernel_module_
          :_should_not_touch_kernel_module_
        end

        def toplevel_module_
          toplevel_module_with_rspec_already_loaded_
        end
      end

      # ~

      context "if r.s is NOT already loaded," do

        it "the method called `describe` is added to the module" do

          rt = build_runtime_

          hackishly_start_service_ rt

          mock_TS_module = begin_mock_module_
          mock_TS_module.expect_to_have_singleton_method_defined :describe

          rt.send subject_method, mock_TS_module

          mock_TS_module.finish
          kernel_module_.finish
        end

        let :kernel_module_ do
          mod = begin_mock_module_
          mod.expect_to_have_method_defined :should
          mod
        end

        def toplevel_module_
          toplevel_module_with_rspec_not_loaded_
        end
      end

      # ~

      context "if quickie 'has reign' but service failed to start (because ARGV issues)" do

        it "the `describe` method is defined on the kernel anyway (in some manner)" do

          rt = build_runtime_
          hack_runtime_to_build_this_service_ rt do
            NOTHING_  # any false-ish here makes it look like service failed to start
          end

          mock_TS_module = begin_mock_module_
          mock_TS_module.expect_to_have_singleton_method_defined :describe

          rt.send subject_method, mock_TS_module

          mock_TS_module.finish
          kernel_module_.finish
        end

        let :kernel_module_ do
          mod = begin_mock_module_
          mod.expect_to_have_method_defined :should
          mod
        end

        def toplevel_module_
          toplevel_module_with_rspec_not_loaded_
        end
      end
    end

    # ==
  end
end
# #born: years later
