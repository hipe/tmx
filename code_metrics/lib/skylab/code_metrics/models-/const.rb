module Skylab::CodeMetrics

  class Models_::Const

    class ConstScanner

      # why don't we just `split` and `const_get`, you ask? we want
      # the option of failing gracefully with detailed error message
      # from arbitrary user-entered strings.

      class << self

        def via_string s, & p
          __begin( s, & p ).__init
        end

        alias_method :__begin, :new
        undef_method :new
      end

      def initialize s, & p
        @_scn = Home_.lib_.string_scanner.new s
        @_listener = p
      end

      def __init
        if _end_of_scan
          _when_premature_end_of_string
        elsif _skip_const_sep
          @was_absolute = true
          if _end_of_scan
            _when_premature_end_of_string
          else
            _at_normal_head
          end
        else
          _at_normal_head
        end
      end

      def _at_normal_head
        @no_unparsed_exists = false
        if _parse_const
          @_advance_one = :__advance_one_normally
          if _end_of_scan
            @is_last = true
            self
          else
            @is_last = false
            self
          end
        else
          _when_failed_to_parse_const
        end
      end

      def flush_to_value
        if @no_unparsed_exists
          fail
        else
          __flush_to_value
        end
      end

      def __flush_to_value
        mod = ::Object
        begin
          _mod_ = mod.const_get current_token, false
          mod = _mod_
          advance_one
        end until @no_unparsed_exists
        Common_::Known_Known[ mod ]
      end

      def gets_one
        x = current_token
        _ok = send @_advance_one
        _ok && x
      end

      def current_token
        @_current_token_knownness.value_x
      end

      def advance_one
        send @_advance_one
        NIL
      end

      def __advance_one_normally  # result in t/r
        remove_instance_variable :@_current_token_knownness
        if @is_last
          remove_instance_variable :@_advance_one
          remove_instance_variable :@_scn
          @no_unparsed_exists = true
          ACHIEVED_
        elsif _skip_const_sep
          if _parse_const
            if _end_of_scan
              @is_last = true
            end
            ACHIEVED_
          else
            _when_failed_to_parse_const
          end
        else
          __when_expected_separator
        end
      end

      def _parse_const
        s = @_scn.scan CONST___
        if s
          s.freeze
          @_current_token_knownness = Common_::Known_Known[ s ]
          ACHIEVED_
        else
          UNABLE_
        end
      end

      def _skip_const_sep
        @_scn.skip CONST_SEP___
      end

      def _end_of_scan
        @_scn.eos?
      end

      # ==

      def _when_failed_to_parse_const
        me = self
        @_listener.call :error, :expression, :failed_to_parse_const do |y|
          y << "failed to parse const (near #{ me._express_near })"
        end
        UNABLE_
      end

      def _when_premature_end_of_string
        scn = @_scn
        @_listener.call :error, :expression, :premature_end_of_string do |y|
          y << "premature end of string (had: #{ scn.string.inspect })"
        end
        UNABLE_
      end

      def _express_near
        _lib = Home_.lib_.basic::String
        d = @_scn.pos
        _hi = @_scn.scan %r(.{0,20})m
        @_scn.pos = d
        _ = _lib.ellipsify _hi, 16
        "\"#{ _ }\""
      end

      # ==

      attr_reader(
        :is_last,
        :no_unparsed_exists,
        :was_absolute,
      )

      CONST___ = /[A-Z][a-zA-Z0-9_]+(?=$|::)/
      CONST_SEP___ = /::/
    end

    # ==

    # ==
  end
end
# #tombstone-A: furlough const-based load adapter
# #born for mondrian
