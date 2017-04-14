module Skylab::Brazen

  module CollectionAdapters::GitConfig

    module Mutable

      class Magnetics::WriteDocument_via_Collection < Common_::MagneticBySimpleModel

        # always succeeds. failure is impossible

        def initialize
          @do_write_to_tmpfile_first = false
          @is_dry = false
          super
          @filesystem ||= Home_.lib_.system.filesystem
        end

        def write_to_tmpfile_first
          @do_write_to_tmpfile_first = true
        end

        attr_writer(
          :filesystem,  # at writing, never set explicitly
          :is_dry,
          :line_upstream,
          :listener,
          :path,
        )

        def execute

          __note_whether_the_file_existed_before_the_write

          bytes = 0
          st = remove_instance_variable :@line_upstream
          __with_IO_open_for_writing do |io|
            begin
              line = st.gets
              line || break
              bytes += io.write line
              redo
            end while above
          end

          __emit_an_emission_structure bytes

          ACHIEVED_  # all failures are exceptional
        end

        # -- C

        def __emit_an_emission_structure bytes

          _verb_lemma = @__file_existed_before ? :update : :create

          _ = WroteFileEvent_via_Values.call_by do |o|

            o.bytes = bytes
            o.is_dry = @is_dry
            o.path = @path
            o.verb_lemma_symbol = _verb_lemma
          end

          @listener.call :info, :success do
            _
          end
          NIL
        end

        # -- B

        def __with_IO_open_for_writing

          __init_IO_open_for_writing_and_support

          io = remove_instance_variable :@_IO
          x = yield io
          io.close

          if @do_write_to_tmpfile_first
            _path = remove_instance_variable :@__tmpfile_path
            @filesystem.mv _path, @path, noop: @is_dry
          end

          x
        end

        def __init_IO_open_for_writing_and_support

          if @is_dry

            @_IO = Home_.lib_.system_lib::IO::DRY_STUB

          elsif @do_write_to_tmpfile_first

            _head = Home_.lib_.system.filesystem.tmpdir_path
            path = ::File.join _head, 'br-VOLATILE'  # #[#sl-122]

            @_IO = ::File.open path, WRITE_MODE__
            @__tmpfile_path = path

          else

            @_IO = ::File.open @path, WRITE_MODE__
          end
          NIL
        end

        # -- A

        def __note_whether_the_file_existed_before_the_write
          @__file_existed_before = @filesystem.exist? @path
        end

        # ==

        class WroteFileEvent_via_Values < Common_::MagneticBySimpleModel  # [tm] too

          attr_writer(
            :bytes,
            :is_dry,
            :path,
            :verb_lemma_symbol,
          )

          def execute

            _ev = Common_::Event.inline_OK_with(

              :collection_resource_committed_changes,
              :bytes, remove_instance_variable( :@bytes ),
              :is_completion, true,
              :is_dry, remove_instance_variable( :@is_dry ),
              :path, remove_instance_variable( :@path ),
              :verb_lemma_symbol, remove_instance_variable( :@verb_lemma_symbol ),

            ) do | y, o |

              _dry = ( "dry " if o.is_dry )

              y << "#{ o.verb_lemma_symbol }d #{ pth o.path } (#{ o.bytes } #{ _dry }bytes)"
            end

            _ev  # hi. #todo
          end
        end

        # ==

        WRITE_MODE__ = ::File::WRONLY | ::File::TRUNC | ::File::CREAT

        # ==
        # ==
      end
    end
  end
end
# #history-A: phased out iambic interface for "magnetic by simple model".
#             before this work, was ~#[#081] "experimental extensions to methodic actor"
