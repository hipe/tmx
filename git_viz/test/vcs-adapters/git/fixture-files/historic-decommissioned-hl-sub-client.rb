module Skylab::Headless::SubClient

  Home_ = ::Skylab::Headless

  include Home_

  class << self

    def expression_agent
      Expression_Agent___
    end
  end

  module Expression_Agent___

    class << self

      def NLP_EN_agent
        NLP_EN_expression_agent_instance__[]
      end
    end
  end

  module InstanceMethods

    # **NOTE** the below are not all unobtrusive and auto-vivifying like
    # some i.m modules try to be. The participating object _must_ call
    # `init_headless_sub_client`

  private

    def initialize client_x=nil  # XXX #transitional only #todo
      @error_count = 0
      client_x and headless_client_notify client_x
      super()
    end

    def init_headless_sub_client x  # :+#deprecation:post-tr
      @error_count = 0
      headless_client_notify x ; nil
    end

    def headless_client_notify client_x
      self.request_client = client_x ; nil
    end

if false  # XXX these changes are just an integration joist #todo

    def initialize request_client=nil # this is the heart of it all [#004] (see)
      block_given? and raise ::ArgumentError.new 'blocks are not honored here'
      request_client and init_headless_sub_client request_client
      super(   )
    end

    #         ~ getting and setting the request client ~

    def init_headless_sub_client request_client
      @error_count = 0            # (if this overwrites an important nonzero
                                  # value here, you deserve whatver happens
                                  # to you. why would u call init 2x?)
      self.request_client = request_client  # (some environments employ
    end                           # alternatives to the ivar for storing r.c)

end

    def request_client= x  # #private-attr-writer
      @request_client = x
    end

    def request_client
      @request_client or no_request_client_notify caller_locations( 1, 1 )[ 0 ]
    end

    def no_request_client_notify loc

      desc = if BLOCK_ == loc.label[ BLK_R_ ]

        path = loc.absolute_path.dup
        _reference_pn = ::Pathname.new ::Skylab.dir_path
        path = ::Pathname.new( path ).relative_path_from( _reference_pn ).to_path
        " in block at #{ path }:#{ loc.lineno }"
      else
        " of `#{ loc.base_label }`"
      end

      fail "#{ self.class } cannot delegate call#{ desc } #{
        }upwards to request client - request client is human (#{
        }do you need to implement it for that class)?"
    end

    module Home_::SubClient    # we can't define constants here
      BLOCK_ = 'block '.freeze    # it might be a box module.
      BLK_R_ = 0 ... BLOCK_.length
    end

    #         ~ an alphabetical list of things ~

    def actual_parameters         # not all stacks use this, just convenience
      request_client.send :actual_parameters
    end

    def call_digraph_listeners *a                   # (don't get into the habit of expecting
      request_client.send :call_digraph_listeners, *a # meaningful results from `call_digraph_listeners` --
      nil                         # it's just never a good idea.  ever.)
    end

    def send_error_string s
      send_error s
    end

    def send_error x              # be extra careful around methods that
      @error_count += 1           # affect or are expected to affect the
      call_digraph_listeners :error, x  # validity of your sub-client!
      false                       # this implementation is the result of a
    end                           # "perfect abstraction" but may still cause
                                  # you pain if you're not careful.

    public def error_count
      @error_count
    end

                                  # there is no absolutely no guarantee that
                                  # that out of the box this is reflective
                                  # of anything that you think it is.  caution!

    def escape_path x             # (this is the closing of (now) [#sy-005])
      request_client.send :escape_path, x
    end

    def io_adapter                # sometimes sub-clients need access to
      request_client.send :io_adapter # the streams, e.g. the instream
    end

    def send_info_string s
      send_info s
    end

    def send_info x               # provided as a convenience for this
      call_digraph_listeners :info, x               # extremely common implementation
      nil                         # (note that `x` might be an `h`)
    end

    def parameter_label x, *rest  # [#036] explains it all
      request_client.send :parameter_label, x, *rest
    end

    def send_payload x            # provided as a convenience for this common
      call_digraph_listeners :payload, x            # emitter "macro" -- not all sub-clients
      nil                         # will necessarily call_digraph_listeners this.
    end

    def pen
      request_client.send :pen
    end

    # --- * ---

    # the below methods follow [#br-093]:#the-semantic-markup-guidelines

    def em s
      pen.em s
    end

    def human_escape s
      pen.human_escape s
    end

    def hdr s
      pen.hdr s
    end

    def h2  s
      pen.h2 s
    end

    def ick s
      pen.ick s
    end

    def kbd s
      pen.kbd s
    end

    def omg s
      pen.omg s
    end
  end

  NLP_EN_expression_agent_instance__ = Common_.memoize do

    class NLP_EN_Expression_Agent____

      alias_method :calculate, :instance_exec

      Home_.lib_.human::NLP::EN::Methods[ self, :private, [ :and_, :or_, :s ] ]

      self
    end.new
  end
end
