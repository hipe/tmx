module Skylab::Brazen

  module CLI_Support

    Section = ::Module.new

    class Section::Expression

      # use the same one for the lifetime of your screen rendering

      def initialize line_yielder, expag

        @_boundarizer = Section::Boundarizer.new line_yielder

        @_expression_agent = expag

        @_line_yielder = @_boundarizer.line_yielder
      end

      def express_section * x_a, & x_p

        dup.__express_section x_a, & x_p
      end

      def express_section_via x_a, & x_p

        dup.__express_section x_a, & x_p
      end

      def __express_section x_a, & message_y_p

        opt = Parse_options___[ x_a ]

        @_header_s = opt.header
        @_message_yielder_callback = message_y_p
        @_pluralize = opt.pluralize
        @_singularize = opt.singularize
        @_wrapped_second_column = opt.wrapped_second_column
        @_tight = opt.tight
        @_tight_IFF_one_line = opt.tight_IFF_one_line

        if @_wrapped_second_column
          ___two_column

        elsif @_header_s
          __one_column

        else
          __raw
        end
      end

      Opts__ = ::Struct.new(
        :header,  # string, typically plural. must not be styled.
        :tight,  # put header and first item on same line. only for 1 col for now
        :tight_IFF_one_line,
        :pluralize,  # ditto below
        :singularize,  # only for use with the next option
        :wrapped_second_column,  # like optparse. pass o.p-esque as an argument.
      )

      _TAKES_ARG = Opts__.new
      _TAKES_ARG[ :header ] = true
      _TAKES_ARG[ :wrapped_second_column ] = true

      _EMPTY_OPTS = Opts__.new.freeze

      Parse_options___ = -> x_a do

        if x_a.length.zero?
          _EMPTY_OPTS
        else
          opts = Opts__.new
          st = Callback_::Polymorphic_Stream.via_array x_a
          begin
            k = st.gets_one
            _x = if _TAKES_ARG[ k ]
              st.gets_one
            else
              true
            end
            opts[ k ] = _x
          end until st.no_unparsed_exists
          opts
        end
      end

      def ___two_column

        # in the streamingest possible way: detect if there was 0 or at least
        # one item. furthermore, IFF `singularize` detect whether there is
        # one or more than one. function soup so that we output each received
        # line as soon as possible given the options.

        op = remove_instance_variable :@_wrapped_second_column
        marg = op.summary_indent
        sw_d = op.summary_width
        op = nil

        first_line_fmt = "#{ marg }%-#{ sw_d }s %s"

        _d = marg.length + sw_d + 1  # " " is 1 char wide

        subsequent_format = "#{ SPACE_ * _d }%s"

        express_tuple = -> a do

          if 1 == a.length
            @_line_yielder << a.fetch( 0 )
          else

            slug, desc_s_a = a

            if ! desc_s_a || desc_s_a.length.zero?
              @_line_yielder << "#{ marg }#{ slug }"
            else
              @_line_yielder << ( first_line_fmt % [ slug, desc_s_a[0] ] )
              ( 1 ... desc_s_a.length ).each do | d |
                @_line_yielder << ( subsequent_format % desc_s_a.fetch(d) )
              end
            end
          end
        end

        cached_tuple = nil
        had_none =  true
        p = -> tuple do
          had_none = false
          if @_singularize || @_pluralize
            cached_tuple = tuple
            p = -> tuple_ do

              if @_pluralize
                _change_header_to_plural
              end

              _express_lone_header_line
              express_tuple[ cached_tuple ]
              cached_tuple = nil
              express_tuple[ tuple_ ]
              p = express_tuple
              NIL_
            end
          else
            p = express_tuple
            p[ tuple ]
          end
        end

        _y = ::Enumerator::Yielder.new do | * one_or_two |
          p[ one_or_two ]
        end

        @_message_yielder_callback[ _y ]

        if had_none
          NOTHING_  # don't display header. let client know there is none. [ze]

        elsif cached_tuple

          if @_singularize
            _change_header_to_singular
          end

          _express_lone_header_line
          express_tuple[ cached_tuple ]
          ACHIEVED_
        else
          ACHIEVED_
        end
      end

      def __one_column

        # we do this functionally so that it is the streamingest it can be
        # (that is, we don't needelssly cache all lines before outputting)

        had_none = true
        plain_one = nil
        tight_one = nil

        p = -> line do
          had_none = false
          if @_tight_IFF_one_line
            tight_one = Callback_::Known_Known[ line ]
            p = -> line_ do
              tight_one = nil
              _express_lone_header_line
              p = -> line__ do
                @_line_yielder << line__
              end
              p[ line ]
              p[ line_ ]
            end
          elsif @_tight
            _express_tight_first_line line
            margin = SPACE_ * ( @_header_s.length + HEADER_COLON_LENGTH___ )
            p = -> line_ do
              @_line_yielder << "#{ margin }#{ line_ }"
            end
          else
            plain_one = line
            p = -> line_ do
              p = -> line__ do
                @_line_yielder << line__
              end
              if @_pluralize
                self._YAY_plain_pluralize
              end
              _express_lone_header_line
              p[ plain_one ]
              plain_one = nil
              p[ line_ ]
            end
          end
        end

        _y = ::Enumerator::Yielder.new do | line |
          p[ line ]
        end

        @_message_yielder_callback[ _y ]

        if had_none
          self._DECIDE_ME
        elsif tight_one
          _express_tight_first_line tight_one.value_x
          ACHIEVED_
        elsif plain_one
          if @_singularize
            _change_header_to_singular
          end
          _express_lone_header_line
          @_line_yielder << plain_one
        else
          ACHIEVED_
        end
      end

      def _change_header_to_singular

        s = Home_.lib_.human::NLP::EN::POS.singular_noun @_header_s
        if s
          @_header_s = s ; nil
        end
      end

      def _change_header_to_plural

        s = Home_.lib_.human::NLP::EN::POS.plural_noun @_header_s
        if s
          @_header_s = s ; nil
        end
      end

      def _express_lone_header_line

        @_boundarizer.touch_boundary

        header = @_header_s

        _ = @_expression_agent.calculate do
          "#{ hdr header }"
        end

        @_line_yielder << _
        NIL_
      end

      def _express_tight_first_line line

        @_boundarizer.touch_boundary

        header = @_header_s

        _ = @_expression_agent.calculate do
          "#{ hdr header }#{ HEADER_COLON__ }#{ line }"  # :[#072].
        end

        @_line_yielder << _
        NIL_
      end

      def __raw

        # the client is going to output any "something". we don't really
        # care what it is or whether there is any, we only have to mark
        # the boundary. to be consistent our result is etc.

        @_boundarizer.touch_boundary

        did = nil
        p = -> xx do
          did = true
          p = -> x do
            @_line_yielder << x
          end
          p[ xx ]
        end

        _y = ::Enumerator::Yielder.new do | x |
          p[ x ]
        end

        @_message_yielder_callback[ _y ]

        did
      end

      HEADER_COLON__ = ': '
      HEADER_COLON_LENGTH___ = HEADER_COLON__.length
    end

    class Section::Boundarizer

      # a stateful filter in front of the client's info line yielder that
      # allows us to "mark" where there should possibly be a blank line to
      # separate each "section" (whatever "section" means to us), while
      # freeing us from having to track the cases of whether we are at the
      # very beginning or whether the preceding section(s) had no cotent.
      # (a simple, hand-written form of a #[#hu-053] eventing expresser.)

      # it is very likely that you want the lifetime of this to coincide
      # exactly to the expression of one screen (or super-section, document,
      # etc.), because visual separation between sections is important and
      # only relevant in the context of one such node (perhaps by definition,
      # see [#002]/figure-3)). (or call `clear` between "screens" to re-use
      # this same boundarizer.)

      def initialize y

        has_visible_content = normal_touch_boundary = p = nil
        on_next_line_express_a_boundary = nil
        when_at_top = when_in_middle = nil

        @_clear = -> do

          # when at the top of the "screen" (or whatever it is), you haven't
          # outputted anything at all yet, so you do *not* want a boundary
          # touch to cause the next outputted line to have a separtor line
          # before it (part of the point of all this) ..

          @_touch_boundary = EMPTY_P_
          p = when_at_top

          NIL_
        end

        when_at_top = -> s do
          # for the zero or more top-anchored empty lines and
          # any first non-empty line:

          if has_visible_content[ s ]

            # then state change: now we *do* pay attention to these:

            @_touch_boundary = normal_touch_boundary
            p = when_in_middle
          end

          y << s
          NIL_
        end

        has_visible_content = -> s do
          s && VISIBLE_CONTENT_RX___ =~ s
        end

        normal_touch_boundary = -> do
          on_next_line_express_a_boundary = true ; nil
        end

        when_in_middle = -> s do

          if on_next_line_express_a_boundary

            on_next_line_express_a_boundary = false  # regardless of below

            if has_visible_content[ s ]
              y << EMPTY_S_  # output a blank line of our own IFF this. otherwise:
            end

            # if the received string has no visible content, we assume both
            # that it will appear as a blank line below and that expressing
            # our own blank line would create an unintended redundancy.
          end

          y << s
        end

        @line_yielder = ::Enumerator::Yielder.new do | s |
          p[ s ]
        end

        @_clear.call
      end

      VISIBLE_CONTENT_RX___ = /[^[:space:]]/

      attr_reader(
        :line_yielder,
      )

      def touch_boundary
        @_touch_boundary[]
      end
    end
  end
end
# #pending-rename
