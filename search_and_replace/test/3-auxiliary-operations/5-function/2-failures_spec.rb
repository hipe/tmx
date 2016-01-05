require_relative '../../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] auxiliaries - function - (2) failures" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event
    use :operations

    memoize( :_ruby_regexp ) { /wazoo/i }

    _replacement_expression = '{{ $0.downcase.well_well_well.nope }}'

    _filename_pattern = '*-line*.txt'

    context "you have a strange function and no function directory" do

      shared_subject :state_ do
        _call_with_directory nil
        flush_event_log_and_result_to_state @result
      end

      it "fails" do
        fails_
      end

      it "events" do

        _be_this = be_emission_ending_with :functions_directory_required do |y|

          _a = [ "a `functions_directory` must be indicated #{
           }to help define #{
             }(code :well_well_well) and (code :nope)" ]

          y.should eql _a
        end

        last_emission.should _be_this
      end
    end

    context "if you have an existent directory but no file" do

      shared_subject :state_ do

        _dir = TestSupport_::Fixtures.dir :empty_esque_directory
        _call_with_directory _dir
        flush_event_log_and_result_to_state @result
      end

      it "fails" do
        fails_
      end

      it "events" do
        msg = nil

        _be_this = be_emission_ending_with :missing_function_definitions do |ev|
          msg = black_and_white ev
        end

        last_emission.should _be_this

        msg.should match(
          %r('well_well_well' and 'nope' are missing the expected files «.+#{
              }well-well-well\.rb, nope\.rb\}»\z) )
      end
    end

    define_method :_call_with_directory do |dir|

      call_(
        :ruby_regexp, _ruby_regexp,
        :path, common_haystack_directory_,
        :filename_pattern, _filename_pattern,
        :search,
        :replacement_expression, _replacement_expression,
        :functions_directory, dir,
        :replace,
      )
    end
  end
end
