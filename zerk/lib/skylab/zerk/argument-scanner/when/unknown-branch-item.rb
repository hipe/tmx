module Skylab::Zerk

  module ArgumentScanner

    module WhenScratchSpace____

      class When::UnknownBranchItem < Home_::SimpleModel_  # 1x

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
        #   - see simpler `When::Unknown_operator` and friends

        # -

          def initialize
            @available_item_name_stream_by = nil
            @strange_value_by = nil
            @talker = nil
            yield self
            freeze
          end

          attr_accessor(
            :available_item_name_stream_by,
            :listener,
            :shape_symbol,
            :strange_value_by,
            :talker,
            :terminal_channel_symbol,
          )

          def execute
            t = @talker
            if t
              p = t.emit_idea_by
            end
            if p
              p[ self ]
            else
              emit_normally
            end
          end

          def emit_normally
            _i_a = get_channel
            me = self
            @listener.call( * _i_a ) do |y|
              me.to_expression_into_under( y, self ).express_normally
            end
            UNABLE_
          end

          def get_channel

            head = [ :error, :expression, :parse_error ]
            head.push @terminal_channel_symbol  # ..
            head
          end

          def to_expression_into_under y, expag

            dup.extend( ExpressionMethods___ ).__init_for_expression_ y, expag
          end

          def is_about_unknown_item
            @strange_value_by
          end

          def is_about_expecting
            @available_item_name_stream_by
          end

          def category_symbol
            :unknown_branch_item
          end

        # -

        module ExpressionMethods___

          def __init_for_expression_ y, expag
            @_expression_agent_ = expag
            @_yielder_ = y
            freeze
          end

          def express_via_template tmpl_s

            _tmpl_cls = Basic_[]::String::Template
            _tmpl = _tmpl_cls.via_string tmpl_s

            _big_string = _tmpl.express_into_against "", self

            @_yielder_ << _big_string
          end

          def fetch k
            if respond_to? k
              send k
            else
              yield
            end
          end

          def express_normally

            if is_about_unknown_item
              express_unknown_item

            elsif is_about_expecting
              express_expecting_items

            else
              self._REVIEW
              express_as_missing_required
            end
          end

          def express_as_missing_required
            @_yielder_ << say_missing_required_item
          end

          def say_missing_required_item
            case @shape_symbol
            when :primary
              "missing required primary: "
            when :business_item
              "missing required argument: "
            else
              fail
            end
          end

          def express_unknown_item

            buffer = say_unknown_item

            if can_say_splay

              __express_splay_complicatedly buffer

            else
              @_yielder_ << buffer
            end
          end

          def __express_splay_complicatedly buffer

            # to be extra cute and because we're shoehorning 2 diff use cases,
            # if the would-be second line's length is longer than the would-be
            # first line by some threshold, put them on two line otherwise put
            # them on one. (this is more or less the idea)

            d = buffer.length
            buffer << DOT_
            buffer << SPACE_
            d3 = buffer.length

            express_expecting_items_into buffer

            dist2 = buffer.length - d

            if ( 1.5 * d ) >= dist2
              @_yielder_ << buffer
            else
              @_yielder_ << buffer[ 0, d ]
              @_yielder_ << buffer[ d3 .. -1 ]
            end
          end

          def can_say_splay
            @available_item_name_stream_by
          end

          def say_unknown_item

            _buffer = case @shape_symbol
            when :primary
              "unknown primary"
            when :business_item
              "unknown item"
            else
              fail
            end

            say_unknown_item_smart_prefixed _buffer
          end

          def express_unknown_item_smart_prefixed buffer
            @_yielder_ << say_unknown_item_smart_prefixed( buffer )
          end

          def say_unknown_item_smart_prefixed buffer

            if buffer.frozen?
              buffer = buffer.dup
            end

            x = @strange_value_by[]
            s = @_expression_agent_.calculate do
              say_strange_branch_item x
            end

            if COLON_BYTE_ != s.getbyte(0)
              buffer << COLON_
            end
            buffer << SPACE_
            buffer << s
            buffer
          end

          def express_expecting_items

            express_expecting_items_into @_yielder_
          end

          def express_expecting_items_into buffer

            _ = say_splay

            buffer << "expecting #{ _ }"
          end

          def say_splay

            available_name_st = @available_item_name_stream_by[]

            sym = @shape_symbol

            @_expression_agent_.calculate do
              case sym
              when :primary
                say_primary_alternation_ available_name_st
              when :business_item
                say_business_item_alternation_ available_name_st
              end
            end
          end

          attr_reader(
            :_expression_agent_,
            :_yielder_,
          )
        end
      end
    end
  end
end
# #history: broke out from main "when" node
