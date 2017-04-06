module Skylab::Zerk

  module ArgumentScanner

    module WhenScratchSpace____

      class When::UnknownBranchItem < Home_::MagneticBySimpleModel  # 1x

        # :[#fi-037.5.O]

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
            @available_item_internable_stream_by = nil
            @primary_channel_symbol = nil
            @strange_value_by = nil
            @talker = nil
            yield self
            freeze
          end

          attr_accessor(
            :available_item_internable_stream_by,
            :listener,
            :primary_channel_symbol,
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

            _primary = @primary_channel_symbol || :error
            head = [ _primary, :expression, :parse_error ]
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
            @available_item_internable_stream_by
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
            @available_item_internable_stream_by
          end

          def say_unknown_item

            case @shape_symbol
            when :primary
              buffer = "unknown primary"
              colon = :no
            when :business_item
              buffer = "unknown item"
              colon = :yes
            else
              fail
            end

            _say_unknown_item_smart_prefixed buffer, colon
          end

          def express_unknown_item_smart_prefixed buffer
            @_yielder_ << _say_unknown_item_smart_prefixed( buffer, :maybe )
          end

          def _say_unknown_item_smart_prefixed buffer, colon

            if buffer.frozen?
              buffer = buffer.dup
            end

            x = @strange_value_by[]
            s = @_expression_agent_.calculate do
              ick_oper x  # formerly `say_strange_branch_item` #history-B
            end

            case colon
            when :yes
              buffer << COLON_
            when :maybe
              if ADD_A_COLON_IF_RX___ =~ s  # see
                buffer << COLON_
              end
            when :no
              NOTHING_
            else ; never
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
            case @shape_symbol
            when :primary
              __say_splay_when_primary
            when :business_item
              __say_splay_when_business
            else ; no
            end
          end

          def __say_splay_when_primary

            # we can't use our ordinary rendering technique because splays
            # such at these sometimes are not simply oxford joins. not all
            # expession agents have this (at writing).
            #

            available_internable_st = @available_item_internable_stream_by[]

            @_expression_agent_.calculate do

              say_primary_alternation_ available_internable_st
            end
          end

          def __say_splay_when_business

            # (there might be a desire to "chuck down on the bat" here and
            # expose an API that lets you have more control of how items
            # are expressed. but for now we map them to symbols and use a
            # hard-coded method..)

            # (also there will probably eventually be a desire to levenshtein here)

            available_internable_st = @available_item_internable_stream_by[]

            No_deps_zerk_[]
            _sym_scn = ::NoDependenciesZerk::Scanner_by.new do
              item = available_internable_st.gets
              if item
                item.intern
              end
            end

            good_m = :oper  # as long as it works ..

            @_expression_agent_.calculate do

              simple_inflection do
                oxford_join_do_not_store_count "", _sym_scn, " or " do |sym|
                  send good_m, sym
                end
              end
            end
          end

          attr_reader(
            :_expression_agent_,
            :_yielder_,
          )
        end
      end

      # ==

      # kinky new guidelines for when to use a colon:
      #
      # generally we use a colon to separate a descriptive noun phrase
      # from the referrant being described:
      #
      #      never:  'number is too large 10'
      #     better:  'number is too large: 10'
      #
      # but if a colon would precede any other colon, typically we avoid it:
      #
      #     zoiks:   'unexpected symbol: :sym_sym'
      #     better:  'unexpected symbol :sym_sym'
      #
      # generally we *do* use a colon for strange business values:
      #
      #     worse:  'unexpected token "foo"'
      #     better: 'unexpected token: "foo"'
      #
      #     even:   'unexpected value: :sym'  # but we're not sure
      #
      # but don't use a colon if the noun is a familiar, commonly used
      # noun of one of the "operators" (primary or operation name):
      #
      #     worse:  'unexpected primary: "-foo". did you mean..'
      #     better: 'unexpected primary "-foo". did you mean..'
      #
      #
      # discussion: probably the strongest design objective here is avoiding
      # semantic redundancy. another strong one is that what we call "ick"-
      # style noun phrases must have some kind of diacritical markings to
      # set them apart from plain language..

      ADD_A_COLON_IF_RX___= /\A(?!
        :  # don't add another colon if a colon is present
        #  # do add a colon if the "ick" starts with a single quote
        #  # do add a colon if the "ick" stars with a double quote
      )/x

      # ==
    end
  end
end
# :#history-B (probably temporary)
# #history: broke out from main "when" node
