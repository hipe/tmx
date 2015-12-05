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
                s = Home_.lib_.human::NLP::EN::POS.plural_noun @_header_s
                if s
                  @_header_s = s
                end
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
          self._DECIDE_ME

        elsif cached_tuple

          if @_singularize
            self._YAY_SINGULARIZE
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
        only_one_x = nil

        p = -> line do
          had_none = false
          if @_tight_IFF_one_line
            only_one_x = Callback_::Known_Known[ line ]
            p = -> line_ do
              only_one_x = nil
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
            _express_lone_header_line
            @_line_yielder << line
            p = -> line_ do
              @_line_yielder << line_
            end
          end
        end

        _y = ::Enumerator::Yielder.new do | line |
          p[ line ]
        end

        @_message_yielder_callback[ _y ]

        if had_none
          self._DECIDE_ME
        elsif only_one_x
          _express_tight_first_line only_one_x.value_x
          ACHIEVED_
        else
          ACHIEVED_
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
      # (a simple, hand-written form of a #[#ca-047] eventing articulator.)

      # it is very likely that you want the lifetime of this to coincide
      # exactly to the expression of one screen (or super-section, document,
      # etc.), because visual separation between sections is important and
      # only relevant in the context of one such node (perhaps by definition,
      # see [#002]/figure-3)).

      def initialize y

        @_touch_boundary = EMPTY_P_  # when in the beginning state before
          # anything has ever been emitted, touching this does nothing.

        p = -> ss do
          # the first time ever something (even false-ish) is emitted,
          # then we start maintaining this flip-flop flag

          pending_boundary_to_express = false

          @_touch_boundary = -> do
            pending_boundary_to_express = true ; nil
          end
          y << ss
          p = -> s do
            if pending_boundary_to_express
              pending_boundary_to_express = false
              y << NIL_
            end
            y << s
          end
        end

        @line_yielder = ::Enumerator::Yielder.new do | s |
          p[ s ]
        end
      end

      attr_reader(
        :line_yielder,
      )

      def touch_boundary
        @_touch_boundary[]
      end
    end
  end
end
