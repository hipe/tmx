module Skylab::TestSupport

  class Expect  # see [#029] the expect omnibus and narrative #intro-to-gamma

    # ~ three laws for real ~

    module InstanceMethods
    private

      def expect * x_a, & p
        exp = build_expectation_from_x_a_and_p x_a, p
        exp.assert_under self
      end

      def build_expectation_from_x_a_and_p x_a, p
        expectation_class.new x_a, p
      end

      def expectation_class
        String_Oriented_Expectation_
      end
    public
      def shift_emission
        baked_em_a.shift
      end
      def baked_em_a
        @baked_em_a ||= build_baked_em_a
      end
      def when_no_emission exp
        fail "expected an emission on the '#{ exp.channel_i }' channel"
      end
      def expect_no_more_emissions
        baked_em_a.length.zero? or when_unexpected_emission
      end
      def when_unexpected_emission
        fail say_unexpected_emission
      end
      def say_unexpected_emission
        em = @baked_em_a.first
        "unexpected '#{ em.channel_i }' emission: #{ em.payload_x.inspect }"
      end
      def expect_channel_for_emission chan_x, em
        em.channel_i.should eql chan_x
      end
      def match_with_string exp_s, em
        em.payload_x.should eql exp_s
      end
      def match_with_regex exp_rx, em
        em.payload_x.should match exp_rx
      end
    end

    Expectation_ = self
    class Expectation_

      def initialize x_a, p
        @p = p ; @x_a = x_a
        absrb_iambic_fully
      end
    private
      def absrb_iambic_fully
        absrb_keywords
        @x_a.length.nonzero? and absrb_based_on_shape
        @p and absorb_the_proc
        @x_a.length.nonzero? and when_unparsed_x_a
      end
      def absrb_keywords
        p = self.class.prefix_map_proc
        while @x_a.length.nonzero? and (( m_i = p[ @x_a.first ] ))
          @x_a.shift ; send m_i
        end ; nil
      end
      class << self
        def prefix_map_proc
          @prefix_map_proc ||= curry_suffix_map( :_prefix_keyword= )
        end
      private
        def curry_suffix_map suffix_i
          -> prefix_i do
            if prefix_i.respond_to? :id2name
              m_i = :"#{ prefix_i }#{ suffix_i }"
              private_method_defined?( m_i ) and m_i
            end
          end
        end
      end
      def absrb_based_on_shape
        if @x_a.first.respond_to? :named_captures
          absorb_regex @x_a.shift
        elsif @x_a.first.respond_to? :ascii_only?
          absorb_string @x_a.shift
        end ; nil
      end
      def when_unparsed_x_a
        raise ::ArgumentError, "unexpected argument: #{ @x_a.first }"
      end
    public
      def assert_under ctx
        @context = ctx
        @emission = ctx.shift_emission
        @emission ? when_emission : @context.when_no_emission( self )
      end
    end

    class String_Oriented_Expectation_ < Expectation_
      def initialize a, p
        @channel_i = nil
        @expect_is_styled = false
        @pattern_method = nil
        super a, p
      end
      attr_reader :channel_i, :expect_is_styled, :pattern_method, :pattern_x
    private
      def styled_prefix_keyword=
        @expect_is_styled = true
      end
      def out_prefix_keyword=
        @channel_i = :out
      end
      def err_prefix_keyword=
        @channel_i = :err
      end
      def absorb_regex rx
        @pattern_method = :match_with_regex
        @pattern_x = rx ; nil
      end
      def absorb_string str
        @pattern_method = :match_with_string
        @pattern_x = str ; nil
      end
      def when_emission
        expect_any_channel
        expect_any_content
      end
      def expect_any_channel
        if @channel_i
          @context.expect_channel_for_emission @channel_i, @emission
        end
      end
      def expect_any_content
        if @pattern_method
          @context.send @pattern_method, @pattern_x, @emission
        end
      end
    end
  end
end
