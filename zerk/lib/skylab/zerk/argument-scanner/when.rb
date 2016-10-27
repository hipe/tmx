module Skylab::Zerk

  module ArgumentScanner

    When = ::Module.new

    module WhenScratchSpace____

      # ==

      When::Argument_value_not_provided = -> argument_scanner do

        self._COVER_ME_just_a_sketch

        sym = argument_scanner.current_primary_symbol

        argument_scanner.listener.call(
          :error, :expression, :parse_error, :primary_value_not_provided
        ) do |y|

          _name = Common_::Name.via_variegated_symbol sym

          y << "#{ say_primary_ _name } must be followed by an argument"

        end
        UNABLE_
      end

      # ==

      class When::UnknownPrimary

        # this does the levenshtein-like (but not levenshtein) thing where
        # we explicate valid alternatives.
        #
        #   - CLI (not API) frequently makes use of the "subtraction hash"
        #     which must decidedly be taken into account when effecting this
        #     UI expression behavior.
        #
        #   - otherwise, we want this UI expression behavior between CLI
        #     and API to be identical (or more accurately, different in
        #     the regular way as per the respective expression agents).
        #

        class << self
          alias_method :begin, :new
          undef_method :new
        end  # >>

        def initialize
          @recognizable_normal_symbols_proc = nil
          @subtraction_hash = nil
          @terminal_channel_symbol = nil
        end

        attr_writer(
          :listener,
          :name_by,
          :recognizable_normal_symbols_proc,
          :subtraction_hash,
          :terminal_channel_symbol,
        )

        def execute

          ks_p = @recognizable_normal_symbols_proc
          name_p = @name_by
          sub_h = @subtraction_hash

          _tcs = ( @terminal_channel_symbol || :unknown_primary )

          @listener.call :error, :expression, :parse_error, _tcs do |y|

            buffer = "unknown primary"
            _name = name_p[]
            s = say_strange_primary_ _name
            if COLON_BYTE_ != s.getbyte(0)
              buffer << COLON_
            end
            buffer << SPACE_
            buffer << s
            y << buffer

            if ks_p

              _keys = ks_p[]
              sub_h ||= MONADIC_EMPTINESS_

              _name_st = Stream_[ _keys ].map_reduce_by do |sym|

                if ! sub_h[ sym ]
                  Common_::Name.via_variegated_symbol sym
                end
              end
              _this_or_this_or_this = say_primary_alternation_ _name_st
              y << "expecting #{ _this_or_this_or_this }"
            end
            y  # important, covered
          end
          UNABLE_
        end
      end

      # ==

      Stream_ = -> a, & p do
        Common_::Stream.via_nonsparse_array a, & p  # on stack to move up
      end

      # ==

      COLON_ = ':'
      COLON_BYTE_ = COLON_.getbyte 0
    end
  end
end
# #history: abstracted from the "when" node of the [tmx] map operation
