require_relative 'test-support'

module Skylab::Basic::TestSupport::Pathname::N11n

  Parent_ = ::Skylab::Basic::TestSupport::Pathname

  Parent_[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  describe "[ba] pathname normalization" do

    TestLib_::Expect_event[ self ]

    TestLib_::Expect_normalization[ self ]

    extend TS_

    it "loads" do
      subject
    end

    it "builds" do
      norm = subject :absolute
      norm.instance_variable_get( :@relative_is_OK ).should eql false
    end

    context "the empty normalizer" do

      before :all do
        Empty = Subject_[].build_via_iambic Basic_::EMPTY_A_
      end

      it "against nil does nothing - checking required-ness is outside of scope" do
        use_event_proc_against nil
        expect_nothing
      end

      it "against false results in false - this is your problem not ours" do
        use_event_proc_against false
        output_value_was_not_written
        event_proc_was_not_called
        @result_x.should eql false
      end

      it 'against the empty string - "your value cannot be empty" (ever)' do
        use_event_receiver_against Basic_::EMPTY_S_
        output_value_was_not_written
        @result_x.should eql false
        expect_event :path_cannot_be_empty,
          '(par «your_value») cannot be empty - (ick "")'
        expect_no_more_events
      end

      it "against the root path - OK" do
        expect_the_passthru_normalization_with '/'
      end

      it "against the pwd dot - OK" do
        expect_the_passthru_normalization_with '.'
      end

      it "against dot dot - OK" do
        expect_the_passthru_normalization_with '..'
      end

      it "BUT two contiguous separators with nothing between them - NO" do
        use_event_receiver_against '//'
        expect_errored_with :path_cannot_contain_repeated_separators,
          '(par «your_value») cannot contain repeated separators - (ick "//")'
      end

      it "against a normal, single-term absolute path - OK" do
        expect_the_passthru_normalization_with '/foo'
      end

      it "against a single-term abspath with a trailing slash - OK" do
        expect_the_passthru_normalization_with '/foo/'
      end

      def subject
        Empty
      end
    end

    context "the relative normalizer" do

      before :all do
        Rel = Subject_[].build_with :relative
      end

      it "an abspath - NO" do
        use_event_receiver_against '/'
        expect_errored_with :path_cannot_be_absolute,
          '(par «your_value») cannot be absolute - (ick "/")'
      end

      it "a relpath - YES" do
        expect_the_passthru_normalization_with 'A'
      end

      def subject
        Rel
      end
    end

    context "the absolute normalizer" do

      before :all do
        Abs = Subject_[].build_with :absolute
      end

      it "an abspath - YES" do
        expect_the_passthru_normalization_with '/'
      end

      it "a relpath - NO" do
        use_event_receiver_against ' '
        expect_errored_with :path_cannot_be_relative,
          '(par «your_value») cannot be relative - (ick " ")'
      end

      def subject
        Abs
      end
    end

    context "downward only" do

      before :all do
        Downward_Only = Subject_[].build_with :downward_only
      end

      it "loads" do
      end

      it "no" do
        use_event_receiver_against '..'
        expect_errored_with :path_cannot_contain_dot_dot,
          '(par «your_value») cannot contain dot dot - (ick "..")'
      end

      it "yes" do
        expect_the_passthru_normalization_with '...'
      end

      def subject
        Downward_Only
      end
    end

    context "no single dots" do

      before :all do
        No_Single_Dots = Subject_[].build_with :no_single_dots
      end

      it "loads" do
      end

      it "in the middle - no" do
        use_event_receiver_against 'a/./c'
        expect_errored_with :path_cannot_contain_single_dot,
          '(par «your_value») cannot contain single dot - (ick "a/./c")'
      end

      it "but same with dot dot is ok" do
        expect_the_passthru_normalization_with 'a/../c'
      end

      def subject
        No_Single_Dots
      end
    end

    context "no dotfiles" do

      before :all do
        No_Dotfiles = Subject_[].build_with :no_dotfiles
      end

      it "loads" do
      end

      it "no" do
        use_event_receiver_against '...'
        expect_errored_with :path_cannot_contain_dot_file,
          '(par «your_value») cannot contain dot file - (ick "...")'
      end

      it "yes LOOK" do
        expect_the_passthru_normalization_with './*'
      end

      def subject
        No_Dotfiles
      end
    end

    def expect_the_passthru_normalization_with s
      use_event_proc_against s
      expect_the_passthru_normalization
    end

    def expect_errored_with * a, & p
      output_value_was_not_written
      @result_x.should eql false
      expect_not_OK_event( * a, & p )
    end

    def subject * x_a
      if x_a.length.zero?
        Subject_[]
      else
        Subject_[].build_via_iambic x_a
      end
    end

    Subject_ = -> do
      Basic_::Pathname.normalization
    end
  end
end
