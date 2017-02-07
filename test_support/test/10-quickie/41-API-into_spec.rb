require_relative '../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] quickie - API" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_emission_fail_early
    use :quickie

    it "call with strange primary - raises key error" do
      call :za_zoom
      begin
        expect_result :_no_see_ts_
      rescue ::KeyError => e
      end
      e.message == "key not found: :za_zoom" || fail
    end

    it "call without the required primary" do
      call
      expect :error, :expression, :missing_requireds do |y|
        y == [ "missing required argument(s): (load_tests_by)" ] || fail
      end
      expect_API_result_for_fail_
    end

    context "look at this variety of emissions and results that we get.." do

      it "the events are emitted as expected" do
        _state || fail
      end

      it "the examples were executed in the expected order" do
        _state.last == [ :eg_1_ran, :eg_2_ran ] || fail
      end

      it "stats look good" do
        stats = _state.first
        stats.example_count == 2 || fail
        stats.example_failed_count == 1 || fail
      end

      shared_subject :_state do

        a = []

        call :load_tests_by, -> rt do

          _mod = enhanced_module_via_runtime_ rt
          _mod.describe do

            context "c 1" do

              it "eg 1" do
                a.push :eg_1_ran
                1.should_ eql 1
              end
            end

            it "eg 2" do
              a.push :eg_2_ran
              1.should_ eql 2
            end
          end
        end

        expect :data, :example do |eg|
          eg.passed || fail
          eg.description_stack == [ "c 1", "eg 1" ] || fail
        end

        expect :data, :example do |eg|
          eg.passed && fail
          eg.description_stack == [ "eg 2" ] || fail
        end

        _statistics = execute

        [ _statistics, a ]
      end
    end

    it "(more complex test structure, to cover branch depth drop)" do

      call :load_tests_by, -> rt do

        _mod = enhanced_module_via_runtime_ rt
        _mod.describe do
          context "c1" do
            context "c2" do
              context "c3" do
                it "eg1" do
                end
              end
            end
            context "c4" do
              it "eg2" do
              end
            end
          end
        end
      end
      _expect %w( c1 c2 c3 eg1 )
      _expect %w( c1 c4 eg2 )
      _stats = execute
      _stats.example_count == 2 || fail
    end

    # ==

    it "(what about if multiple `describe` blocks are sent?)" do

      call :load_tests_by, -> rt do

        _mod1 = enhanced_module_via_runtime_ rt
        _mod1.describe do
          context "c1" do
            context "c2" do
              it "eg1" do
              end
            end
          end
        end

        _mod2 = enhanced_module_via_runtime_ rt
        _mod2.describe do
          context "c3" do
            it "eg2" do
            end
            context "c4" do
              it "eg3" do
              end
            end
            it "eg4" do
            end
          end
          context "c5" do
            it "eg5" do
            end
            it "eg6" do
            end
          end
          it "eg7" do
          end
        end
      end

      _expect %w( c1 c2 eg1 )
      _expect %w( c3 eg2 )
      _expect %w( c3 c4 eg3 )
      _expect %w( c3 eg4 )
      _expect %w( c5 eg5 )
      _expect %w( c5 eg6 )
      _expect %w( eg7 )

      _stats = execute
      _stats.example_count == 7 || fail
    end

    alias_method :_expect, :expect_example_

    # ==

    def toplevel_module_
      toplevel_module_with_rspec_not_loaded_
    end

    def kernel_module_
      kernel_module_with_rspec_not_loaded_
    end

    # ==

    def expression_agent
      Home_::THE_EMPTY_EXPRESSION_AGENT
    end
  end
end
# #born
