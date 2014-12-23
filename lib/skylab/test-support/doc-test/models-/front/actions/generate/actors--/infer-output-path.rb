module Skylab::TestSupport

  module DocTest

    module Models_::Front

      class Actions::Generate

        class Actors__::Infer_output_path

          Callback_::Actor.call self, :properties,

            :input_path,
            :on_event_selectively


          def execute
            via_manifest_entry_absolute_path_resolve_test_dir_pathname &&
              via_test_dir_pathname_resolve_output_path
          end

          def via_manifest_entry_absolute_path_resolve_test_dir_pathname

            @test_dir_pn = TestSupport_._lib.system.filesystem.walk(
              :start_path, ::File.dirname( @input_path ),
              :filename, TEST_DIR_FILENAME_,
              :ftype, DIR_FTYPE_,
              :max_num_dirs_to_look, -1,
              :property_symbol, :manifest_entry_path_dirname,
              :on_event_selectively, @on_event_selectively )

            @test_dir_pn ? ACHIEVED_ : UNABLE_
          end

          DIR_FTYPE_ = 'directory'.freeze

          def via_test_dir_pathname_resolve_output_path

            test_dir_path = @test_dir_pn.to_path

            sidesystem_path_length =
               test_dir_path.length - SEP_LENGTH_ - TEST_DIR_FILENAME_.length

            _sidesystem_abspath = @input_path[ 0, sidesystem_path_length ]

            sidesys_relpath = @input_path[ sidesystem_path_length + SEP_LENGTH_ .. -1 ]

            if sidesys_relpath.include? FILE_SEP_
              dirname = remove_trailing_dashes_from_pathparts ::File.dirname sidesys_relpath
              basename = ::File.basename sidesys_relpath
            else
              basename = sidesys_relpath
            end

            _testfile_basename = testfile_basename_via_basename basename

            part_a = [ _sidesystem_abspath, TEST_DIR_FILENAME_ ]
            dirname and part_a.push dirname
            part_a.push _testfile_basename

            ::File.join( * part_a )
          end  # :[#bs-026]. this method is a case study

          SEP_LENGTH_ = FILE_SEP_.length

          def remove_trailing_dashes_from_pathparts sidesys_relpath

            _upstream_parts = sidesys_relpath.split FILE_SEP_

            _downstream_parts = _upstream_parts.map do | s |
              Remove_trailing_dashes___[ s ]
            end

            _downstream_parts.join FILE_SEP_
          end

          Remove_trailing_dashes___ = -> s do
            s_ = s.dup
            Mutate_string_by_removing_trailing_dashes_[ s_ ]
            s_
          end

          def testfile_basename_via_basename basename
            pn = ::Pathname.new basename
            ext  = pn.extname
            stem = pn.sub_ext( EMPTY_S_ ).to_path
            Mutate_string_by_removing_trailing_dashes_[ stem ]
            "#{ stem }#{ TestSupport_::Init.test_file_basename_suffix_stem }#{ ext }"
          end
        end
      end
    end
  end
end
