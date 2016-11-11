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
        # #cover-me

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

      class When::UnknownBranchItem

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
          @available_item_name_stream_by = nil
          @strange_value_by = nil
        end

        attr_writer(
          :available_item_name_stream_by,
          :listener,
          :shape_symbol,
          :strange_value_by,
          :terminal_channel_symbol,
        )

        def execute

          available_item_name_stream_by = @available_item_name_stream_by  # any
          shape_sym = @shape_symbol
          strange_value_by = @strange_value_by

          _tcs = @terminal_channel_symbol

          @listener.call :error, :expression, :parse_error, _tcs do |y|

            if strange_value_by

              case shape_sym
              when :primary ; buffer = "unknown primary"
              when :business_branch_item ; buffer = "unknown item"
              end

              s = say_strange_branch_item strange_value_by[]
              if COLON_BYTE_ != s.getbyte(0)
                buffer << COLON_
              end
              buffer << SPACE_
              buffer << s
              y << buffer
              buffer = ""
            else

              case shape_sym
              when :primary ; buffer = "missing required primary: "
              when :business_branch_item ; buffer = "missing required argument: "
              end
            end

            if available_item_name_stream_by

              _available_name_st = available_item_name_stream_by[]

              case shape_sym
              when :primary
                _this_or_this_or_this = say_primary_alternation_ _available_name_st
              when :business_branch_item
                _this_or_this_or_this = say_business_branch_item_alternation_ _available_name_st
              end

              buffer << "expecting #{ _this_or_this_or_this }"
              y << buffer
            end

            y  # important, covered
          end

          UNABLE_
        end
      end

      # ==

      COLON_ = ':'
      COLON_BYTE_ = COLON_.getbyte 0
    end
  end
end
# #history: abstracted from the "when" node of the [tmx] map operation
