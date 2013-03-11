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

    # --- * ---

    fun = Headless::NLP::EN::Minitesimal::FUN

                                  # memoize last counts for shorter strings

    attr_accessor :_nlp_last_length

    define_method :an do |s, x=nil|
      if x
        self._nlp_last_length = x
      else
        x = _nlp_last_length
      end
      fun.an[ s, x ]
    end

    define_method :and_ do |a|
      self._nlp_last_length = a.length
      fun.oxford_comma[ a, ' and ' ]
    end

    define_method :or_ do |a|
      self._nlp_last_length = a.length
      fun.oxford_comma[ a, ' or ' ]
    end

    define_method :s do |length=nil, part=nil|
      args = [length, part].compact
      pt = ::Symbol === args.last ? args.pop : :s
      if args.length.zero?
        len = self._nlp_last_length or raise ::ArgumentError.new 'numeric?'
      else
        x = args.first
        len = ::Numeric === x ? x : x.length # #gigo
        self._nlp_last_length = len
      end
      fun.s[ len, pt ]
    end
  end
end
