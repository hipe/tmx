module Skylab::Zerk

  class Magnetics::FormalParameters_via_MethodParameters < ::Class.new  # see [#022.4]

    # (this normalization facility is tracked with :[#fi-037.5.E].)

      # (this is similar to but more specialized than [#br-057])


      Models_ = ::Module.new

      # <-

    Models_::Base_Syntax = superclass
    class Models_::Base_Syntax

      def initialize farg_a
        @farg_a = farg_a
        super()
      end

      # #storypoint-3 for error reporting it is useful to speak in terms of..

      def detect_argument &p  # used by #reflection-API
        @farg_a.detect( & p )
      end

      def to_a
        @farg_a.dup
      end

      def each_argument &p
        @farg_a.each( & p )
      end

      def to_argument_stream
        Stream_[ @farg_a ]
      end

      def fetch_argument_at_index i, &p
        @farg_a.fetch i, &p
      end

      def first_argument
        @farg_a.first
      end

      def index_of_argument *a, &p
        @farg_a.index( * a, & p )
      end

      def argument_term_count
        @farg_a.length
      end

      def argument_slice x
        if x.respond_to? :exclude_end?
          build_slice_from_range x
        else
          @farg_a.fetch x
        end
      end

      alias_method :[], :argument_slice

    private

      def build_slice_from_range range
        @_range_for_dupe_ = range
        r = dupe
        @_range_for_dupe_ = nil
        r
      end

    public

      # #storypoint-4 we once had a `string` method but it was a..

      # ~ #hook-out to #parameter-reflection-API

      def fetch_parameter sym, & else_p

        parm = @farg_a.detect do | prp |
          sym == prp.name_symbol
        end

        if parm then parm else
          (( else_p || -> do
            raise ::KeyError, "argument not found: #{ sym.inspect }"
          end )).call
        end
      end
    end

    # ->

      def initialize ruby_param_a

        a = []

        _cls = Home_::Magnetics::Property_via_PlatformParameter

        ruby_param_a.each do | typ, sym |

          a.push _cls.new( typ, sym )
        end

        super a
      end

      def validate_against_args argv, & wiring_p

        o = Sessions_::Length_Validation.new( & wiring_p )
        o.actual_arguments = argv
        o.formal_arguments = @farg_a
        o.syntax = self
        o.execute
      end

      Sessions_ = ::Module.new
      class Sessions_::Length_Validation

        attr_writer(
          :actual_arguments,
          :formal_arguments,
          :syntax,
        )

        def initialize & wiring_p
          @hooks = My_hooks___[].new( & wiring_p )
        end

        My_hooks___ = Lazy_.call do

          class My_Hooks____

            _attrs = Attributes_actor_.call( self,
              missing: :hook,
              extra: :hook,
              success: :hook,
            )

            _attrs.define_methods self  # ..

            def initialize & wiring_p
              wiring_p[ self ]
            end

            self
          end
        end

        def execute

          __init_valid_range

          __init_relationship_of_actual_arguments_to_valid_range

          if @_range_failure_method_name
            send @_range_failure_method_name
          else
            p = @hooks.__success__handler
            if p
              p[]
            else
              ACHIEVED_
            end
          end
        end

        def __init_valid_range

          # this is a function of the formal arguments only and so it
          # could be memoized somewhere but meh.

          o = Sessions_::Calculate_Range.new
          o.formal_arguments = @formal_arguments
          o.execute
          @_begin_d = o.begin
          @_end_d = o.end
          NIL_
        end

        def __init_relationship_of_actual_arguments_to_valid_range

          @_actual_d = @actual_arguments.length

          @_range_failure_method_name = if @_begin_d > @_actual_d
            :__when_missing
          elsif @_end_d && @_end_d < @_actual_d
            :__when_extra
          end
          NIL_
        end

        def __when_missing

          _farg_a = Actors_::Calculate_missing_formals.new(
            @formal_arguments, @actual_arguments.length ).execute

          _stx = Models_::Base_Syntax.new _farg_a
          _ev = Events_::Missing[ :vertical, _stx, nil, @syntax ]
          @hooks.receive__missing__ _ev
        end

        def __when_extra

          _s_a = @actual_arguments[ @_end_d .. -1 ]
          _ev = Events_::Extra[ _s_a ]
          @hooks.receive__extra__ _ev
        end
      end

      _Stru = Common_::Event.structured_expressive.method :new

      Events_ = ::Module.new

      Events_::Missing = _Stru.call(
        :orientation_i,
        :syntax_slice,
        :any_at_token_set,
        :any_full_syntax,
      )

      Events_::Extra = _Stru.call :s_a do
        def x
          @s_a.fetch 0
        end
      end

      class Sessions_::Calculate_Range

        attr_writer(
          :formal_arguments,
        )

        attr_reader(
          :begin,
          :end,
        )

        def initialize

          @begin = 0
          @_did_see_glob = false
          @end = 0
        end

        def execute

          @formal_arguments.each do | fa |
            send :"__when__#{ fa.reqity_symbol_ }__"
          end
          if @_did_see_glob
            @end = nil
          end
          NIL_
        end

        def __when__opt__
          @end += 1
          NIL_
        end

        def __when__req__
          @begin += 1
          @end += 1
          NIL_
        end

        def __when__rest__
          @_did_see_glob = true
          NIL_
        end
      end

      Actors_ = ::Module.new
      class Actors_::Calculate_missing_formals

        def initialize farg_a, actual_len_d

          @actual_len_d = actual_len_d
          @farg_a = farg_a
          @_missing_term_a = []
          @_num_required_seen_d = 0
        end

        def execute

          @farg_a.each_with_index do | arg, d |
            @_farg = arg
            @_d = d
            send :"__when__#{ arg.reqity_symbol_ }__"
          end
          @_missing_term_a
        end

        def __when__opt__
          NIL_
        end

        def __when__rest__
          NIL_
        end

        def __when__req__
          d = ( @_num_required_seen_d += 1 )
          if d > @actual_len_d
            @_missing_term_a.push Models_::Missed.new( @_d, @_farg )
          end
          NIL_
        end
      end

      class Models_::Missed

        attr_reader(
          :syntax_index,
        )

        def initialize index_d, farg

          @syntax_index = index_d
          @formal_argument = farg
        end

        def reqity_symbol_
          @formal_argument.reqity_symbol_
        end

        def name
          @formal_argument.name
        end
      end
  end
end
