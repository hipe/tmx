module Skylab::TanMan

  module InputAdapters_::Treetop

    class Magnetics_::GrammarArray_via_Entity < Common_::Dyadic  # 1x

      # build the array of units of work, necessarily in one batch so we
      # memoize the existential state of the various dirs involved, only
      # hitting the filesystem once per dir, not once per unit of work.
      #
      #   • this used to be over-generalized. we have since parsimonized it.
      #   • this once looked like a :+[#sy-004] normalizer. but no longer.

      def initialize avr, fs, & p
        @association_value_reader = avr
        @filesystem = fs
        @on_event_selectively = p
      end

      include Common_::Event::ReceiveAndSendMethods

      def execute

        out_a = []

        @_gx_qkn = @association_value_reader.association_reader_via_symbol :add_treetop_grammar  # a "list" b.p

        @_gx_qkn.value.each_with_index do |grammar_path, d|

          @_grammar_path = grammar_path
          @_item_index = d

          gr = __build_grammar
          if gr
            out_a.push gr
          else
            out_a = gr
            break
          end
        end
        out_a
      end

      def __build_grammar

        @_uow = Grammar_to_Load___.new

        if FILE_SEPARATOR_ == @_grammar_path[ 0 ]  # ..
          __when_grammar_path_is_absolute
        else
          __when_grammar_path_is_relative
        end
      end

      def __when_grammar_path_is_relative

        _ok = __maybe_normalize_head_paths
        _ok && __when_head_paths_are_normal
      end

      def __maybe_normalize_head_paths

        @___did_normalize_head_paths ||= __init_normalize_head_paths
        @_head_paths_are_normal
      end

      def __init_normalize_head_paths  # must assert both head dirs exist

        @_head_paths_are_normal = true

        _check_dir :input_path_head_for_relative_paths
        _check_dir :output_path_head_for_relative_paths
        ACHIEVED_
      end

      def _check_dir sym  # must assert is (existent) directory

        ar = @association_value_reader.association_reader_via_symbol sym
        dir = ar.value

        ok = if dir

          if @filesystem.directory? dir
            instance_variable_set :"@__#{ sym }__", dir
            ACHIEVED_
          else
            maybe_send_error :__build_not_directory_error, ar
          end
        else
          maybe_send_error :__build_no_anchor_path_event, :xx, ar
        end

        if ! ok
          @_head_paths_are_normal = ok
        end

        NIL_
      end

      def __when_head_paths_are_normal  # assume relative path, head dirs exist

        stem = @_grammar_path
        uow = @_uow

        uow.input_path = ::File.join(
          @__input_path_head_for_relative_paths__, stem )

        output_path = ::File.join(
          @__output_path_head_for_relative_paths__,
          _convert_basename( stem ) )

        uow.output_path = output_path

        dir = ::File.dirname output_path  # *not* necessaritly same as ivar

        if ! @filesystem.directory? dir

          # assume that the head paths are (existent) directories. therefor,
          # to mkdir -p the above dir is "guaranteed" to make only a number
          # directories that corresponds to the number of slashes in the stem

          uow.make_this_directory_minus_p = dir
        end

        _common_finish
      end

      def __when_grammar_path_is_absolute

        path = @_grammar_path

        if @filesystem.file? path

          @_uow.input_path = path

          @_uow.output_path = ::File.join(
            ::File.dirname( path ),
            _convert_basename( ::File.basename( path ) ) )

          _common_finish
        else
          maybe_send_error :__build_not_found_error
        end
      end

      def _convert_basename bn
        "#{ bn }#{ Autoloader_::EXTNAME }"
      end

      def _common_finish

        uow = @_uow

        sym_a = Magnetics_::HackPeekConstArray_via_AssetPath.call(
          uow.input_path,
          @filesystem,
          & @on_event_selectively )

        if sym_a

          uow.module_name_i_a = sym_a

          uow.output_path_did_exist = @filesystem.file? uow.output_path

          uow.freeze
        else
          sym_a
        end
      end

      def __build_not_abspath_event qkn, qkn_

        build_not_OK_event_with :not_absolute_path do |y, _|

          y << "#{ nm qkn_.name } must be an absolute #{
            }path in order to expand paths like #{ nm qkn.name } #{
              }(path: #{ pth qkn.value })"
        end
      end

      def __build_no_anchor_path_event qkn, qkn_

        build_not_OK_event_with :no_anchor_path do |y, _|

          y << "#{ nm qkn_.name } must be set #{
            }in order to support a relative path like #{ o.qkn.label }!"
        end
      end

      def __build_not_directory_error qkn

        build_not_OK_event_with :not_a_directory do |y, _|

          y << "#{ nm qkn.name } is not a directory: #{ pth qkn.value }"
        end
      end

      def __build_not_found_error qkn

        build_not_OK_event_with :not_found do |y, _|

          y << "#{ nm qkn.name } not found: #{ pth qkn.value }"
        end
      end

      # ==

      class Grammar_to_Load___

        attr_accessor(
          :input_path,
          :make_this_directory_minus_p,
          :module_name_i_a,
          :output_path,
          :output_path_did_exist,
        )
      end

      # ==
      # ==
    end
  end
end
