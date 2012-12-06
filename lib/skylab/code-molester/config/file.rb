::Skylab::Headless::FUN.require_quietly[ 'treetop' ]


module ::Skylab::CodeMolester

  class Config::File

    # like the one in MetaHell::DelegatesTo, but with ad-hoc
    # customization for this class
    def self.delegates_to implementor, method_name, condition=nil
      if ! condition                        # the default condition is that the
        condition = -> { send implementor } # implementor result must be trueish
      end
      defn = -> *a, &b do
        result = nil
        if instance_exec(& condition)
          result = send( implementor ).send method_name, *a, &b
        end
        result
      end
      define_method method_name, &defn
    end

    delegates_to :sexp, :[], -> { valid? }

    def []= k, v
      set_value k, v
    end

    attr_reader :content # @api private!

    def content= str
      @content = str
      @state = :unparsed
    end

    delegates_to :sexp, :content_items, -> { valid? }

    delegates_to :pathname, :dirname

    delegates_to :pathname, :exist?

    def invalid_reason
      valid?
      @invalid_reason
    end

    delegates_to :sexp, :key?, -> { valid? }

    def modified?
      if pathname.exist?
        if @mtime
          pathname.mtime > @mtime
        else
          true
        end
      end
    end

    def on_read &b
      if b then @on_read = b else @on_read end
    end

    def on_write &b
      if b then @on_write = b else @on_write end
    end

    def path
      @pathname.to_s if @pathname
    end

    def path= mixed
      if mixed
        @pathname = ::Pathname.new mixed.to_s
        mixed
      else
        @pathname = mixed
      end
    end

    attr_reader :pathname

    on_read = PubSub::Emitter.new error: :all, invalid: :error

    define_method :read do
      e = on_read.new
      if block_given? then yield e else self.on_read[ e ] end
      self.content = pathname.read
      @mtime = pathname.mtime
      result = nil
      if valid?
        result = self
      else
        e.emit :invalid, invalid_reason
        result = false
      end
      result
    end

    delegates_to :sexp, :sections, -> { valid? }

    delegates_to :sexp, :set_value, -> { valid? }

    def sexp
      if valid?
        @content
      else
        false
      end
    end

    # `to_s` - don't define or alias this.  It is so ambiguous
    # for this class it should not be used.

    def string
      valid? ? @content.unparse : @content
    end

    delegates_to :sexp, :value_items, -> { valid? }


    on_write = PubSub::Emitter.new error: :all, notice: :all,
      before: :all, after: :all, before_edit: [:before, :notice],
      after_edit: [:after, :notice], before_create: [:before, :notice],
      after_create: [:after, :notice], no_change: :notice


    define_method :write do
      e = on_write.new
      if block_given then yield e else self.on_write[ e ] end
      result = nil
      if exist?
        result = update e
      else
        result = create e
      end
      result
    end

    def valid?
      if :initial == @state || :unparsed == @state
        if @content.nil?
          @content = ''
        end
        p = self.class.parser
        result = p.parse @content
        if result
          @content = result.sexp
          @state = :valid
          @invalid_reason = nil
        else
          @state = :invalid
          @invalid_reason = CodeMolester::ParseFailurePorcelain.new p
        end
      end

      case @state
      when :valid   ; true
      when :invalid ; false
      else          ; fail "unexpected state: #{ @state }"
      end
    end

    delegates_to :pathname, :writable?

  protected

    # [path] [opts]
    def initialize *args
      @content = @mtime = @on_read = @on_write = @pathname = nil
      @state = :initial
      params_h = if ::Hash === args.last
        args.pop.dup
      else
        { }
      end
      params_h[:path] = args.pop unless args.empty?
      args.empty? or
        raise ::ArgumentError.new "syntax: #{ self.class }.new [path [, opts]]"
      params_h.each { |k, v| send "#{ k }=", v }
      yield self if block_given?
    end


    def create e
      result = nil

      begin
        content = string
        if content == pathname.read
          e.emit :no_change, "no change: #{ escaped_path }"
          break
        end

        e.emit :before_edit, resource: self,
          message: "updating #{ escaped_path }"

        if writable?
          bytes = nil
          pathname.open( w ) { |fh| bytes = fh.write content }
          e.emit :after_edit, bytes: bytes,
            message: "updated #{ escaped_path } (#{ bytes } bytes)"
          result = bytes
          break
        end

        result = e.error "cannot edit, file is not writable: #{ escaped_path }"
      end while nil

      result
    end


    def update e
      result = nil

      begin
        e.emit :before_create, resource: self,
          message: "creating #{ escaped_path }"

        if ! dirname.exist?
          result = e.error(
            "parent directory does not exist, cannot write #{ escaped_path }" )
          break
        end

        if ! dirname.writable?
          result = e.error(
            "parent direcory is not writable, cannot write #{ escaped_path }" )
          break
        end

        bytes = nil
        pathname.open( 'w+' ) { |fh| bytes = fh.write string }

        e.emit :after_create, bytes: bytes,
          message: "created #{ escaped_path } (#{ bytes } bytes)"

        result = bytes
      end while nil

      result
    end


    # ----------------------- define m.m `parser` begin ---------------------

    class << self
      attr_accessor :do_debug
    end

    const = :ConfigParser

    debug = -> { do_debug }

    compile = -> do
      debug[] and $stderr.puts "creating new #{ const } xyzzy"
      pathname = Config.dir_pathname.join 'file-parser'
      o = ::Treetop.load pathname.to_s
      o.name =~ /::#{ ::Regexp.escape const.to_s }\z/ or fail "huh?#{ o }"
      o
    end

    parser_class = -> do
      o = nil
      if CodeMolester.const_defined? const, false
        debug[] and $stderr.puts "constant existed! #{ const } xyzzy"
        o = CodeMolester.const_get const, false
      else
        o = compile[]
      end
      parser_class = -> do
        debug[] and $stderr.puts "using memoized #{ const } xyzzy"
        o
      end
      o
    end

    define_singleton_method :parser_class do
      parser_class[]
    end

    def self.parser
      @parser ||= parser_class.new
    end

    # ------------------------------- end ------------------------------------
  end

  Config::File.do_debug = true

end
