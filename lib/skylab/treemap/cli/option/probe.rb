module Skylab::Treemap

  module CLI::Option::Probe
  end

  class CLI::Option::Probe::OptionParser
    # a recorder for option parser definitions

    def on *a, &b
      @option_definition_queue << [ *a, b ]
    end

    empty_a = [ ].freeze

    define_method :more do |_|    # compat. with the experimental `more`
      empty_a                     # service that manages long option descs
    end                           # for now we /dev/null this

    def separator *a              # compat with the ::optionparser opt
    end

    # --*--

    def absorb option_syntax_block
      @param_h_recorder.mode = :defaults
      instance_exec @param_h_recorder, &option_syntax_block
      @param_h_recorder.mode = :arguments
      while parts = @option_definition_queue.shift
        option(* parts )
      end
      nil
    end

  protected

    def initialize option_box
                                  # (in the order they are used)
      @default_h = { }
      @param_h_recorder =
        CLI::Option::Probe::Param_H.new @default_h
      @option_definition_queue = [ ]
      @option_box = option_box
    end

    def error msg
      fail msg                    # we would likely want to soften some of these
      false
    end

    describe = -> a do
      aa = a.reduce( [] ) do |m, x|
        m << x if ::String === x && '-' == x[0]
        m
      end
      ( aa.length.nonzero? ? aa : a ).join ', '
    end

    define_method :option do |*args, block|
      res = false
      begin
        block or fail "option reflection not implemented for option #{
          }definitions without a block (#{ args.inspect })"

        # note we are calling the block as if the option were being parsed,
        # but all we really want to know is what key is used, so hopefully
        # the param_h is used in a straightforward manner there! HACK!!

        block[ * block.arity.abs.times.map{ nil } ]
        key = @param_h_recorder.last_key
        if ! key
          error "block did not set a value in options hash in definition #{
            }for #{ describe[ args ]}"
          break
        end
        if @default_h.key? key
          ::Hash === args.last and fail 'implement me'
          args.push default: @default_h[ key ]
        end
        opt = CLI::Option.build_from_args(
          args, key, -> e { error e } )
        opt or break
        existing = @option_box.fetch_by_normalized_name(
          opt.normalized_name ) { }
        if existing
          if existing.render_long != opt.render_long
            break( error "redifinition of #{ opt.render } did not #{
              }match: #{ existing.render_long } vs. #{ opt.render_long }" )
          end
        else
          @option_box.add opt
        end
        res = true
      end while nil
      res
    end
  end

  class CLI::Option::Probe::Param_H
    # this is necessarily a modal recorder - we want to do different things
    # with the values we receive based on what mode we are in.

    def []= k, v
      @set[ k, v ]
    end

    def [] k
      @get[ k ]
    end

    attr_reader :last_key

    def mode= mode
      if mode != @mode
        @mode_h.fetch( mode ).call
        @mode = mode
      end
      mode
    end

  protected

    def initialize default_h
      default_set = -> k, v { default_h[k] = v }
      default_get = -> k    { default_h[k] }

      argument_set = -> k, v { @last_key = k ; v }
      argument_get = -> k { fail 'sanity - you could but do you want to?' }

      @mode = :initialized
      @mode_h = {                 # in order of operation
        defaults: -> do
          @set = default_set
          @get = default_get
          nil
        end,
        arguments: -> do
          @set = argument_set
          @get = argument_get
          nil
        end
      }
      @last_key = nil
    end
  end
end
