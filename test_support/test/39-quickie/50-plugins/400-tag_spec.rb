require_relative '../../test-support'

module Skylab::TestSupport::TestSupport

_SUPREME_HACK = -> do

  describe "[ts] quickie - plugins - tag - OMG DOUBLE LOADING OF SAME FILE" do

    # REMINDER: this is not the main file for testing tags. this is for
    # testing the recursive runner's integration with tags. to regress on
    # tags themselves, use the dedicated test files for tags in the "onefile"
    # distribution.

    TS_[ self ]
    use :quickie_plugins

    # NOTE when you add examples, increment the variable that counts them YEEYAHH

    eek = __FILE__

      # - API

        it "will see this one because of its tag (apple)", find_me: true, tempurature: :cold do

          call :tag, "find_me", :doc_only, :path, eek
          _want_only_these_examples "(apple)"
        end

        it "won't see this one because of its tag (grape)", avoid_me: true, tempurature: :hot do

          call :tag, "~avoid_me", :doc_only, :path, eek
          _want_examples_do_not_contain "(grape)"
        end

        it "some specific value of some tag (pear)", tempurature: :cold do
          call :tag, "tempurature:cold", :doc_only, :path, eek
          _want_only_these_examples "(apple)", "(pear)"
        end

      # -
    # ==

    number_of_examples = 3

    define_method :_want_examples_do_not_contain do |*black_s_a|

      _want_number = number_of_examples - black_s_a.length

      _want_number.times do

        want :data, :example do |eg|

          actual_s = eg.description_stack.last
          black_s_a.each do |black_s|
            if actual_s.include? black_s
              fail "was expecting not to see: #{ actual_s.inspect }"
            end
          end
        end
      end

      want :info, :expression, :number_of_files

      want_succeed
    end

    # ==

    def _want_only_these_examples * pool_s_a

      pool_s_a.length.times do

        want :data, :example do |eg|

          actual_s = eg.description_stack.last
          idx = pool_s_a.length.times.detect do |d|
            actual_s.include? pool_s_a.fetch d
          end
          idx or fail "expecting #{ pool_s_a * ' or ' } in #{ actual_s.inspect }"
          pool_s_a[ idx, 1 ] = EMPTY_A_  # eek
        end
      end

      want :info, :expression, :number_of_files

      want_succeed

      pool_s_a.length.nonzero? and fail "never found #{ pool_s_a * ' and ' }"
    end

    # ==

    # _SUPREME_HACK TL;DR: we use these tests as the tests that are tested
    # against in these tests.
    #
    # assume we are in a test in this file. we can thereby assume that this
    # file has been loaded once. what we want is (in effect) to load this
    # selfsame file again but against our test conditions (specifically,
    # certain tags being employed or not employed).
    #
    # now, before you say "false requirement", consider that on its face
    # such a stunt is theoretically almost possible:
    #
    # almost all our test files (certainly this one) share a similar
    # structure: they begin with a single call to `require`, then they (re-)
    # open the sidesystem-specific "test support" module, then they send
    # `describe` to this module, passing it a (typically large) block
    # element (that contains all the contexts and/or examples). test files
    # that follow this structure probably number in the hundreds.
    #
    # of those those three structural elements, the first two are safely
    # re-entrant: you can safely require the same path twice; you can safely
    # open the same module twice.
    #
    # but we hit a bit of a wall when it comes to the call to `describe`.
    # the "grand bargain" of quickie (rspec too) is that since the receiver
    # of such a call is a "common household object" like a `::Module` or
    # `main`, for such a call to do anything useful it must have been
    # "hacked" beforehand to reach out to some universal singleton object
    # (almost like a global) to reach its vendor-specific implementation.
    # now, ironically or not such singleton objects are the bane of testing
    # (and arguably of good software design). (what would be better is if
    # you could decide the execution context of a file when you load it, but
    # in this platform you can't). :[#006.C].
    #
    # anyway, rather than slather a hack on top of a hack to "intercept"
    # this would-be second call to the same `describe` method, we hack things
    # at a lower level to make the plugin think it is loading this selfsame
    # file when actually we [see].
    #
    # oh also we make use of our `doc_only` flag so we don't actually run
    # any tests the second time. it's horrible, but it's not quite as bad
    # as no test at all.

    define_method :prepare_subject_API_invocation do |invo|

      runtime = nil
      runtime_once = -> do
        runtime = build_fresh_dummy_runtime_
        runtime_once = nil  # assert implicitly
        runtime
      end

      pi = hack_that_one_plugin_of_invocation_to_use_this_runtime_ invo do
        runtime_once[]
      end

      path_loaded_once = -> path do
        path_loaded_once = nil  # assert implicitly

        eek == path || TS_._SANITY

        # #coverpoint2.5: we won't see the description of the root element
        # (the describe) because that's how it is with the tree roots..

        _describer = TS_::Quickie::Plugins::DescribeProxy.new do |p, s_a|
          _hi = runtime.dereference_quickie_service_._receive_describe p, s_a
          _hi.nil? || fail
        end

        _hi = _describer.instance_exec( & _SUPREME_HACK )
        _hi == :_hello_self_ || fail
      end

      pi.send :define_singleton_method, :load do |path|
        path_loaded_once[ path ]
      end

      super invo
    end

    # ==
  end
  :_hello_self_
end  # # _SUPREME_HACK
_SUPREME_HACK.call

end
# #born years later
