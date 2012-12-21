module ::Skylab::CodeMolester

  class Config::File


    # custom `delegates_to` -- contrast with MetaHell::DelegatesTo
    # #watch'ing this for push up potential.
    #
    def self.delegates_to implementor, method_name, condition=nil
      if ! condition                        # the default condition is that the
        condition = -> { send implementor } # implementor result must be trueish
      end
      defn = ->( *a, &b ) do
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

    def content= str
      @valid = nil
      @content = str
    end

    delegates_to :sexp, :content_items, -> { valid? }

    delegates_to :pathname, :dirname

    delegates_to :pathname, :exist?

    def invalid_reason
      valid? if @valid.nil?
      @invalid_reason
    end

    delegates_to :sexp, :key?, -> { valid? }


    # **NOTE** the meaning of `modified?` may have changed since we last used
    # it: it *used* to mean: "does the file that is currently on disk have
    # an `mtime` that is greater than the `mtime` was when we last read it?"
    # whereas *now* it means "are the bytes we have in memory different
    # than the the bytes that are on disk?".
    #
    # The old sense of the meaning may prove useful in the future to protect
    # against accidental overwrites, (as vi does for e.g) which is why
    # we keep this note here.
    #
    # For those instances that are not (yet?) associated with a pathname,
    # the question of if it is `modified?` is meaningless and potentially
    # hazardous if misunderstood.  In such cases we raise a sanity check
    # exception.
    #
    # For those instances that are not valid, the question of whether the
    # object is `modified?` should not be asked, because this library will
    # try to prevent you from writing such objects to disk.  Likewise a runtime
    # error is raised in such cases.

    def modified?
      result = nil
      if ! @pathname
        fail "sanity - it is meaningless to ask if `modified?` on #{
          }a #{ noun } not associated with any pathname."
      elsif ! valid?
        raise "sanity - invalid files should not be written to disk and hence #{
          }whether such files are modified is the wrong question to ask."
      else
        if @pathname.exist?
          result = string == @pathname.read # #twice
        elsif '' ==  string       # in cases where the file has not (yet) been
          result = false          # written to disk, consider our structure as
        else                      # modified IFF we flatten as anything other
          result = true           # than the empty string, to avoid writing
        end                       # empty files to disk.
      end
      result
    end

    def noun                      # clients may find this useful in e.g.
      @entity_noun_stem || 'config file' # reflection (thing `git status`)
    end

    def path
      @pathname.to_s if @pathname # a simpler, perhaps more familiar interface
    end                           # for the outside world

    def path= str                 # with this class we try to create objects
      if @pathname                # that are "semi-immutable", however for some
        raise "won't overwrite existing path" # applications it is useful to
      end                         # be able to build the instancep progressively
      if str                      # hence we experiment with this.
        @pathname = ::Pathname.new str.to_s
        str
      else
        @pathname = str
      end
    end

    attr_reader :pathname

    default_escape_path = ->( pn ) { pn.basename } # a nice safe common denom.

    read_events = ::Struct.new :error, :read_error, :no_ent, :is_not_file,
      :invalid, :escape_path

    define_method :read do |&block|
      ev = read_events.new
      block[ ev ] if block
      escape_path = -> pathname do
        ( ev[:escape_path] || default_escape_path )[ pathname ]
      end
      @pathname or
        raise "cannot read - no pathname associated with this #{ noun }"
      res = nil
      if @pathname.exist?
        stat = @pathname.stat
        if 'file' == stat.ftype
          content = @pathname.read # change state only after this succeeds
          pn_ = @pathname         # clear everythihng but the pathname - ick
          clear
          @pathname = pn_
          @pathname_was_read = true # used e.g by InvalidReason for l.g.
          @content = content      # avoid circular dependency inf. loop here by
          if valid?               # setting @content before calling `valid?`
            res = true
          elsif( f = ev[:invalid] || ev[:error] )
            res = f[ invalid_reason ]
          else
            res = false
          end
        else
          f = ev[:is_not_file] || ev[:read_error] || ev[:error]
          f ||= -> pn, ftype do
            raise "expected #{ noun } to be of type 'file', had #{ ftype } #{
              }- #{ escape_path[ pn ] }"
          end
          res = f[ @pathname, stat.ftype ]
        end
      else
        f = ev[:no_ent] || ev[:read_error] || ev[:error] || -> pn do
          raise ::Errno::ENOENT.exception( escape_path[ pn ].to_s )
          # the class itself writes "No such file or directory - #{ .. }" for us
        end
        res = f[ @pathname ]
      end
      res
    end


    delegates_to :sexp, :sections, -> { valid? }

    delegates_to :sexp, :set_value, -> { valid? }

    def sexp
      valid? if @valid.nil?
      if @valid
        @content
      else
        @valid # (presumably false)
      end
    end

    def string
      valid? if @valid.nil?
      if @valid
        @content.unparse
      else
        @content
      end
    end

    # `to_s` - don't define or alias this.  It is so ambiguous
    # for this class it should not be used.

    delegates_to :sexp, :value_items, -> { valid? }


    def valid?
      if @valid.nil?
        if @content.nil?
          if @pathname and @pathname.exist?
            reading = true        # avoid circular dependency inf. loop here
            read                  # when `read` calls `valid?`
          else
            @content = ''
          end
        end
        if ! reading
          parser = self.class.parser
          result = parser.parse @content
          if result
            @content = result.sexp # @content goes from being a string to a sexp
            @invalid_reason = nil
            @valid = true
          else
            # (leave content as the invalid string)
            use_pn = (@pathname and @pathname_was_read) ? @pathname : nil
            @invalid_reason = CodeMolester::InvalidReason.new parser, use_pn
            @valid = false
          end
        end
      end
      @valid
    end

    delegates_to :pathname, :writable?



    write_emitter = PubSub::Emitter.new error: :all,
      notice: :all, before: :all, after: :all,
      before_edit:   [:before, :notice], after_edit:   [:after, :notice],
      before_create: [:before, :notice], after_create: [:after, :notice],
      no_change: :notice
    write_emitter.send :attr_accessor, :escape_path # ouch


    define_method :write do |&block|
      result = nil
      em = write_emitter.new
      block[ em ] if block
      em.escape_path ||= default_escape_path
      @pathname or
        raise "cannot write - no pathname associated with this #{ noun }"
      if valid?
        if exist?
          if @pathname_was_read
            result = update em
          else
            fail "won't overwrite a pathname that was not first read" # stub
          end
        else
          result = create em
        end
      else
        raise "attempt to write invalid #{ noun } - check if valid? first"
      end
      result
   end

  protected

    opts_struct = ::Struct.new :path, :string, :entity_noun_stem

    define_method :initialize do |param_h=nil|
      block_given? and raise 'where?'
      o = opts_struct.new
      if param_h
        param_h.each { |k, v| o[k] = v }
      end
      @content = o[:string] # expecting nil or string here
      @entity_noun_stem = o[:entity_noun_stem]
      @invalid_reason = nil
      @pathname = o[:path] ? ::Pathname.new( o[:path].to_s ) : nil
      @pathname_was_read = nil
      @valid = nil
    end

    def clear
      @content = @invalid_reason = @pathname = @pathname_was_read = @valid = nil
    end

    def create em
      result = nil # assume valid? and @pathname which not exist?
      begin
        em.emit :before_create,
          resource: self,
          message: "creating #{ em.escape_path[ @pathname ] }"

        # because the below are not considered porcelain-level errors, they
        # use neither the emitter nor `escape_path`
        @pathname.dirname.exist? or
          raise "parent directory does not exist, cannot write - #{
            }#{ @pathname.dirname }"

        @pathname.dirname.writable? or
          raise "parent directory is not writable, cannot write #{
            }#{ @pathname }"

        bytes = nil
        @pathname.open( 'w+' ) { |fh| bytes = fh.write string }

        em.emit :after_create,
          bytes: bytes,
          message: "created #{ em.escape_path[ @pathname ] } (#{ bytes } bytes)"

        result = bytes
      end while nil
      result
    end

    def update em
      result = nil
      begin
        string = self.string      # thread safety HA

        if string == @pathname.read # #twice
          em.emit :no_change,
            "no change: #{ em.escape_path[ @pathname ] }"
          break
        end

        em.emit :before_edit,
          resource: self,
          message: "updating #{ em.escape_path[ @pathname ] }"

        @pathname.writable? or
          raise "path is not writable, cannot write - #{ @pathname }"

        bytes = nil
        pathname.open( 'w' ) { |fh| bytes = fh.write string }

        em.emit :after_edit,
          bytes: bytes,
          message: "updated #{ em.escape_path[ @pathname ] } (#{ bytes } bytes)"

        result = bytes

      end while nil
      result
    end



    #
    # ----------------------- define m.m `parser` begin ---------------------
    #

    class << self
      attr_accessor :do_debug
    end

    const = :ConfigParser

    debug = -> { do_debug }

    compile = -> do
      debug[] and $stderr.puts "loading new #{ const } xyzzy"
      pathname = Config.dir_pathname.join 'file-parser'
      o = CodeMolester::Services::Treetop.load pathname.to_s
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
