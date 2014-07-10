module Skylab::MetaHell

  class Proxy::Tee < ::BasicObject  # construct a tee like you would a struct

    class << self
      alias_method :metahell_original_new, :new
    end

    next_id = -> do
      id = 0
      -> { id += 1 }
    end.call

    define_singleton_method :new do |method, * method_a, & cls_p |

      method_a.unshift method ; method = nil  # just for the syntax above.
      method_a.freeze

      ::Class.new( self ).class_exec do

        class << self
          alias_method :new, :metahell_original_new
        end

        method_a.each do |m|
          define_method m do |*a, &b|
            @mux.dispatch m, a, b
          end
        end

        define_singleton_method :method_names do
          method_a
        end

        kls = self                # basic object don't respond to `class`
                                  # basic object don't care

        define_method :initialize do |*a|
          @mux = Proxy::Tee::Mux.new self, kls, next_id[], a
        end

        cls_p and class_exec( & cls_p )

        self
      end
    end

    # as a compromise for readable code and easier debugging, we make it
    # hard for you to proxy out the following methods. alternatives include
    # either making a 'pure proxy' that has an external controller object,
    # or passing in all the downstream children at construction time. both
    # were deemed unideal attotw.
    #

    def [] k
      @mux[k]
    end

    def []= k, v
      @mux[k] = v
    end
                                  # we will assume you don't want to proxy-
    def to_s                      # out calls to to_s, and if you did you could
      @mux.to_s
    end

    alias_method :inspect, :to_s  # (makes errors more traceable)

    def method sym
      ::Proc.new do |*a, &b|
        __send__ sym, *a, &b      # sorry, it is the best i can do
      end                         # on short notice
    end
  end

  class Proxy::Tee::Mux           # (internal dispatcher for proxy tee)

    def [] k
      @box.fetch k
    end

    def []= k, v                  # wrapper for non-clobbering store of a
      @box.add k, v               # downstream
      v
    end

    def dispatch method, args, func
      res = seen = nil
      @box.each do |x|            # (if the receiver is a ::BasicObject it
        r = x.__send__ method, *args, &func # won't have plain old `send`)
        seen ||= begin
          res = r
          true
        end
      end
      res
    end

    def to_s
      "#<#{ @tee_class.to_s }:(tee #{ @tee_id })>"
    end

  private

    def initialize tee, tee_class, tee_id, tee_args  # mutates tee_args
      @tee, @tee_class, @tee_id = tee, tee_class, tee_id
      @box = MetaHell_::Formal::Box.new
      class << @box
        public :fetch, :add
      end
      process_tee_args tee_args
    end

    def process_tee_args a  # mutates tee args
      if a.length.nonzero? and a.respond_to? :each
        h = a.pop
        h.each do |k, v|
          @box.add k, v
        end
      end
      raise ::ArgumentError, "(#{ a.length + 1} for 1)" if a.length.nonzero?
      nil
    end
  end
end
