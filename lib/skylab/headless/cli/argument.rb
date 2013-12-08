module Skylab::Headless

  class CLI::Argument   # might be joined by sister CLI::Option one day..

    # read [#135] the CLI argument node narrative #storypoint-1

    def initialize formal, reqity
      @formal, @reqity = formal, reqity
    end

    attr_reader :formal, :reqity

    def as_slug
      @formal.name.as_slug
    end

    def name
      @name ||= Headless::Name::Function.new @formal.normalized_parameter_name
    end

    #  ~ all #hook-out to #parameter-reflection-API

    def normalized_parameter_name  #hook-out to reflection API
      @formal.normalized_parameter_name
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

    module FUN

      Reqity_brackets = {
        opt:  [ '[', ']'      ],
        req:  [ '',  ''       ],
        rest: [ '[', ' [..]]' ],
        req_group: [ '{', '}' ]  # #storypoint-2 block is not represen..
      }.each { |_, a| a.each( & :freeze).freeze }.freeze.method :fetch

    end

    class Syntax  # #abstract-base-class (covered by [#136] test node)

      def self.DSL & p
        self::DSL.DSL_notify_with_p p
      end

      def initialize
        super
      end

      # #storypoint-3 for error reporting it is useful to speak in terms of..

      [ :detect,  # used by reflection API
        :each,    # here
        :first,   # CLI client
        :index,   # here
        :length   # CLI client
      ].each do |i|
        define_method i do |*a, &p|
          @item_a.send i, *a, &p
        end
      end

      def slice x
        if x.respond_to? :exclude_end?
          build_slice_from_range x
        else
          @item_a.fetch x
        end
      end
      alias_method :[], :slice
    private
      def build_slice_from_range range
        x_a = base_args ; item_a = @item_a
        self.class.allocate.instance_exec do
          base_init( * x_a )
          @item_a = item_a[ range ]
          self
        end
      end
    public

      # #storypoint-4 we once had a `string` method but it was a..

      # ~ #hook-out to #parameter-reflection-API

      def fetch_parameter norm_i, & else_p
        parm = @item_a.detect do |x|
          norm_i == x.normalized_parameter_name
        end
        if parm then parm else
          (( else_p || -> do
            raise ::KeyError, "argument not found: #{ norm_i.inspect }"
          end )).call
        end
      end

    private

      # ~ #hook-out's to #dupe-API

      def base_args
        MetaHell::EMPTY_A_
      end

      def base_init
      end

      MetaHell::MAARS::Upwards[ self ]  # because we #stowaway but have childs

      class Inferred < self

        def initialize ruby_param_a, formal_p=nil
          @item_a = ruby_param_a.reduce [] do |m, (opt_req_rest_i, name_i)|
            formal_p and fp = formal_p[ name_i ]
            fp ||= Headless::Parameter.new nil, name_i
            m << CLI::Argument.new( fp, opt_req_rest_i )
          end
          super()
        end

        def process_args arg_a, & event_p
          Validate__.new( self, @item_a, event_p, arg_a ).execute
        end
      end

      Validate = Headless::Parameter::Definer.new do
        param :on_missing, hook: true
        param :on_unexpected, hook: true
        param :on_result_struct, hook: true  # we won't use it but others might
      end

      class Validate__
        def initialize slice_p, item_a, event_p, arg_a
          @arg_a = arg_a ; @item_a = item_a ; @slice_p = slice_p
          @hooks = Validate.new( & event_p )
          @formal_idx = @actual_idx = 0
          @formal_last = @item_a.length - 1
          @actual_last = @arg_a.length - 1
          @result = true
        end
        def execute
          check_for_xtra
          check_for_miss
          @result
        end
      private
        def check_for_xtra
          while @actual_idx <= @actual_last
            visit or break
          end
        end
        def visit
          if @formal_idx > @formal_last
            @result = on_xtra ; STOP__
          elsif :rest == @item_a[ @formal_idx ].reqity
            @formal_idx += 1 ; STOP__  # even when a, *b, c
          else
            @formal_idx += 1 ; @actual_idx += 1 ; PROCEDE__
          end
        end
        STOP__ = false ; PROCEDE__ = true
        def on_xtra
          @hooks.on_unexpected[ Extra_[ @arg_a[ @actual_idx .. -1 ] ] ]
        end
        CLI::Argument::Extra_ = Event_.new :s_a  # [hl]
        def check_for_miss
          @missed_req_idx = if @formal_idx <= @formal_last
            ( @formal_idx .. @formal_last ).detect do |d|
              :req == @item_a[ d ].reqity
            end
          end
          @missed_req_idx and missed_notify ; nil
        end
        def missed_notify  # allow for (*a, b)
          _num_unseen_formal = @formal_last - @formal_idx + 1
          _num_unseen_actual = @actual_last - @actual_idx + 1
          if _num_unseen_formal > _num_unseen_actual
            @result = on_miss
          end ; nil
        end
        def on_miss
          @hooks.on_missing[ Missing_[
            @slice_p[ @missed_req_idx .. -1 ], :vertical] ]
        end
        CLI::Argument::Missing_ = Event_.
          new :argument_a, :orientation, :any_at_token_set
      end
    end
  end
end
