module Skylab::TMX

  module Operations_::Map

    class FrontCLI

      # (this is used to test lowelevel nerks so we gotta duplicate some stuff)

      def initialize i, o, e, pn_s_a
        @serr = e
        @sout = o
        @program_name_string_array = pn_s_a
      end

      def invoke argv
        @exitstatus = 0
        @argv = argv
        if __resolve_bound_call
          bc = remove_instance_variable :@__bound_call
          st = bc.receiver.send bc.method_name, * bc.args, & bc.block
          if st
            begin
              x = st.gets
              x || break
              @sout.puts x.get_filesystem_directory_entry_string
              redo
            end while above
          end
        end
        @exitstatus
      end

      def __resolve_bound_call
        d = @argv.length
        if d.zero?
          __when_no_args
        elsif Looks_like_opt__[ @argv.first ]
          __when_looks_like_option_at_front
        elsif 1 < d && Looks_like_opt__[ @argv.last ]
          __when_looks_like_option_at_back
        else
          __when_some_args
        end
      end

      def __when_looks_like_option_at_back
        @_unsanitized_option = @argv.last
        @_then = :__after_parsed_last
        _via_unsanitized_option
      end

      def __when_looks_like_option_at_front
        @_unsanitized_option = @argv.first
        @_then = :__after_parsed_first
        _via_unsanitized_option
      end

      def _via_unsanitized_option
        if /\A--?h(?:e(?:lp?)?)?\z/ =~ @_unsanitized_option
          __when_help
        else
          __when_unrecognized_option
        end
      end

      def __when_help
        io = @serr
        io.puts "usage #{ _program_name } #{ _formal_actions } [opts]"
        io.puts
        io.puts "description: experiment.."
        NIL
      end

      def __when_unrecognized_option
        @serr.puts "unrecognized option: #{ @_unsanitized_option.inspect }"
        _invite_to_help
      end

      def __when_no_args
        @serr.puts "expecting #{ _formal_actions }"
        _invite_to_help
      end

      # --

      def __when_some_args

        y = Lazy_.call do
          ::Enumerator::Yielder.new do |s|
            @serr.puts s
          end
        end

        @_emit = -> * i_a, & p do
          if :eventpoint == i_a[0]
            send i_a.fetch 1
          else
             nil.instance_exec y[], & p
            if :parse_error == i_a[2]
              _invite_to_help
            elsif :error == i_a.first
              @exitstatus = 5
            end
          end
          NIL
        end

        _scn = Common_::Polymorphic_Stream.via_array @argv

        @__bound_call = BoundCall_via_Dispatch.new( _scn, & @_emit ).execute

        ACHIEVED_
      end

      def clear_argv
        @argv.clear ; nil
      end

      # --

      def _invite_to_help
        @serr.puts "try '#{ _program_name } -h'"
        _failed
      end

      def _program_name
        ::File.basename @program_name_string_array.last
      end

      def _formal_actions
        "{map}"
      end

      def _failed
        @exitstatus = 5
        UNABLE_
      end
    end  # end CLI

    # ==

    class BoundCall_via_Dispatch

      def initialize scn, & emit
        @scn = scn
        @_emit = emit
      end

      def execute
        if "map" == @scn.current_token
          @scn.advance_one
          if @scn.no_unparsed_exists
            __map_money
          else
            __when_unexpected_arguments
          end
        else
          __when_unrecognized_action
        end
      end

      def __when_unexpected_arguments
        scn = @scn
        @_emit.call :error, :emission, :parse_error do |y|
          y << "unexpected argument - #{ scn.current_token.inspect }"
        end
        UNABLE_
      end

      def __when_unrecognized_action
        scn = @scn
        @_emit.call :error, :emission, :parse_error do |y|
          y << "unrecognized action #{ scn.current_token.inspect }"
        end
        UNABLE_
      end

      def __map_money

        @_emit.call :eventpoint, :clear_argv

        dir = ::File.expand_path '../../..', Home_.dir_path  # sidesys_path_

        stat = ::File.lstat dir

        if stat.symlink?
          dir_ = ::File.readlink dir
        else
          dir_ = dir
        end

        _yikes = ::File.dirname dir_

        _rcvr = TheMapOperation___.new _yikes, ::Dir, & @_emit

        Common_::Bound_Call[ nil, _rcvr, :execute ]
      end
    end

    # ==

    class TheMapOperation___

      def initialize dir, filesystem, & p
        @dir = dir
        @_emit = p
        @filesystem = filesystem
      end

      def execute
        if __glob_produces_one_or_more_file
          __produce_stream
        else
          __whine_about_it
        end
      end

      def __glob_produces_one_or_more_file

        @_glob = ::File.join @dir, '*', '.for-tmx-map.json'

        paths = @filesystem.glob @_glob
        if paths.length.zero?
          UNABLE_
        else
          @__paths = paths ; ACHIEVED_
        end
      end

      def __whine_about_it
        glob = @_glob
        @_emit.call :error, :expression do |y|
          y << "found no files for #{ glob }"
        end
        UNABLE_
      end

      def __produce_stream

        require 'json'

        ac = AttributeCache___.new Home_::Attributes_

        Common_::Stream.via_nonsparse_array @__paths do |path|
          Node___.new path, ac
        end
      end
    end

    # ==

    class Node___

      def initialize json_file, ac
        @_attribute_cache = ac
        @json_file = json_file
      end

      def get_filesystem_directory_entry_string
        ::File.basename ::File.dirname @json_file
      end
    end

    # ==

    class AttributeCache___

      def initialize mod
        @module = mod
      end
    end

    # ==

    Looks_like_opt__ = -> do
      d = DASH_.getbyte 0  # DASH_BYTE_
      -> s do
        d == s.getbyte(0)
      end
    end.call

    # ==
  end
end
