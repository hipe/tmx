module ::Skylab::CodeMolester

  class Config::File::Model

    module Foofer # (ignore)

      # (while [#ps-101] (cover pub-sub viz) is open..) (multiple graphs
      # in one file, specifically)

      extend PubSub::Emitter
      emits wizzle: :paazle
    end

    # custom `delegates_to` -- contrast with MetaHell::DelegatesTo
    # #watch'ing this for push up potential.

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

    def []= k, x
      set_mixed k, x
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
    # hazardous if misunderstood. In such cases we raise a sanity check
    # exception.
    #
    # For those instances that are not valid, the question of whether the
    # object is `modified?` should not be asked, because this library will
    # try to prevent you from writing such objects to disk. Likewise a runtime
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
      @entity_noun_stem || 'config file'  # reflection (thing `git status`)
    end

    def path
      @pathname.to_s if @pathname # a simpler, perhaps more familiar interface
    end                           # for the outside world

    def path= str                 # with this class we try to create objects
      if @pathname                # that are "semi-immutable", however for some
        raise "won't overwrite existing path"  # applications it is useful to
      end                         # be able to build the instancep progressively
      if str                      # hence we experiment with this.
        @pathname = ::Pathname.new str.to_s
        str
      else
        @pathname = str
      end
    end

    attr_reader :pathname

    default_escape_path = -> pn { pn.basename } # a nice safe common denom.

    Read = ::Struct.new :error, :read_error, :no_ent, :is_not_file,
      :invalid, :escape_path

    define_method :read do |&block|  # ( b.c uses `default_escape_path` )
      ev = Read.new
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
          content = @pathname.read  # change state only after this succeeds
          pn_ = @pathname         # clear everythihng but the pathname - ick
          clear
          @pathname = pn_
          @pathname_was_read = true  # used e.g by InvalidReason for l.g.
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

    delegates_to :sexp, :set_mixed, -> { valid? }

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

    # `to_s` - don't define or alias this. It is so ambiguous for such an
    # object as this that it should not be assigned any special behavior,
    # nor used in application code.

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
          parser = Config::File::Parser.instance
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

    # the new way - looks atomic to the outside, might be from immutable object

    def if_valid if_yes_have_self, if_no_have_this_error_metadata
      if valid?
        if_yes_have_self[ self ]
      else
        if_no_have_this_error_metadata[ @invalid_reason ]
      end
    end

    delegates_to :pathname, :writable?

    Write = PubSub::Emitter.new  # see `write`
    class Write

      # (this class is file-private but so-named for friendlier debugging)

      # the world'd most interesting graph - see `write`

      taxonomic_streams :all, :structural, :text, :notice, :before, :after

      emits error: [ :text, :all ],
        notice: [ :text, :all ], before: :all, after: :all,
        before_update:   [ :structural, :before, :notice ],
        after_update:    [ :structural, :after, :notice ],
        before_create: [ :structural, :before, :notice ],
        after_create:  [ :structural, :after, :notice ],
        no_change:     [ :notice, :text ]

      event_factory -> { PubSub::Event::Factory::Isomorphic.new Events }

      # a dubious and experimental way to pass in parameters -

      attr_accessor :dry_run
      alias_method :is_dry_run, :dry_run

      attr_accessor :escape_path
    end

    module EVENT_
      # filled with joy
    end

    module Events
      MetaHell::Boxxy[ self ]
      Text = PubSub::Event::Factory::Datapoint
      Structural = PubSub::Event::Factory::Structural.new 2, nil, EVENT_
    end

    # `write` - because so many different interesting things can happen when
    # we set out to write a file, we have a custom emitter class that models
    # this event graph that callers can use to hook into these event streams.
    #
    # For one thing the file either does or does not already exist,
    # and for these two states we will variously use the verbs `update`
    # or `create` respectively in various symbols below.
    #
    # We emit separate events immediately `before` and immediately `after`
    # the file is written to, which, when events on such streams are received
    # by the caller that has a CLI modality, they are frequently written
    # out as one line in two parts, with the reasoning that it is useful to
    # see separately that the file writing *began* at all and that the file
    # writing *completed* (successfully) -- and doing this in two separate
    # lines may be considered too noisy -- however having the first half
    # of the line written out e.g. to a logfile might be nice so that you
    # have the filename recorded right before e.g a permission error was
    # thrown by the filesystem.)
    #
    # The four symbols introduced above (`create`, `update`, `before`,
    # `after`) exist as taxonomic streams, and then additionally one stream
    # each for the four permutations of the two "exponents" for each of the
    # two "categories" exists ("before_create", "after_update") etc.
    #
    # ("taxonomic streams" are streams that exist only to categories other
    # streams (kind of like folders, more like tags). they are useful if
    # you wanted subscribe only to certain sub-streams of events -
    # e.g only the "after-" related events or only the "update-" related
    # events.)
    #
    # Other taxonomic streams used include `text` v.s `structural` (whether
    # the event is a string or a struct-ish of metadata (in the inheritence
    # chain of a given stream, first one wins here) -- this may help you
    # decide programmatically how to handle the event); and `notice` vs.
    # `error` i.e. the severity -- e.g you may only want to act on events
    # when they are at a certain level of severity to you.
    #
    # This big graph of streams is best viewed with `pub-sub viz`, a command-
    # line tool that is part of pub-sub and works in conjunction with graph-viz
    # to display this graph visually.
    #
    # (incidentally this and its two constituent implementation methods
    # is becoming the poster-child wet-dream of [#hl-022], which seeks
    # - possibly in vain - to dry up this prevalent pattern..)

    define_method :write do |&block|  # ( because uses `default_escape_path`)
      res = nil
      w = Write.new
      block[ w ] if block
      w.escape_path ||= default_escape_path
      @pathname or
        raise "cannot write - no pathname associated with this #{ noun }"
      if valid?
        if exist?
          if @pathname_was_read
            res = update w
          else
            fail "won't overwrite a pathname that was not first read"  # stub
          end
        else
          res = create w
        end
      else
        raise "attempt to write invalid #{ noun } - check if valid? first"
      end
      res
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

    def create w  # ( assumes valid? and @pathname which not exist? )
      res = nil
      begin
        w.emit :before_create,
          resource: self,
          message_function: -> { "creating #{ w.escape_path[ @pathname ] }" }

        # because the below are not considered porcelain-level errors, they
        # use neither the emitter nor `escape_path` (for now..)
        @pathname.dirname.exist? or
          raise "parent directory does not exist, cannot write - #{
            }#{ @pathname.dirname }"

        @pathname.dirname.writable? or
          raise "parent directory is not writable, cannot write - #{
            }#{ @pathname }"

        bytes = nil

        if ! w.is_dry_run              # (contrast with `update`)
          @pathname.open 'a' do |fh|   # ('a' not 'w' to fail gloriously)
            bytes = fh.write string
          end
        end

        w.emit :after_create,
          bytes: bytes,
          message_function: -> do
            "created #{ w.escape_path[ @pathname ] } (#{ bytes } bytes)"
          end

        res = bytes
      end while nil
      res
    end

    attr_reader :entity_noun_stem

    def update w
      res = nil
      begin
        string = self.string      # thread safety HA

        if string == @pathname.read # #twice
          w.emit :no_change,
            "no change: #{ w.escape_path[ @pathname ] }"
          break
        end

        w.emit :before_update,
          resource: self,
          message_function: -> { "updating #{ w.escape_path[ @pathname ] }" }

        @pathname.writable? or
          raise "path is not writable, cannot write - #{ @pathname }"

        bytes = nil

        pathname.open 'w' do |fh|
          if ! w.is_dry_run  # ( contrast with `create` )
            bytes = fh.write string
          end
        end

        w.emit :after_update,
          bytes: bytes,
          message_function: -> do
            "updated #{ w.escape_path[ @pathname ] } (#{ bytes } bytes)"
          end

        res = bytes

      end while nil
      res
    end
  end
end
