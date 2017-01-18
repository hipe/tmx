module Skylab::TanMan

  module Input_Adapters_::Treetop

    class Actors_::Build_units_of_work < Common_::Dyadic

      # build the array of units of work, necessarily in one batch so we
      # memoize the existential state of the various dirs involved, only
      # hitting the filesystem once per dir, not once per unit of work.
      #
      #   • this used to be over-generalized. we have since parsimonized it.
      #   • this once looked like a :+[#sy-004] normalizer. but no longer.

      def initialize batrs, fs, & p
        @bound_attributes = batrs
        @filesystem = fs
        @on_event_selectively = p
      end

      Common_::Event.selective_builder_sender_receiver self

      def execute

        out_a = []

        @_gx_qkn = @bound_attributes.lookup :add_treetop_grammar  # a "list" b.p

        @_gx_qkn.value_x.each_with_index do | grammar_path, d |

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

        @_uow = Models_::Grammar_to_Load.new

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

        ba = @bound_attributes.lookup sym
        dir = ba.value_x

        ok = if dir

          if @filesystem.directory? dir
            instance_variable_set :"@__#{ sym }__", dir
            ACHIEVED_
          else
            maybe_send_error :__build_not_directory_error, ba
          end
        else
          maybe_send_error :__build_no_anchor_path_event, :xx, ba
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

        i_a = Actors_::Hack_peek_module_name.call(
          uow.input_path,
          @filesystem,
          & @on_event_selectively )

        if i_a

          uow.module_name_i_a = i_a

          uow.output_path_did_exist = @filesystem.file? uow.output_path

          uow.freeze
        else
          i_a
        end
      end

      def __build_not_abspath_event qkn, qkn_

        build_not_OK_event_with :not_absolute_path do |y, _|

          y << "#{ nm qkn_.name } must be an absolute #{
            }path in order to expand paths like #{ nm qkn.name } #{
              }(path: #{ pth qkn.value_x })"
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

          y << "#{ nm qkn.name } is not a directory: #{ pth qkn.value_x }"
        end
      end

      def __build_not_found_error qkn

        build_not_OK_event_with :not_found do |y, _|

          y << "#{ nm qkn.name } not found: #{ pth qkn.value_x }"
        end
      end
    end
  end
end
