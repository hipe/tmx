require_relative '../test-support'

module Skylab::TaskExamples::TestSupport

  describe "[de] task-types - move to" do

    TS_[ self ]
    use :task_types

    def subject_class_
      Task_types_[]::MoveTo
    end

    context "requires move_to and from" do

      it "and fails without it" do

        expect_missing_required_attributes_are_ :move_to, :from
      end

      def build_arguments_
        EMPTY_H_
      end
    end

    context "when moving an existing file" do

      def before_execution_

        _fuc = TestLib_::System[].filesystem.file_utils_controller do | msg |
          if do_debug
            debug_IO.puts "(#{ msg })"
          end
        end

        prepare_build_directory_

        _from = ::File.join FIXTURES_DIR, 'some-file.txt'
        _to = ::File.join BUILD_DIR, 'some-file.txt'

        _fuc.cp _from, _to

        NIL_
      end

      context "to an available location" do

        shared_state_

        it "content is moved to new location (ORDER SENSITIVE)" do

          content = nil
          exists = nil
          @__TERRIBLE = -> do
            content = read_file_ from
            exists = file_exists_ move_to
            NIL_
          end

          state_

          exists.should eql false

          file_exists_( from ).should eql false
          read_file_( move_to ).should eql content
        end

        it "succeeds" do
          succeeds_
        end

        it "emits a `shell` emission" do

          _rx = /mv .*some-file.txt .*move-worked.txt/
          expect_only_ :shell, _rx
        end

        def before_execution_
          super()
          remove_instance_variable( :@__TERRIBLE )[]
          NIL_
        end

        memoize_ :move_to do
          ::File.join BUILD_DIR, 'move-worked.txt'
        end
      end

      context "to an unavailable location" do

        shared_state_

        it "fails" do
          fails_
        end

        it "expreses the error" do

          _rx = /\bfile exists.*another-file/
          expect_only_ :error, _rx
        end

        def move_to
          ::File.join FIXTURES_DIR, 'another-file.txt'
        end
      end

      memoize_ :from do
        ::File.join BUILD_DIR, 'some-file.txt'
      end
    end

    context "when moving a nonexitant file" do

      shared_state_

      it "fails" do
        fails_
      end

      it "expresses the error" do

        _rx = /\bfile not found.*not-there\b/
        expect_only_ :error, _rx
      end

      def from
        ::File.join FIXTURES_DIR, 'not-there'
      end

      def move_to
        ::File.join BUILD_DIR, 'wherever'
      end
    end

    def build_arguments_
      {
        move_to: move_to,
        from: from,
      }
    end

    def context_
      NIL_
    end
  end
end
