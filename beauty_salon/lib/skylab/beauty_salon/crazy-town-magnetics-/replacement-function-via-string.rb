# frozen_string_literal: true

module Skylab::BeautySalon

  class CrazyTownMagnetics_::ReplacementFunction_via_String < Common_::MagneticBySimpleModel

    class ReplacementFunction___

      def initialize x, const, path
        @user_function = x
        @user_const = const
        @path = path
        freeze
      end

      attr_reader(
        :path,
        :user_const,
        :user_function,
      )
    end

    # -

      attr_writer(
        :listener,
        :string,
      )

      def execute
        @scanner = Home_.lib_.string_scanner.new remove_instance_variable :@string
        ok = true
        ok &&= __parse_schema
        ok &&= __parse_colon
        ok && __parse_the_rest
      end

      # --

      def __parse_the_rest
        send @_town_time
      end

      # --

      def __parse_colon
        _yes = @scanner.skip %r(:)
        if _yes
          _step
        else
          expecting_token ':'
        end
      end

      # --

      def __parse_schema
        _step
        s = @scanner.scan %r([a-z]+)
        if s
          __parse_schema_via_string s
        else
          _when_failed_to_parse_schema
        end
      end

      def __parse_schema_via_string s
        case s
        when 'file' ; __accept_that_schema_is_file
        else ; _when_failed_to_parse_schema
        end
      end

      def _when_failed_to_parse_schema

        expecting_token 'file'
      end

      def __accept_that_schema_is_file
        @use_pos = @scanner.pos
        @_town_time = :__when_file
        ACHIEVED_
      end

      # --

    # -

    # ==

      def __when_file
        @filesystem = ::File
        ok = true
        ok &&= __parse_path
        ok &&= __open_path
        ok &&= __resolve_user_function_module
        ok &&= __flush
      end

      def __flush

        ReplacementFunction___.new(
          remove_instance_variable( :@__user_function ),
          @_user_const,
          @path.freeze,
        )
      end

      # --

      def __resolve_user_function_module

        # (we have functions that do most of this but meh)

        mod = __touch_module

        new_consts = __new_consts mod

        matched_consts, stem = __matched_consts_and_stem new_consts

        case 1 <=> matched_consts.length
        when 0
          @_user_const = matched_consts.fetch 0
          @__user_function = mod.const_get @_user_const, false
          ACHIEVED_
        when 1
          __when_not_found stem, new_consts, mod
        when -1
          self._COVER_ME__easy_to_write__ambiguous__
        end
      end

      def __when_not_found stem, new_consts, mod

        path = @path

        @listener.call :error, :expression, :load_error do |y|

          _s = Common_::Name.via_slug( stem ).as_camelcase_const_string

          y << "expecting something like #{ mod }::#{ _s }"
          y << "to be defined in #{ path }"

          if new_consts.length.zero?
            y << "file apparently defined no consts at all"
          else
            y << "(had consts: #{ new_consts * ', ' })"
          end
        end
        UNABLE_
      end

      def __matched_consts_and_stem new_consts

        basename = ::File.basename @path
        d = ::File.extname( basename ).length
        stem = d.zero? ? basename : basename[ 0 ... -d ]

        target_sym = Common_::Distill[ stem ]

        matched_consts = []
        new_consts.each do |const|  # might be zero

          _actual = Common_::Distill[ const ]
          if target_sym == _actual
            matched_consts.push const
          end
        end

        [ matched_consts, stem ]
      end

      def __new_consts mod

        consts_before = mod.constants

        io = remove_instance_variable :@__IO
        load @path
        io.close  # no, there's really not much gained by opening an IO
        mod.constants - consts_before
      end

      def __touch_module

        parent_mod = ::Skylab::BeautySalon
        const = :CrazyTownFunctions
        if ! parent_mod.const_defined? const, false
          parent_mod.const_set const, ::Module.new
        end
        parent_mod.const_get const, false
      end

      # --

      def __open_path
        io = @filesystem.open @path
        io.flock( ::File::LOCK_EX ).zero? || self._COVER_ME__failed_to_lc
        io.gets  # yi
        @__IO = io
      rescue ::Errno::ENOENT, ::Errno::EISDIR => e
        @listener.call :error, :expression, :parse_error do |y|

          msg = e.message
          msg.gsub!( / @ [a-z_]+ -(?: fd:\d+)? /, ' - ' )  # yikes this mutates the original - meh
          y << msg
          # me.express_scanner_state_into y (this is really ugly with long paths. ellipsifying meh)
        end
        UNABLE_
      end

      def __parse_path

        s = @scanner.scan %r(.+\z)
        if s
          @path = s ; ACHIEVED_
        else
          expecting_argument "path"
        end
      end

    # ==

      def expecting_argument s
        _expecting_moniker "<#{ s }>"
      end

      def expecting_token token_s
        _expecting_moniker "'#{ token_s }'"
      end

      def _expecting_moniker moniker_s

        me = self
        @listener.call :error, :expression, :parse_error do |y|
          y << "expecting #{ moniker_s }:"
          me.express_scanner_state_into y
        end
        UNABLE_
      end

      def express_scanner_state_into y

        _dashes = DASH_ * @use_pos

        y << "  #{ @scanner.string }"
        y << "  #{ _dashes }^"
      end

      def _step
        @use_pos = @scanner.pos
        ACHIEVED_
      end

    # ==

    # ==
  end
end
# #born.
