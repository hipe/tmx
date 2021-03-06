require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] pathname normalization" do

    TS_[ self ]
    use :memoizer_methods
    use :want_event
    use :want_normalization

    it "loads" do
      _subject_module
    end

    it "builds" do
      _norm = _new_subject :absolute
      expect( _norm.instance_variable_get( :@relative_is_OK ) ).to eql false
    end

    context "the empty normalizer" do

      shared_subject :subject_normalization_ do
        _subject_module.via_iambic Home_::EMPTY_A_
      end

      it "against nil does nothing - checking required-ness is outside of scope" do
        normalize_against_ nil
        want_nothing_
      end

      it "against false results in false - this is your problem not ours" do

        normalize_against_ false
        want_output_value_was_not_written_
        want_no_events
        expect( @result_x ).to eql false
      end

      it 'against the empty string - "your value cannot be empty" (ever)' do

        normalize_against_ Home_::EMPTY_S_
        want_output_value_was_not_written_
        expect( @result_x ).to eql false
        want_not_OK_event_ :path_cannot_be_empty,
          '(par «your_value») cannot be empty - (ick "")'
        want_no_more_events
      end

      it "against the root path - OK" do
        _want_the_passthru_normalization_with '/'
      end

      it "against the pwd dot - OK" do
        _want_the_passthru_normalization_with '.'
      end

      it "against dot dot - OK" do
        _want_the_passthru_normalization_with '..'
      end

      it "BUT two contiguous separators with nothing between them - NO" do

        normalize_against_ '//'
        want_errored_with_ :path_cannot_contain_repeated_separators,
          '(par «your_value») cannot contain repeated separators - (ick "//")'
      end

      it "against a normal, single-term absolute path - OK" do
        _want_the_passthru_normalization_with '/foo'
      end

      it "against a single-term abspath with a trailing slash - OK" do
        _want_the_passthru_normalization_with '/foo/'
      end
    end

    context "the relative normalizer" do

      shared_subject :subject_normalization_ do
        X_p_n_Rel = _new_subject :relative
      end

      it "an abspath - NO" do
        normalize_against_ '/'
        want_errored_with_ :path_cannot_be_absolute,
          '(par «your_value») cannot be absolute - (ick "/")'
      end

      it "a relpath - YES" do
        _want_the_passthru_normalization_with 'A'
      end
    end

    context "the absolute normalizer" do

      shared_subject :subject_normalization_ do
        X_p_n_Abs = _new_subject :absolute
      end

      it "an abspath - YES" do
        _want_the_passthru_normalization_with '/'
      end

      it "a relpath - NO" do
        normalize_against_ ' '
        want_errored_with_ :path_cannot_be_relative,
          '(par «your_value») cannot be relative - (ick " ")'
      end
    end

    context "downward only" do

      shared_subject :subject_normalization_ do
        X_p_n_Downward_Only = _new_subject :downward_only
      end

      it "loads" do
        subject_normalization_
      end

      it "no" do
        normalize_against_ '..'
        want_errored_with_ :path_cannot_contain_dot_dot,
          '(par «your_value») cannot contain dot dot - (ick "..")'
      end

      it "yes" do
        _want_the_passthru_normalization_with '...'
      end
    end

    context "no single dots" do

      shared_subject :subject_normalization_ do
        X_p_n_No_Single_Dots = _new_subject :no_single_dots
      end

      it "loads" do
        subject_normalization_
      end

      it "in the middle - no" do
        normalize_against_ 'a/./c'
        want_errored_with_ :path_cannot_contain_single_dot,
          '(par «your_value») cannot contain single dot - (ick "a/./c")'
      end

      it "but same with dot dot is ok" do
        _want_the_passthru_normalization_with 'a/../c'
      end
    end

    context "no dotfiles" do

      shared_subject :subject_normalization_ do
        X_p_n_No_Dotfiles = _new_subject :no_dotfiles
      end

      it "loads" do
        subject_normalization_
      end

      it "no" do
        normalize_against_ '...'
        want_errored_with_ :path_cannot_contain_dot_file,
          '(par «your_value») cannot contain dot file - (ick "...")'
      end

      it "yes LOOK" do
        _want_the_passthru_normalization_with './*'
      end
    end

    def _want_the_passthru_normalization_with s
      normalize_against_ s
      want_the_passthru_normalization__
    end

    def want_errored_with * a, & p
      want_output_value_was_not_written_
      expect( @result_x ).to eql false
      want_not_OK_event( * a, & p )
    end

    def _new_subject * x_a
      _subject_module.via_iambic x_a
    end

    def _subject_module
      Home_::Pathname::Normalization
    end
  end
end
