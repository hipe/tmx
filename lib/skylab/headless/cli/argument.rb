module Skylab::Headless

  class CLI::Argument   # might be joined by sister CLI::Option one day..

    # simple wrapper that combines ruby's builtin method.parameters `reqity`
    # with a formal parameter. (`reqity` is a term we straight made up to refer
    # to that property that is either :req, :opt or :rest, as seen in the
    # result structure of ruby's ::Method#parameters.)

    def normalized_parameter_name     # will be queried by reflection api
      @formal.normalized_parameter_name
    end

    attr_reader :formal

    def name
      @name ||= Headless::Name::Function.new @formal.normalized_parameter_name
    end

    def as_slug
      @formal.name.as_slug
    end

    attr_reader :reqity

    #  ~ for #parameter-reflection-API ~

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

    def initialize formal, reqity
      @formal, @reqity = formal, reqity
    end

    FUN = ::Struct.new( :reqity_brackets )[
      -> do
        arg_string_h = {
          opt:  [ '[', ']'      ],
          req:  [ '',  ''       ],
          rest: [ '[', ' [..]]' ],
          req_group: [ '{', '}' ]
          # block: - not represented here. we trigger the error on purpose -
        }.each { |_, a| a.each(& :freeze).freeze }.freeze  # block parameters
                                  # arge not isomorphic
        -> x do
          arg_string_h.fetch x
        end
      end.call ].freeze
  end

  class CLI::Argument::Syntax     # abstract

    MetaHell::MAARS::Upwards[ self ]

    # For error reporting it is useful to speak in terms of sub-slices of
    # argument syntaxes (used at least 2x here). (In fact, this was originally
    # a sub-class of ::Array (eek))  So some of that is mimiced here.

    [
      :detect, # courtesy for reflection api
      :each,   # used here in `render_argument_syntax`, from it we can have etc
      :first,  # for a.s inspection in cli/client
      :index,  # used here
      :length  # in cli/client
    ].each do |m|
      define_method m do |*a, &b|
        @elements.send m, *a, &b
      end
    end

    def slice x
      if x.respond_to? :exclude_end?
        new = self.class.allocate
        ba = base_args ; e = @elements
        new.instance_exec do
          base_init( * ba )
          @elements = e[x]
        end
        new
      else
        @elements.fetch x
      end
    end

    alias_method :[], :slice

    # (we once had a `string` but it was a smell here - pls render it yrself)

    #        ~ reflection API (as a courtesy for experiments) ~

    def fetch_parameter norm_name, &otr
      parm = @elements.detect do |x|
        norm_name == x.normalized_parameter_name
      end
      if parm then parm else
        ( otr || -> { raise ::KeyError,
                      "argument not found: #{ norm_name.inspect }" } ).call

      end
    end

  private

    alias_method :base_init, :initialize

    def base_args                 # compat with our `slice`. add parameters
      []                          # that you want to copy-by-reference to
    end                           # a nerk result of slice

    def self.DSL & p
      self::DSL.DSL_notify_with_p p
    end
  end

  class CLI::Argument::Syntax::Inferred < CLI::Argument::Syntax

    def initialize ruby_param_a, formals=nil
      @elements = ruby_param_a.reduce [] do |m, (opt_req_rest, name)|
        if formals
          fp = formals[ name ]
        end
        fp ||= Headless::Parameter.new nil, name
        m << CLI::Argument.new( fp, opt_req_rest )
      end
      super()
    end

    Validate = Headless::Parameter::Definer.new do
      param :on_missing, hook: true
      param :on_unexpected, hook: true
      param :on_result_struct, hook: true  # we won't use it but others might
    end

    def process_args arg_a, &events  # result is true or hook result
      hooks = Validate.new(& events )
      formal_idx = actual_idx = 0
      formal_end = @elements.length - 1
      actual_end = arg_a.length - 1
      res = true  # important

      while actual_idx <= actual_end
        if formal_idx > formal_end
          res = hooks.on_unexpected[ CLI::Argument::Extra_[
            arg_a[ actual_idx .. -1 ] ] ]
          break
        end
        if :rest == @elements[ formal_idx ].reqity
          formal_idx += 1
          break                   # (regardless of a, *b, c)
        end
        formal_idx += 1
        actual_idx += 1           # (regardless of opt / req)
      end
      # are there any required parameters yet unseen?
      if formal_idx <= formal_end
        unseen_req_idx = ( formal_idx .. formal_end ).detect do |i|
          :req == @elements[i].reqity
        end
      end
      if unseen_req_idx           # below allows for (*a, b)
        num_unseen_formal = formal_end - formal_idx + 1
        num_unseen_actual = actual_end - actual_idx + 1
        if num_unseen_formal > num_unseen_actual
          res = hooks.on_missing[ CLI::Argument::Missing_[
            self[ unseen_req_idx .. -1 ], :vertical ] ]
        end
      end
      res
    end
    #
    CLI::Argument::Extra_ = Headless::Event_.new :s_a
    #
    CLI::Argument::Missing_ = Headless::Event_.
      new :argument_a, :orientation, :any_at_token_set

  end
end
