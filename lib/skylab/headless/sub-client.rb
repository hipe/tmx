module Skylab::Headless::SubClient

  Headless_ = ::Skylab::Headless

  include Headless_

  class << self

    def expression_agent
      Expression_Agent__
    end
  end

  module Expression_Agent__

    class << self

      def NLP_EN_agent
        NLP_EN_expression_agent_instance__[]
      end

      def NLP_EN_methods * x_a
        if x_a.length.zero?
          NLP_EN_Methods__
        else
          NLP_EN_Methods__.via_arglist x_a
        end
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

    module Headless_::SubClient    # we can't define constants here
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

    def escape_path x             # (this is the closing of [#031])
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

    # the below methods follow [#fa-052]:#the-semantic-markup-guidelines

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

  NLP_EN_expression_agent_instance__ = Callback_.memoize do

    class NLP_EN_Expression_Agent_Instance__

      alias_method :calculate, :instance_exec

      methods = NLP_EN_Methods__.struct

    private

      [ :and_, :or_, :s, :nlp_last_length, :set_nlp_last_length ].each do | i |
        define_method i, methods[ i ]
      end

      self
    end.new
  end

  module NLP_EN_Methods__  # see [#086]

    class << self

      def [] mod, * x_a
        on_mod_via_iambic mod, x_a
      end

      def via_arglist a
        on_mod_via_iambic a.shift, a
      end

      def each_pair & p
        @struct.each_pair( & p )
      end

      def on_mod_via_iambic mod, x_a

        case x_a.first
        when :private ; do_private = true
        when :public ; nil
        else ; raise ::ArgumentError, "public or private, not: '#{ x_a.first }'"
        end

        2 == x_a.length or raise ::ArgumentError, "#{ x_a.length } for 2"

        meth_i_a = [ * x_a.last, :nlp_last_length, :set_nlp_last_length ]

        o = @struct

        mod.module_exec do
          meth_i_a.each do |meth_i|
            define_method meth_i, o[ meth_i ]
          end
          do_private and private( * meth_i_a )
        end ; nil
      end

      attr_reader :struct
    end

    -> do

      o = -> do
        @i_a = [] ; @p_a = []
        o_ = -> i, p do
          @i_a.push i ; @p_a.push p ; nil
        end
        class << o_
          alias_method :[]=, :call
        end
        o_
      end.call

      bump_numerish = _EN = nil

      %i| an an_ |.each do |i|
        o[ i ] = -> lemma, numerish=false do
          instance_exec numerish, -> nmrsh do
            _EN[][ i ][ lemma, nmrsh ]
          end, & bump_numerish
        end
      end

      o[ :_non_one ] = -> numerish=nil do  # for nlp hacks, leading space iff not 1
        instance_exec numerish, -> nmrsh do
          " #{ nmrsh }" if 1 != nmrsh
        end, & bump_numerish
      end

      o[ :s ] = -> * args do  # [length] [lexeme_i]
        len_x, lexeme_i = Headless_._lib.parse_series args,
          -> x { ! x.respond_to? :id2name }, # defer it
          -> x { x.respond_to? :id2name }
        lexeme_i ||= :s  # when `len_x` is nil it means "use memoized"
        p = if :identity == lexeme_i
          IDENTITY_
        else
          -> len_x_ do
            _EN[].s len_x_, lexeme_i
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

      memoize_length = -> p do
        -> a do
          set_nlp_last_length a.length
          instance_exec a, &p
        end
      end

      o[ :nlp_last_length ] = -> do
        @nlp_last_length
      end

      o[ :set_nlp_last_length ] = -> x do   # (because to_struct creates getters
        @nlp_last_length = x              # and setters for each of its methods
      end                                 # you can't have your nerk end with '=')

      o[ :_and ] = -> a do  # (when you want the leading space conditionally on etc)
        x = and_ a
        x and " #{ x }"
      end

      o[ :and_ ] = memoize_length[ -> a do
        And__[ a ]
      end ]

      o[ :both ] = memoize_length[ -> a do
        _EN[].both a
      end ]

      o[ :indefinite_noun ] = -> do
        Headless_::NLP::EN::POS.indefinite_noun
      end

      o[ :or_ ] = memoize_length[ -> a do
        Or__[ a ]
      end ]

      o[ :plural_noun ] = -> do
        Headless_::NLP::EN::POS.plural_noun
      end

      o[ :preterite_verb ] = -> do
        Headless_::NLP::EN::POS.preterite_verb
      end

      o[ :progressive_verb ] = -> do
        Headless_::NLP::EN::POS.progressive_verb
      end

      bld_oxford_comma = -> sep do
        p = -> a do
          p = _EN[].oxford_comma.curry[ ', ', sep ]
          p[ a ]
        end
        -> a do
          p[ a ]
        end
      end

      And__ = bld_oxford_comma[ ' and ' ]
      Or__ = bld_oxford_comma[ ' or ' ]

      _EN = Headless_::Callback_.memoize do  # necessary because circular dependency
        Headless_::NLP::EN
      end

      @struct = ::Struct.new( * @i_a ).new( * @p_a )
      @i_a = @p_a = nil

    end.call
  end

  module InstanceMethods
    NLP_EN_Methods__.each_pair do | method_name, body |
      define_method method_name, &body
      protected method_name  # #protected-not-private
    end
  end
end
