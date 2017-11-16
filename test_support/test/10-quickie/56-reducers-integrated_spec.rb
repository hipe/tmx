require_relative '../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] quickie - reducers integrated" do

    TS_[ self ]
    use :memoizer_methods
    use :want_emission_fail_early
    use :quickie

    same_describe_for = -> ran_these, mod do

      mod.describe do

        extend TS_::Quickie::Indicated_Line_Ranges::TheseModuleMethods

        _hack_next_line_number 10

        it "eg0" do
          ran_these.push :eg_0_ran
        end

        context "flower", plant: true do

          _hack_next_line_number 20

          it "eg1" do
            ran_these.push :eg_1_ran
          end

          _hack_next_line_number 30

          it "eg2" do
            ran_these.push :eg_2_ran
          end

          context "orchid" do

            _hack_next_line_number 40

            it "eg3", no_see: true do
              ran_these.push :eg_3_ran
            end

            _hack_next_line_number 50

            it "eg4", werp: true do
              ran_these.push :eg_4_ran
            end

            _hack_next_line_number 70

            it "eg5" do
              ran_these.push :eg_5_ran
            end

            _hack_next_line_number 90

            it "eg6"  # <- PENDED EXAMPLE

            _hack_next_line_number 100

            it "eg7" do
              ran_these.push :eg_7_ran
            end
          end
        end
      end
    end

    same_tests_for = -> a, real_ctx do
      -> rt do
        _mod = real_ctx.enhanced_module_via_runtime_ rt
        same_describe_for[ a, _mod ]
      end
    end

    it "big money" do

      # -

        ran_these = []

        call(
          :load_tests_by, same_tests_for[ ran_these, self ],
          :tag, :plant,
          :tag, '~werp',
          :line, 10,
          :line, 30,
          :from, 40, :to, 90,
        )

        want_example_ %w( flower eg2 )
        want_example_ %w( flower orchid eg3 )
        want_example_ %w( flower orchid eg5 )

        _statistics = execute
        _state = [ ran_these, _statistics ]

      # -
      _ran_these = _state.first
      _ran_these == [ :eg_2_ran, :eg_3_ran, :eg_5_ran ] || fail
      _state.last.example_count == 3 || fail
    end

    # ==

    def toplevel_module_
      toplevel_module_with_rspec_not_loaded_
    end

    def kernel_module_
      kernel_module_with_rspec_not_loaded_
    end

    # ==
  end
end
# #born years later
