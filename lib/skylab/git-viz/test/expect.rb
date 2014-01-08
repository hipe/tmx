module Skylab::GitViz

  module TestSupport

    module Expect

      def self.[] user_mod
        user_mod.send :include, Instance_Methods__ ; nil
      end

      Headless = GitViz::Headless

      module Instance_Methods__

        def expect_emissions_on_channel i
          @default_channel_i = i ; nil
        end

        attr_reader :default_channel_i

        def expect * x_a, &p
          ::Array.try_convert( x_a.first ) and x_a.unshift :on_channel_i_a
          @expectation = Expectation__.new x_a, p
          @em = shift_some_emission
          if @expectation.on_channel_i
            expct_channel_i
          elsif @expectation.on_channel_i_a
            expct_channel_i_a
          elsif (( i = default_channel_i ))
            @em.stream_name.should eql i
          end
          @matchee_x = @em.payload_x
          @expectation.is_styled and expct_styled_and_unstyle
          m_i = @expectation.any_matcher_method_name and send m_i
          p = @expectation.any_finally_proc and expct_finally_proc
        end

        def shift_any_emission
          baked_em_a.length.nonzero? and @baked_em_a.shift
        end

        def shift_some_emission
          baked_em_a.shift or fail "expected emission, had none."
        end

        def expct_channel_i
          @em.stream_name.should eql @expectation.on_channel_i ; nil
        end

        def expct_channel_i_a
          @em.channel_i_a.should eql @expectation.on_channel_i_a ; nil
        end

        def expct_styled_and_unstyle
          s = Headless::CLI::Pen::FUN::Unstyle_styled[ @matchee_x ]
          s or fail "expected styled, was not: #{ @matchee_x }"
          @matchee_x = s ; nil
        end

        def expct_finally_proc
          send FINALLY_PROC_ARITY_H__.fetch @expectation.any_finally_proc.arity
        end

        FINALLY_PROC_ARITY_H__ = {
          0 => :expct_finally_proc_when_arity_is_zero,
          1 => :expct_finally_proc_when_arity_is_one }.freeze

        def expct_finally_proc_when_arity_is_zero
          @expectation.any_finally_proc[]
        end

        def expct_finally_proc_when_arity_is_one
          @expectation.any_finally_proc[ @em ]
        end

        def expect_match_with_rx
          @md = @expectation.matcher_x.match @matchee_x
          @md or fail  "expected #{ @expectation.matcher_x.inspect }, #{
            }had #{ @matchee_x.inspect }" ; nil
        end

        def expect_match_with_str
          @matchee_x.should eql @expectation.matcher_x
        end

        def expect_failed
          expect_no_more_emissions
          expect_result_for_failure  # :+#hook-out
        end

        def expect_no_more_emissions
          baked_em_a.length.zero? or fail say_expected_no_more_emissions
        end

        def say_expected_no_more_emissions
          em = @baked_em_a.first
          "expected no more emissions, had: #{ inspect_emission_object em }"
        end

        def inspect_emission_object em
          inspect_emission_channel_and_payload em.channel_x, em.payload_x
        end

        def inspect_emission_channel_and_payload channel_x, payload_x
          "#{ channel_x.inspect }: #{ Inspect[ payload_x ] }"
        end
      end

      class Expectation__

        Headless::API::Simple_monadic_iambic_writers[ self,
          :on_channel_i, :on_channel_i_a ]

        attr_reader :any_finally_proc, :any_matcher_method_name,
          :is_styled, :matcher_x,
          :on_channel_i, :on_channel_i_a

        def initialize x_a, p
          absorb_iambic_passively x_a
          absrb_any_matcher
          @any_finally_proc = p ; nil
        end
      private
        def styled=
          @is_styled = true ; nil
        end
        def absrb_any_matcher
          @x_a.length.zero? or absrb_some_matcher
        end
        def absrb_some_matcher
          @matcher_x = @x_a.shift
          @x_a.length.zero? or raise ::ArgumentError, "unexpected iambic: #{
            }#{ Inspect[ @x_a.first ] }"
          if @matcher_x.respond_to? :named_captures
            @any_matcher_method_name = :expect_match_with_rx
          elsif @matcher_x.respond_to? :ascii_only?
            @any_matcher_method_name = :expect_match_with_str
          else
            raise ::ArgumentError, "expected some matcher, had #{
              Inspect[ @matcher_x ] }"
          end
        end
      end

      Inspect = -> x do
        Headless::Services::Basic::FUN::Inspect__[ 120, x ]
      end
    end
  end
end
