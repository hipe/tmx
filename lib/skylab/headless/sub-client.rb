module Skylab::Headless

  module SubClient
    # this used to be more complicated, but you see what it has become now
  end

  module SubClient::InstanceMethods
    # **NOTE** the below are not all unobtrusive and auto-vivifying like
    # some i.m modules try to be. The participating object _must_ call
    # `init_headless_sub_client`

  protected

    def initialize request_client # this is the heart of it all [#004] (see)
      block_given? and raise ::ArgumentError.new 'blocks are not honored here'
      init_headless_sub_client request_client
      super(   )
    end

    #         ~ getting and setting the request client ~

    def init_headless_sub_client request_client
      @error_count = 0            # (if this overwrites an important nonzero
                                  # value here, you deserve whatver happens
                                  # to you. why would u call init 2x?)
      self.request_client = request_client  # (some environments employ
    end                           # alternatives to the ivar for storing r.c)

    attr_writer :request_client

    def request_client
      @request_client or begin
        caller_a = caller
        md = Headless::FUN.call_frame_rx.match caller_a[ 0 ]
        desc = if md
          if 0 == md[:meth].index( 'block ' )
            pth = md[:path]
            pth.sub! %r|\A#{ ::Regexp.escape ::Skylab.dir_pathname.to_s }/|, ''
            " in block at #{ pth }:#{ md[:no] }"
          else
            " of `#{ md[:meth] }`"
          end
        end
        fail "#{ self.class } cannot delegate call#{ desc } #{
          }upwards to request client - request client is human (#{
          }do you need to implement it for that class)?"
      end
    end

    #         ~ an alphabetical list of things ~

    def actual_parameters         # not all stacks use this, just convenience
      request_client.send :actual_parameters
    end

    def emit *a                   # (don't get into the habbit of expecting
      request_client.send :emit, *a # meaninful results from `emit` --
      nil                         # it's just never a good idea.  ever.)
    end

    def error s                   # be extra careful around methods that
      @error_count += 1           # affect or are expected to affect the
      emit :error, s              # validity of your sub-client!
      false                       # this implementation is the result of a
    end                           # "perfect abstraction" but may still cause
                                  # you pain if you're not careful.

    attr_reader :error_count      # there is no absolutely no guarantee that
                                  # that out of the box this is reflective
                                  # of anything that you think it is.  caution!

    def escape_path x             # (this is the closing of [#hl-031])
      request_client.send :escape_path, x
    end

    def io_adapter                # sometimes sub-clients need access to
      request_client.send :io_adapter # the streams, e.g. the instream
    end

    def info s                    # provided as a convenience for this
      emit :info, s               # extremely common implementation
      nil
    end

    def parameter_label x, *rest  # [#036] explains it all
      request_client.send :parameter_label, x, *rest
    end

    def payload x                 # provided as a convenience for this common
      emit :payload, x            # emitter "macro" -- not all sub-clients
      nil                         # will necessarily emit this.
    end

    def pen
      request_client.send :pen
    end

    # --- * ---

    def em s ; pen.em s end       # style for emphasis

    def human_escape s ; pen.human_escape s end  # usu. add quotes conditonally

    def hdr s ; pen.hdr s end     # style as a header

    def h2  s ; pen.h2  s end     # style as a smaller header

    def ick s ; pen.ick s end     # style a usu. user-entered x that is invalid

    def kbd s ; pen.kbd s end     # style e.g keyboard input or code

    def omg s ; pen.omg s end     # style an error emphatically

  end

  SubClient::EN_FUN = -> do

    # things about nlp here: 1) we put our nlp-ish subclient instance methods
    # *first* in a struct-box and then distribute the definitions to this i.m
    # module so that a) they can be re-used elsewhere independent of s.c but
    # b) our ancester chain doesn't get annoyingly long. 2) for those nlp
    # functions that inflect based on number (most of them) what we do here
    # different from our downstream (dependees) is we memoize the last used
    # numeric expressors (for the 'number' grammatical category) so that they
    # don't need to be re-submitted as arguments for subsequent utterance
    # producers, for shorter, more readable utterance templates.
    #
    # `numerish` below means "more broad than numeric" e.g an array is
    # numerish because we can derive a numeric property from it - its length.
    # also a `numerish` might hold `nil` or `false` which variously
    # may have special meanings (e.g `nil` might tell a function "substitute
    # some default for `nil`) whereas `false` might mean "substitute a default
    # iff this is is a terminal node in the callstack, otherwise propagate
    # the value `false`).

    o = MetaHell::Formal::Box::Open.new

    bump_numerish = fun = nil

    o[:an] = -> lemma, numerish=false do
      instance_exec numerish, -> nmrsh do
        fun[].an[ lemma, nmrsh ]
      end, & bump_numerish
    end

    o[:_non_one] = -> numerish=nil do  # for nlp hacks, leading space iff not 1
      instance_exec numerish, -> nmrsh do
        " #{ nmrsh }" if 1 != nmrsh
      end, & bump_numerish
    end

    -> do  # `s`
      o[:s] = -> * args do  # [length] [lexeme_sym]
        numerish, lexeme_sym = MetaHell::FUN.parse_series[ args,
          -> x { ! x.respond_to? :id2name }, # defer it
          -> x { x.respond_to? :id2name } ]
        lexeme_sym ||= :s  # when `numerish` is nil it means "use memoized"
        instance_exec numerish, -> num do
          fun[].s[ num, lexeme_sym ]
        end, & bump_numerish
      end
    end.call

    bump_numerish = -> numerish_x, func do
      if numerish_x
        if numerish_x.respond_to? :length
          numerish = numerish_x.length
        else
          numerish = numerish_x
        end
        set_nlp_last_length numerish
      elsif false == numerish_x
        numerish = false
      else
        numerish = self.nlp_last_length
      end
      instance_exec numerish, &func
    end

    o[:nlp_last_length] = -> do
      @nlp_last_length
    end

    o[:set_nlp_last_length] = -> x do   # (because to_struct creates getters
      @nlp_last_length = x              # and setters for each of its methods
    end                                 # you can't have your nerk end with '=')

    memoize_length = -> f do
      -> a do
        set_nlp_last_length a.length
        instance_exec a, &f
      end
    end

    o[:and_] = memoize_length[ -> a do
      fun[].oxford_comma[ a, ' and ' ]
    end ]

    o[:_and] = -> a do  # (when you want the leading space conditionally on etc)
      x = self.and_ a
      x and " #{ x }"
    end

    o[:or_] = memoize_length[ -> a do
      fun[].oxford_comma[ a, ' or ' ]
    end ]


    fun = -> do
      # ( we've got to lazy-load it b.c of a circular dependency in the files )
      x = Headless::NLP::EN::Minitesimal::FUN
      fun = -> { x }
      x
    end

    o.to_struct

  end.call


  module Headless::SubClient::InstanceMethods

    Headless::SubClient::EN_FUN.each do |method_name, body|
      define_method method_name, &body
      protected method_name
    end
  end
end
