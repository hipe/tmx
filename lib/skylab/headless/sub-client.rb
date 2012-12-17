module Skylab::Headless

  module SubClient
    # this used to be more complicated, but you see what it has become now
  end


  module SubClient::InstanceMethods

  protected

    def initialize request_client # this is the heart of it all [#004]
      block_given? and raise ::ArgumentError.new 'blocks are not honored here'
      _headless_sub_client_init! request_client
    end

    def _headless_sub_client_init! request_client
      @error_count = 0            # (if this overwrites an important nonzero
                                  # value here, you deserve whatver happens
                                  # to you. why would u call init 2x?)
      self.request_runtime = request_client
    end

    def actual_parameters         # not all stacks use this, just convenience
      request_client.send :actual_parameters
    end

    def emit *a                   # (don't get into the habbit of expecting
      request_client.send :emit, *a # meaninful results from `emit` --
      nil                         # it's just never a good idea.  ever.)
    end

    def error s                   # be extra careful around methods that
      increment_error_count!      # affect or are expected to affect the
      emit :error, s              # validity of your sub-client!
      false                       # this implementation is the result of a
    end                           # "perfect abstraction" but may still cause
                                  # you pain if you're not careful.

    attr_reader :error_count      # there is no absolutely no guarantee that
                                  # that out of the box this is reflective
                                  # of anything that you think it is.  caution!

    def increment_error_count!    # use this if you need to do it manually
      @error_count += 1           # (note it happens in the above impl for
    end                           # `error` though)

    def io_adapter                # sometimes sub-clients need access to
      request_client.send :io_adapter # the streams, e.g. the instream
    end

    def info s                    # provided as a convenience for this
      emit :info, s               # extremely common implementation
      nil
    end

    def pen
      request_client.send :pen
    end

    attr_accessor :request_runtime # the center of [#005]
    alias_method :request_client, :request_runtime # one day!!

    # --- * ---

    def em s ; pen.em s end

    def human_escape s ; pen.human_escape s end

    def kbd s ; pen.kbd s end

    def parameter_label x ; pen.parameter_label x end

    # --- * ---

    fun = Headless::NLP::EN::Minitesimal::FUN

                                  # memoize last counts for shorter strings
    define_method :and_ do |a|
      self._nlp_last_length = a.length
      fun.oxford_comma[ a, ' and ' ]
    end

    attr_accessor :_nlp_last_length

    define_method :or_ do |a|
      self._nlp_last_length = a.length
      fun.oxford_comma[ a, ' or ' ]
    end

    define_method :s do |length=nil, part=nil|
      args = [length, part].compact
      pt = ::Symbol === args.last ? args.pop : :s
      if args.empty?
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
