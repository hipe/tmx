require_relative '../test-support'

module Skylab::TaskExamples::TestSupport

  describe "[te] task-types - move to" do

    TS_[ self ]
    use :memoizer_methods
    use :want_event
    use :task_types

    def subject_class_
      Task_types_[]::MoveTo
    end

    context "essential" do

      it "loads" do
        subject_class_
      end
    end

    context "from doesn't exist" do

      shared_subject :state_ do

        _from = non_existent_file_path_
        _to = other_non_existent_file_path_
        _want_emission _from, _to
      end

      it "fails" do
        fails_
      end

      it "emits" do

        _rx = %r<\Afile not found - \(pth "/[^ ]+not-here\.file"\)\z>

        expect( error_expression_message_ ).to match _rx
      end
    end

    context "'move to' exists" do

      shared_subject :state_ do

        _from = one_existent_file_path_
        _to = other_existent_file_path_
        _want_emission _from, _to
      end

      it "fails" do
        fails_
      end

      it "emits" do

        _rx = %r(\Afile exists - \(pth "/[^ ]+three-lines\.txt"\)\z)

        expect( error_expression_message_ ).to match _rx
      end
    end

    context "move OK" do

      shared_subject :state_ do

        td = empty_tmpdir_
        _from = td.touch 'za-za'
        _to = ::File.join( td.path, 'foo-foo' )

        _want_emission _from, _to
      end

      it "succeeds" do
        succeeds_
      end

      it "emits" do
        expect( info_expression_message_ ).to match %r(\Amv )
      end
    end

    def _want_emission from, to

      state_where_emission_is_expected_(
        :filesystem, real_filesystem_,
        :from, from,
        :move_to, to,
      )
    end
  end
end
