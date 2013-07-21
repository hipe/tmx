module Skylab::PubSub::TestSupport
  # (our anchor module is this one so h.l is visible)

  module Event
    module Predicate
    end # (monoadic semantic namespace)
  end

  class Event::Predicate::Nub

    # this is a 'courtesy' class used by other libraries, not this one.
    #
    # Emigrated from porcelain, this is the test-framework-agnostic core
    # (or "nub") for e.g an ::Rspec custom matcher. A few lines of wiring
    # would be necessary to adapt it to e.g ::RSpec to make it a custom
    # matcher there, hence it is just a "nub" and not a full-out custom
    # matcher (which is done intentionally so as to not couple our core
    # (and perhaps overwrought) logic too tightly to one external testing f.w).
    #
    # This 'Nub' is a "type DSL" - it is based around the premise that the
    # same things we *always* test about a list of events can be expressed
    # most tersely and readably by using a list of values each of which has
    # a class among ::Fixnum, ::NilClass, ::String, ::Symbol, ::Regexp
    # (yes, we throw the duck out the window).
    #
    # (this whole idea is probably riffing off of the syntax for rspec's
    # `raise_error` matcher, which takes a number of different kinds of
    # arguments, asserting different kinds of expectations.)
    #
    # For example, if a certain event should have a text representation
    # equal to a certain string, ::String is used for that. If its text
    # representation should match a certain regexp, that is the use
    # ::Regexp serves. (::Symbol represents the expected stream name of
    # an event. ::Fixnum indicates the offset of the event we are talking
    # about. ::NilClass is used to indicate that this event we are referring
    # to, we expect it to be the last event in the list of events).
    #
    # In theory, the core lifecycle of one such nub should consist of:
    #
    #   1. construct a nub object with 1 argument: an array of primitive types
    #   where each element is one of the 5 classes above.
    #
    #   2. call `match` on the nub object, passing that an array of actual
    #   PubSub event-looking objects. It will result in trueish or falseish,
    #   based on whether the expected did or did not match the actual,
    #   respectively. (Note the two arrays, expected vs. actual, are *not*
    #   parallel in any way. It is just coincidence that they are both
    #   arrays.)
    #
    #   [3.] IFF the above was false you can call `failure_message_for_should`
    #   and it will give you a lingual-ly clever string explaining the failure.
    #
    #   [4] You should be able to call `descrption` any time after `match`
    #   and it will describe the whole criteria, again being linguistically
    #   clever.

    #         ~ for wiring it to an ::Rspec custom matcher ~

    # (these are expected to be called in the order MATCH [FAIL_MSG] DESC)
    # (`handle_match`, `handle_failure_message_for_should`, handle_description)


    [ :match, :failure_message_for_should, :description ].each do |stem|
      ivar = "@handle_#{ stem }"
      define_method "handle_#{ stem }" do
        if instance_variable_defined? ivar
          instance_variable_get ivar
        else
          instance_variable_set ivar, method( stem )
        end
      end
    end

    #         ~ implementation of the 3 core hooks ~

    # (it is a terse, expressive, and hacky syntax that is most simply
    # implemented by throwing the duck out the window)

    def match actual_a
      @actual_a = actual_a
      if actual_a.length.zero?
        @actual_index = false  # don't confuse the meaning of -1
      else
        @actual_index = actual_a.length - 1  # the last item in queue is default
      end
      @expect_a.each_with_index do |x, idx|
        send "#{ x.class.name.downcase }_subpredicate", x, idx
        @do_continue or break
      end
      if ! @index_specified && ! @did_complain_about_no_event &&
          1 != @actual_a.length then
        subfail_about_missing_element 0
      end
      ! @fail_a  # you passed iff it was not set.
    end

    def failure_message_for_should
      @fail_a.join '. '  # ballsy
    end

    # this appears to be a predicate (as in parts of speech) - a verb phrase.

    -> do


      desc_h_h = {
        pos:  IDENTITY_,
        type: IDENTITY_,
        msg:  IDENTITY_
      }.freeze

      define_method :description do
        if @desc_h.length.zero?
          'nothing'
        else
          use_h = @desc_h.reduce( { } ) do |h, (k, v)|
            h[k] = desc_h_h.fetch( k )[ v ]
            h
          end
          'emit{{pos}}{{type}}{{msg}}'.gsub PubSub::Basic::String::MUSTACHE_RX do
            b = true
            x = use_h.fetch( $1.intern ) do b = false end  # catch metaerrors
            " #{ x }" if b
          end
        end
      end
    end.call

    def unstylize_all_stylized!  # courtesy
      @do_unstylize_all_stylized = true
    end

    attr_writer :textify  # how do you want to convert your events to text?

  private

    def initialize expected
      @actual_index = nil
      @expect_a = expected
      @fail_a = nil
      @index_specified = nil
      @desc_h = { }
      @do_continue = true  # (use it to short-circuit processing expect_a)
      @did_complain_about_no_event = nil
      @do_unstylize_all_stylized = nil
      @textify = -> x { x.text }
    end

    #         ~ the particular subpredicates ~

    -> do
      num2ord = Headless::NLP::EN::Number::FUN.num2ord

      define_method :fixnum_subpredicate do |x, idx|
        if -1 == x
          ord = 'last'
          @actual_index = @actual_a.length - 1
        else
          ord = num2ord[ x + 1 ]
          @actual_index = x
        end
        x = nil
        subdesc :pos, '%-6s' % ord
        @index_specified = true
        # ok - kinda bumpy: if there are any as-yet unprocessed *trueish*
        # nerks in the expected queue *and* the explicitly stated index
        # is off the end of the actual array, it is an error (because
        # future nerks will be trying to derk the berks).
        if @actual_a.length <= @actual_index && @expect_a[ idx + 1 ]
          subfail "expecting event at index #{ @actual_index }, #{
            }had #{ @actual_a.length } events"
          @do_continue = false
        end
        nil
      end
    end.call

    # NOTE - experimental syntax
    #
    # what does nil mean? the mnemonic is "i expect a nil value from the
    # actual event array at the last explicitly stated index (expressed
    # with a ::Fixnum). It is _the_ way to assert the expected exact
    # number of events in the actual list. Using `nil` without an explicitly
    # stated index before it is undefined.
    #
    # So, an expectation array of [0, nil] says "the value of the event
    # array at index 0 should be nil (hence the array should be empty.
    # there should be no events). Since the index that is implied is the
    # last valid index of the queue (i.e length - 1), an arguably poor way
    # to state something might be: [ :foo, 1, nil ], which effectively states
    # "the last event should be of `stream_name` :foo, and oh by the way,
    # since at index 1 we expect `nil`, it means that there should only be
    # one event in the queue."  #experimental
    #
    # (what would of course be nice is that an expectation array of [nil]
    # represent the expectation for a zero-length actual array.)

    def nilclass_subpredicate( x, * )
      subdesc :type, "no more events."
      if @actual_index != @actual_a.length
        s = 's' if 1 != expected_index
        subfail "expected exactly #{ expected_index } event#{ s }, #{
          }had #{ @actual_a.length }"
      end
    end

    def regexp_subpredicate( x, * )
      with_event do |e|
        txt = get_matchable_text e
        if x =~ txt
          subdesc :msg, txt.inspect
        else
          subdesc :msg, x
          subfail "expected text to match #{ x.inspect }, #{
            }had #{ txt.inspect }"
        end
      end
      nil
    end

    def string_subpredicate( x, * )
      with_event do |e|
        subdesc :msg, x.inspect
        txt = get_matchable_text e
        if x != txt
          subfail "expected text #{ x.inspect }, #{
            }had #{ txt.inspect }"
        end
      end
      nil
    end

    def symbol_subpredicate( x, * )
      with_event do |e|
        subdesc :type, x.inspect
        if x != e.stream_name
          subfail "expected stream_name #{ x.inspect }, #{
            }had #{ e.stream_name.inspect }"
        end
      end
      nil
    end

    #         ~ support the particular subpredicates ~

    def with_event &blk
      if @did_complain_about_no_event then false else
        if false == @actual_index  # then we would have dfltd to -1 which..
          expected_index = 0
        else
          expected_index = @actual_index
        end
        if expected_index < @actual_a.length
          x = @actual_a[ expected_index ]
          blk ? blk[ x ] : x
        else
          @did_complain_about_no_event = true
          subfail_about_missing_element expected_index
          false
        end
      end
    end

    def subfail_about_missing_element expected_index
      s = 's' if expected_index.nonzero?
      subfail "expected #{ expected_index + 1 } event#{ s }, #{
        }had #{ @actual_a.length }"
      nil
    end

    def subdesc k, v
      @desc_h.key?( k ) and fail "primitive type mutex - #{ k }"
      @desc_h[k] = v
      nil
    end

    def subfail msg
      ( @fail_a ||= [ ] ) << msg
      nil
    end

    -> do

      unstylize = Headless::CLI::Pen::FUN.unstylize

      define_method :get_matchable_text do |e|
        txt = @textify[ e ]
        if @do_unstylize_all_stylized
          txt = unstylize[ txt ]
        end
        txt
      end
    end.call
  end
end
