module Skylab::Headless::SubClient

  Headless = ::Skylab::Headless
  Headless_ = Headless
  include Headless

  module InstanceMethods

    # **NOTE** the below are not all unobtrusive and auto-vivifying like
    # some i.m modules try to be. The participating object _must_ call
    # `init_headless_sub_client`

  private

    define_singleton_method :private_attr_reader, &
      Headless_::Lib_::Private_attr_reader[]

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
        pth = loc.absolute_path
        pth.sub! %r|\A#{ ::Regexp.escape ::Skylab.dir_pathname.to_s }/|, ''
        " in block at #{ pth }:#{ loc.lineno }"
      else
        " of `#{ loc.base_label }`"
      end
      fail "#{ self.class } cannot delegate call#{ desc } #{
        }upwards to request client - request client is human (#{
        }do you need to implement it for that class)?"
    end

    module Headless::SubClient    # we can't define constants here
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

    def error s                   # be extra careful around methods that
      @error_count += 1           # affect or are expected to affect the
      call_digraph_listeners :error, s              # validity of your sub-client!
      false                       # this implementation is the result of a
    end                           # "perfect abstraction" but may still cause
                                  # you pain if you're not careful.

    private_attr_reader :error_count

                                  # there is no absolutely no guarantee that
                                  # that out of the box this is reflective
                                  # of anything that you think it is.  caution!

    def escape_path x             # (this is the closing of [#031])
      request_client.send :escape_path, x
    end

    def io_adapter                # sometimes sub-clients need access to
      request_client.send :io_adapter # the streams, e.g. the instream
    end

    def info x                    # provided as a convenience for this
      call_digraph_listeners :info, x               # extremely common implementation
      nil                         # (note that `x` might be an `h`)
    end

    def parameter_label x, *rest  # [#036] explains it all
      request_client.send :parameter_label, x, *rest
    end

    def payload x                 # provided as a convenience for this common
      call_digraph_listeners :payload, x            # emitter "macro" -- not all sub-clients
      nil                         # will necessarily call_digraph_listeners this.
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

  EN_FUN = Headless_::Lib_::FUN_module[].new

  module EN_FUN  # see [#086]

    def self.[] mod, * x_a
      on_mod_via_iambic mod, x_a
    end

    def self.on_mod_via_iambic mod, x_a
      :private == x_a[ 0 ] or fail "only `private` is supported for now #{
        }(had #{ Headless_::Lib_::Strange[ x_a[ 0 ] ] })"
      x_a.shift
      1 == x_a.length or fail "expecting exactly one element, an array"
      meth_i_a = [ * x_a.shift, :nlp_last_length, :set_nlp_last_length ]
      h = @h
      mod.module_exec do
        meth_i_a.each do |meth_i|
          define_method meth_i, & h.fetch( meth_i )
        end
        private( * meth_i_a )
      end ; nil
    end

    o = definer

    bump_numerish = fun = nil

    %i| an an_ |.each do |i|
      o[ i ] = -> lemma, numerish=false do
        instance_exec numerish, -> nmrsh do
          fun[][ i ][ lemma, nmrsh ]
        end, & bump_numerish
      end
    end

    o[:_non_one] = -> numerish=nil do  # for nlp hacks, leading space iff not 1
      instance_exec numerish, -> nmrsh do
        " #{ nmrsh }" if 1 != nmrsh
      end, & bump_numerish
    end

    o[:s] = -> * args do  # [length] [lexeme_i]
      len_x, lexeme_i = Headless_::Lib_::Parse_series[ args,
        -> x { ! x.respond_to? :id2name }, # defer it
        -> x { x.respond_to? :id2name } ]
      lexeme_i ||= :s  # when `len_x` is nil it means "use memoized"
      p = if :identity == lexeme_i
        IDENTITY_
      else
        -> len_x_ do
          fun[].s[ len_x_, lexeme_i ]
        end
      end
      instance_exec len_x, p, & bump_numerish
    end

    bump_numerish = -> numerish_x, p do
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
        numerish = nlp_last_length
      end
      instance_exec numerish, & p
    end

    o[:nlp_last_length] = -> do
      @nlp_last_length
    end

    o[:set_nlp_last_length] = -> x do   # (because to_struct creates getters
      @nlp_last_length = x              # and setters for each of its methods
    end                                 # you can't have your nerk end with '=')

    memoize_length = -> p do
      -> a do
        set_nlp_last_length a.length
        instance_exec a, &p
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

    o[:both] = memoize_length[ -> a do
      fun[].both[ a ]
    end ]

    fun = -> do
      # ( we've got to lazy-load it b.c of a circular dependency in the files )
      x = Headless::NLP::EN::Minitesimal::FUN ; fun = -> { x } ; x
    end

  end

  module InstanceMethods
    EN_FUN.each_pair do |method_name, body|
      define_method method_name, &body
      protected method_name  # #protected-not-private
    end
  end
end
