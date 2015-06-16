module Skylab::Headless

  class CLI::Argument_   # might be joined by sister CLI::Option one day..

    # read [#135] the CLI argument node narrative #storypoint-1

    class << self

      def reqity_brackets i
        Reqity_brackets__[ i ]
      end

      def syntax * a
        if a.length.zero?
          Syntax__
        else
          Syntax__.new( * a )
        end
      end

      def missing i, a, set
        Missing_[ i, a, set ]
      end
    end

    def initialize formal, reqity
      @fprm = formal ; @reqity = reqity ; nil
    end

    attr_reader :reqity

    def formal
      @fprm
    end

    def as_slug
      @fprm.name.as_slug
    end

    def name
      @name ||= Callback_::Name.via_variegated_symbol @fprm.normalized_parameter_name
    end

    #  ~ all #hook-out to #parameter-reflection-API

    def normalized_parameter_name  #hook-out to reflection API
      @fprm.normalized_parameter_name
    end

    def is_argument
      true
    end

    def is_option
      false
    end

    def is_atomic_variable
      true
    end

    def is_collection
      false
    end


    Reqity_brackets__ = {
      opt:  [ '[', ']'      ],
      req:  [ '',  ''       ],
      rest: [ '[', ' [..]]' ],
      req_group: [ '{', '}' ]  # #storypoint-2 block is not represen..
    }.freeze.each_value do |a|
      a.freeze.each( & :freeze )
    end.method :fetch


    class Syntax__  # (in Arg) #abstract-base-class

      class << self

        def DSL & p
          self::DSL__.receive_p  p
        end

        def isomorphic * a
          if a.length.zero?
            Isomorphic__
          else
            Isomorphic__.new( * a )
          end
        end

        def validate
          Validate__
        end
      end

      def initialize farg_a
        @farg_a = farg_a
        super()
      end

      # ~ :[#sl-146] custom implementation (just for getting slices)
    private
      def dupe
        dup
      end
      def initialize_copy otr
        init_copy( * otr.get_args_for_copy ) ; nil
      end
    protected
      def get_args_for_copy
        [ @farg_a, @_range_for_dupe_ ]
      end
    private
      def init_copy farg_a, range
        @farg_a = farg_a[ range ] ; nil
      end
      # ~
    public

      # #storypoint-3 for error reporting it is useful to speak in terms of..

      def detect_argument &p  # used by #reflection-API
        @farg_a.detect( & p )
      end
      def to_a
        [ * @farg_a ]
      end
      def each_argument &p
        @farg_a.each( & p )
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

      def fetch_parameter norm_i, & else_p
        parm = @farg_a.detect do |x|
          norm_i == x.normalized_parameter_name
        end
        if parm then parm else
          (( else_p || -> do
            raise ::KeyError, "argument not found: #{ norm_i.inspect }"
          end )).call
        end
      end

    private

      Autoloader_[ self ]  # we are a #stowaway but we have childs that need a.l

      class Isomorphic__ < self  # in Syntax__

        def initialize ruby_param_a, formal_p=nil
          _farg_a = ruby_param_a.reduce [] do |m, (opt_req_rest_i, name_i)|
            formal_p and fp = formal_p[ name_i ]
            fp ||= Headless_::Parameter.new nil, name_i
            m.push CLI.argument( fp, opt_req_rest_i )
          end
          super _farg_a
        end

        def process_args farg_a, & event_p
          Isomorphic_Validate__.new( @farg_a, event_p, farg_a, self ).execute
        end
      end

      Validate__ = Headless_::Parameter::Definer.new do
        param :on_missing, hook: true
        param :on_extra, hook: true
        param :on_result_struct, hook: true  # we won't use it but others might
      end

      class Isomorphic_Validate__  # in Syntax__
        def initialize farg_a, event_p, act_a, stx
          @act_a = act_a ; @farg_a = farg_a
          @hooks = Validate__.new( & event_p ) ; @stx = stx ; nil
        end
        def execute
          calculate_valid_range
          if actual_d_is_within_range
            PROCEDE__
          else
            emit_missing_or_extra
          end
        end
        STOP__ = false ; PROCEDE__ = true
      private
        def calculate_valid_range # #todo consider caching? meh. silly! CLI.
          c = Range_Calcuation__.new @farg_a
          @begin_d = c.begin ; @end_d = c.end ; nil
        end
        def actual_d_is_within_range
          @actual_d = @act_a.length
          ! if @begin_d > @actual_d
            @condition_i = :when_missing
          elsif @end_d and @end_d < @actual_d
            @condition_i = :when_extra
          end
        end
        def emit_missing_or_extra
          send @condition_i
        end
        def when_missing
          _farg_a = Missing_Calculation__.new( @farg_a, @act_a.length ).execute
          _stx = Syntax__.new _farg_a
          _ev = Missing_[ :vertical, _stx, nil, @stx ]
          @hooks.on_missing[ _ev ]
        end
        def when_extra
          _s_a = @act_a[ @end_d .. -1 ]
          _ev = Extra_[ _s_a ]
          @hooks.on_extra[ _ev ]
        end
      end  # in Syntax__
    end # in Argument
    Missing_ = Headless_::Event.
      new :orientation_i, :syntax_slice, :any_at_token_set, :any_full_syntax

    Extra_ = Headless_::Event.new :s_a  # :#API-private (and above)

    class CLI::Argument_

      class Syntax__

        class Range_Calcuation__
          def initialize farg_a
            @begin = 0 ; @end = 0 ; @did_see_glob = false
            farg_a.each do |arg|
              send arg.reqity
            end
            @did_see_glob and @end = nil ; nil
          end
          attr_reader :begin, :end
        private
          def req ; @begin += 1 ; @end += 1 end
          def opt ; @end += 1 end
          def rest ; @did_see_glob = true end
        end

        class Missing_Calculation__
          def initialize farg_a, actual_len_d
            @actual_len_d = actual_len_d
            @missing_term_a = [] ; @num_required_seen_d = 0
            farg_a.each_with_index do |arg, d|
              @farg = arg ; @d = d
              send arg.reqity
            end ; nil
          end
          def execute
            @missing_term_a
          end
        private
          def opt ;  end
          def rest ; end
          def req
            ( @num_required_seen_d += 1 ) > @actual_len_d and record
          end
          def record
            @missing_term_a <<  Missed__.new( @d, @farg ) ; nil
          end
        end
      end

      class Missed__ < self  # in Argument
        def initialize index_d, argument
          @syntax_index_d = index_d
          super argument.formal, argument.reqity ; nil
        end
        attr_reader :syntax_index_d
      end
    end
  end
end
