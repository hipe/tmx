require_relative '../../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] auxiliaries - function - failures" do

    TS_[ self ]
    use :my_API

    memoize( :_ruby_regexp ) { /wazoo/i }

    _replacement_expression = '{{ $0.downcase.well_well_well.nope }}'

    _filename_pattern = '*-line*.txt'

    context "you have a strange function and no function directory" do

      call_by do
        _call_with_directory nil
      end

      it "fails" do
        fails
      end

      it "events" do

        _be_this = be_emission_ending_with :functions_directory_required do |y|

          _a = [ "a `functions_directory` must be indicated #{
           }to help define #{
             }(code :well_well_well) and (code :nope)" ]

          expect( y ).to eql _a
        end

        expect( last_emission ).to _be_this
      end

      def expression_agent_for_want_emission
        Common_::Event.codifying_expression_agent_instance
      end
    end

    context "if you have an existent directory but no file" do

      call_by do

        _dir = TestSupport_::Fixtures.directory :empty_esque_directory
        _call_with_directory _dir
      end

      it "fails" do
        fails
      end

      it "events" do
        msg = nil

        _be_this = be_emission_ending_with :missing_function_definitions do |ev|
          msg = black_and_white ev
        end

        expect( last_emission ).to _be_this

        expect( msg ).to match(
          %r('well_well_well' and 'nope' are missing the expected files «.+#{
              }well-well-well\.rb, nope\.rb\}»\z) )
      end
    end

    define_method :_call_with_directory do |dir|

      call(
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
