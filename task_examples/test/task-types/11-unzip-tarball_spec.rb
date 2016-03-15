require_relative '../test-support'

module Skylab::TaskExamples::TestSupport

  describe "[te] task-types unzip tarball", wip: true do

    TS_[ self ]
    use :memoizer_methods
    use :task_types

    def subject_class_
      Task_types_[]::UnzipTarball
    end

    context "with no build args" do

      it "whines about missing required fields" do

        expect_missing_required_attributes_are_ :unzip_tarball, :build_dir
      end

      def build_arguments_
        EMPTY_H_
      end

      def context_
        EMPTY_H_
      end
    end

    context "with good build args" do

      context "when tarball does not exist" do

        shared_state_

        it "fails" do
          fails_
        end

        it "whines (returns false, emits error)" do

          _rx = /tarball not found.*not-there/
          expect_only_ :error, _rx
        end

        def unzip_tarball
          "#{ FIXTURES_DIR }/not-there.tar.gz"
        end
      end

      context "when the tarball exists" do

        shared_state_

        def before_execution_

          _this_ build_build_directory_controller_
        end

        def _this_ o

          o.prepare
          o.copy unzip_tarball
          NIL_
        end

        memoize :unzip_tarball do
          ::File.join( FIXTURES_DIR, 'mginy-0.0.1.tar.gz' ).freeze
        end

        context "when the target directery exists" do

          shared_state_

          it "succeeds" do
            succeeds_
          end

          it "expresses" do

            _rx = /exists, won't tar extract: .*mginy/
            expect_only_ :info, _rx
          end

          def _this_ o
            super
            o.mkdir "#{ BUILD_DIR }/mginy"
            NIL_
          end
        end

        context "when it's not a tarball" do

          shared_state_

          it "fails" do
            fails_
          end

          it "expresses" do
            _rx = /failed to unzip.*unrecognized archive format/i
            expect_eventually_ :error, _rx
         end

          def unzip_tarball
            ::File.join FIXTURES_DIR, 'not-a-tarball.tar.gz'
          end
        end

        context "when it is a tarball and the target directory does not exist" do

          shared_state_

          it "succeeds" do
            succeeds_
          end

          it "expresses shell" do

            _rx = /cd [^ ]+\[te\]; tar -xzvf mginy/
            expect_eventually_ :shell, _rx
          end

          it "errput lists etc" do

            st = emission_stream_controller_
            st.advance_to_first :err

            expect_ :err, "x mginy/"
            expect_ :err, "\nx mginy/README"

            if st.unparsed_exists
              :err == st.current_token.stream_symbol and fail
            end
          end
        end
      end

      def build_arguments_
        {
          unzip_tarball: unzip_tarball,
        }
      end

      memoize :context_ do
        {
          build_dir: BUILD_DIR,
        }.freeze
      end
    end
  end
end
