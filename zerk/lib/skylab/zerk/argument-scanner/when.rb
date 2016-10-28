module Skylab::Zerk

  module ArgumentScanner

    When = ::Module.new

    module WhenScratchSpace____

      class When::MissingRequireds

        def initialize x_a, as

          @operation_path = nil
          @tuples = []

          scn = Common_::Polymorphic_Stream.via_array x_a
          @_scn = scn
          begin
            send PRIMARIES___.fetch( @_scn.gets_one )
          end until scn.no_unparsed_exists
          remove_instance_variable :@_scn

          @client = as
        end

        PRIMARIES___ = {
          missing: :__parse_missing,
          operation_path: :__parse_operation_path,
        }

        def __parse_operation_path
          x = @_scn.gets_one
          @operation_path = ::Array.try_convert( x ) || [x] ; nil
        end

        def __parse_missing
          @tuples.push @_scn.gets_one ; nil
        end

        def execute

          op_path = @operation_path
          tuples = @tuples

          @client.listener.call(
            :error, :expression, :operation_parse_error, :missing_required_arguments
          ) do |y|

            subsequent_say = nil

            say = -> is_plural, subject_s, primary_s do

              _name = Common_::Name.via_variegated_symbol op_path.last   # meh
              _op = say_formal_component_ _name

              say = subsequent_say
              y << "can't #{ _op } without #{ subject_s }. (maybe use #{ primary_s }.)"
            end

            subsequent_say = -> is_plural, subject_s, primary_s do
              y << "also, must have #{ subject_s }. (maybe use #{ primary_s }.)"
            end

            st = Stream_[ tuples ]
            begin
              tuple = st.gets
              tuple || break

              singplur, subject_s, use_keyword, use_what = tuple

              :use == use_keyword || fail

              _name = Common_::Name.via_variegated_symbol use_what

              _moniker = say_primary_ _name

              _is_plural = IS_PLURAL___.fetch singplur  # not used for now but check anyway

              say[ _is_plural, subject_s, _moniker ]
              redo
            end while above
            y
          end

          UNABLE_
        end

        # ==
        IS_PLURAL___ = {
          is_plural: true,
          is_singular: false,
        }
        # ==
      end

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
