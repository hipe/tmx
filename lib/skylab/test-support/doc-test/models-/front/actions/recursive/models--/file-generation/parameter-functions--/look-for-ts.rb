module Skylab::TestSupport

  module DocTest

    module Models_::Front

      class Actions::Recursive

        class Models__::File_Generation

          class Parameter_Functions__::Look_for_TS < Parameter_Function_

            # rather than always adhering to the strong convention of having
            # the test support file in a fixed relative path from every test
            # file experimentally now we can instead search upwards from the
            # test file, searching for any nearest test support file, and if
            # found use that relative path in the generated test file.

            def initialize( * )
              super  # before below
              @test_path = @generation.output_path
              @test_pn = ::Pathname.new @test_path
            end

            def execute

              ok = resolve_payload_pathname_by_looking_downwards
              ok ||= resolve_payload_pathname_by_looking_upwards
              ok and via_payload_pathname

            end

            def resolve_payload_pathname_by_looking_downwards

              # this wouldn't be necessary as a separate step except that the
              # file walk will fail if the starting directory does not exist

              _test_path_as_directory_pn = @test_pn.sub_ext EMPTY_S_

              maybe_pn = _test_path_as_directory_pn.join TEST_SUPPORT_FILE_

              if maybe_pn.exist?
                @payload_pn = maybe_pn
                ACHIEVED_
              end
            end

            def resolve_payload_pathname_by_looking_upwards

              _dirname = ::File.dirname @test_path

              pn = TestSupport_._lib.system.filesystem.walk(
                :start_path, _dirname,
                :filename, TEST_SUPPORT_FILE_,
                :max_num_dirs_to_look, -1,
                :property_symbol, :dirname_derived_from_output_path,
                :on_event_selectively, @on_event_selectively )

              if pn
                @payload_pn = pn
                ACHIEVED_
              else
                pn
              end
            end

            def via_payload_pathname

              @generation.set_template_variable(
                :require_test_support_relpath,
                @payload_pn.relative_path_from( @test_pn ).sub_ext( EMPTY_S_ ).to_path )

              ACHIEVED_
            end

            a = TestSupport_::Init.test_support_filenames

            TEST_SUPPORT_FILE_ = a.fetch( a.length - 1 << 2 )

            TEST_SUPPORT_DIR_ =
              ::Pathname.new( TEST_SUPPORT_FILE_ ).sub_ext( EMPTY_S_ ).to_path

          end
        end
      end
    end
  end
end