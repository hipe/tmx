module Skylab::Face

  # `Face`
  #   + wraps around ::OptionParser by default
  #   + renders styled help screens and the usual help UI
  #   + arbitrarily deeply nested sub-commands (namespaces)
  #   + nodes (commands and namespaces) can have aliases
  #   + fuzzy matching
  #   + command argument syntax inferred by default from method signature
  #   + some built in 'officious' (allà stdlib o.p) like -v, -h

  # historical note - this library by this name came before headless and
  # before porcelain (both `bleeding` and `legacy`, indeed it was the first
  # client library for `tmx` itself) and it did not age well; but then saw a
  # comprehensive, ground-up test-driven rewrite (TWICE) after those two fell
  # out of fashion. it will hopefully be merged into headless one day because
  # now it is close to perfect.

  # unlike its ancestors, `Face` eschews use of spurious, exuberant,
  # extraneous, or frivolous modules. instead it aspires to a minimal and
  # clean class graph with three classes, a graph that is the embodiment of a
  # rigid and complete trinity of balance, whose goal is to be extensible
  # while not sacrificing simplicity of design and clarity of comprehension.

  # in practice there are more than three classes but conceptually this
  # "triforce" is intrinsic to the design here (illustrated in [#040]).

  # as for the structure of this file, we may sometimes follow something like
  # "narrative pre-order" ([#hl-058]), whose effect is that classes and
  # modules are re-opened as necessary so as to fit method definitions within
  # the appropriate section, to make a rousing narrative, and to make it
  # semantically modular, if we ever need to break it up.

  # within that structure we often follow a top-down outside-in order.

  #          ~ facet 1 - intrinsic mechanics & surface -

  #   ~ 1.1 - necessary forward declarations (nothing interesting)  ~

  class Command  # #forward-declared-for-narrative. re-opens below.
  end

  class Namespace  # #forward-declared-for-narrative. re-opens below.
    def _m  # #todo
      @mechanics
    end
  end

  class CLI < Namespace  # #forward-declaration
    Namespace = Namespace  # the proper way to access it it outside this lib
    Command = Command # the proper way to access it outside this lib
  end

  class NS_Mechanics_ < Command
    # #forward-declare-for-narrative. re-opens below
  end

  class CLI_Mechanics_ < NS_Mechanics_
    # #forward-declare-for-narrative. re-opens below
  end

  class Node_Sheet_  # #forward-declared-for-narrative. re-opens below.
  end

  FUN_ = MetaHell::Formal::Box::Open.new

  #           ~ 1.2 - `CLI` (the "modality client") & support ~

  class CLI < Namespace  # open for facet 1

    # and object of a subclass of the `CLI` class is *the* "modality client"
    # for is an abstract base class - it is the first node to "see" things
    # like ARGV and $stdin, $stdout, $stderr, and is the only node in this
    # ecosystem to "be given" such things from the ruby ecosystem directly.
    #
    # this `CLI` class itself is not meant to be instantiated directly and to
    # do so has undefined results. this `CLI` class in its implementation is a
    # specilization of the `Namespace` class with some extra added
    # functionality for being the topmost (or rootmost) node (for some context)
    # in the application tree. except where noted, all description of
    # `Namespace` below will apply to this class here, so please see that for
    # further description of the `CLI` class.

    #             ~ class section 1 - instance methods ~

    # `invoke` - the only public method. #existential-workhorse. accords with
    # [#hl-020].

    def invoke argv
      ok, res, m, a, b, cmd = @mechanics.get_executable argv
      if ok
        begin
          res = res.send m, *a, &b
        rescue ::ArgumentError => ex
          res = @mechanics.argument_error ex, cmd  # see.
        end  # the above call is coupled to its position in the call stack
      end
      res
    end

    Mechanics__ = CLI_Mechanics_
  end

  # ( `class CLI::Sheet_` note there is none. we use NS::Sheet_ that node. )

  class CLI_Mechanics_ < NS_Mechanics_   # #re-open for facet 1. has p-arent.

    # ~ class section 1 - singleton methods. warning: what you are about to
    # see is extremely clever, elegant, extensible and generally brilliant;
    # in a manner so understated as to have a power that is at first hard to
    # recognize, much less follow ~

    -> do  # `self.enhance`

      # the purpose of the call at this node is simply to normalize the args
      # to allow for [#sl-114] the convention of `stdin, stdout, stderr` as
      # flat args. to be more extensible, we then send the normalized hash at
      # this point off to `_enhance` below it for whatever further processing.

      a_len = {
        1 => -> h { h },
        3 => -> sin, sout, serr { { sin: sin, out: sout, err: serr } }
      }

      define_singleton_method :enhance do |surface, a|
        _enhance surface, a_len.fetch( a.length ).call( * a )  # be extensible
      end

    end.call

    class << self
    private

      # ( because of the power, elegance and whatever, we can add and remove
      # arguments to the below list without dire mofo's or consequences )

      def __enhance surface, sin, out, err, program_name, sheet
        mech = new ( sheet || surface.class.story ), surface
        mech.init_cli_surface surface, sin, out, err, program_name
        mech
      end
    end

    def initialize sheet, surface
      super sheet, surface, nil, nil
    end

    #           ~ class section 2 - public instance methods ~

    # `get_executable` - #existential-workhorse #result-is-tuple
    # result tuple: ( ok, result_code_or_receiver, method, args, block, cmd )

    def get_executable argv
      node = self ; ok = r = rest = @last_cli_executable = nil ; pre_execute
      catch :break_two do
        while true
          if argv.length.zero? && node.has_default_argv
            argv.concat node.default_argv_value
          end
          argv.length.zero? and break( ok, cmd = true, node )
          if DASH_ == argv.fetch( 0 ).getbyte( 0 )
            ok, _ok, r, *rest = node.process_options argv
            _ok or throw :break_two  # this allows an opt to act cmd-like
            argv.length.zero? and break( ok, cmd = true, node )  # repeat!
          end
          ok, r = node.find_command argv
          ok or break
          cmd = r
          if cmd.respond_to? :invokee
            r = cmd.invokee
            rest = [ :invoke, [ argv ], nil, r ]
            throw :break_two
          end
          cmd.respond_to? :find_command or break
          node = cmd  # tail-call like
        end
        begin
          ok or break
          ok, _ok, r, *rest = cmd.parse argv
          _ok or break
          ( f = cmd.invocation_function ) and
            break( r, rest = node, [ :instance_exec, [ argv ], f ] )
          r, rest = node.surface_receiver, [ cmd.method_name, argv, nil, cmd ]
        end while nil
      end
      [ ok, r, *rest ]
    end
    DASH_ = '-'.getbyte 0

    # `init_cli_surface` #called-by self.class only. [#040] explains it all.
    # so this is that weird place where we fan-out these resources upwards
    # for a moment.

    def init_cli_surface surface, sin, out, err, program_name
      surface.instance_exec do
        @program_name ||= program_name
        @sin ||= sin ; @out ||= out ; @err ||= err
        if @err
          @y ||= ::Enumerator::Yielder.new( & @err.method( :puts ) )
          # (note it's hard to lazy-evaluate anything in the surface shell
          # because of [#037])
        end
      end
      nil
    end

    # `pre_execute` - #called-by self in main execution loop, #called-by
    # n-amespace facet when ouroboros is happening. about it: we "re-puff"
    # (that is, `pre_execute`) before every execution for fun, sanity, grease,
    # and design - ostensibly so that the p-arent can change the identity of
    # these resources late and during runtime while b) we can still have them
    # be simple ivars and not long-ass call chains. (also, the point is moot
    # insomuchas CLI's are not long running processes anyway!)

    # in this entire library (without extrinsic facets / extensions), of the
    # whole matryoshka stack [#040], the only resource we need is @y: the
    # standard error stream line yielder (makes sense, right?).

    def pre_execute
      # we override parent and do what our grandparent does. meh.
      @y = parent_services[ :y ]
      @last_hot = nil
      nil
    end
  end

  #   ~ 1.3 `Namespace` *core only* & support (not for deep namespaces) ~

  class Namespace  # #re-open for facet 1. no superclass.

    # the `Namespace` class is an abstract base class - it is meant only to
    # be subclassed; and to instantiate object from it directly has undefined
    # results. the `Namespace` class is the central embodiment of a DSL in
    # this library - it is the interface entrypoint for employing [#041]
    # `isomorphic command composition`, that is, public methods that you
    # write in your class become commands in your user interface. as such,
    # except where noted, the "n-amespace" of instance methods (public, private,
    # and protected) of this class is preserved entirely for "businessland"
    # concerns - that is, the developer user determines them, not this
    # library. again as such, for instance methods, you will only find one
    # defined here - `initialize`.

    #             ~ class section 1 - singleton methods ~

    class << self

      attr_reader :story  # #called-by cli mechanics, and elsewhere

    private

      def inherited kls

        # (because of its placelement and how the child class is written
        # respectively, this won't be called when CLI descends from NS,
        # only when businessland classes descend from either NS or CLI.)

        kls.class_exec do
          @do_track_method_added = true  # location 1 of 3 - this is for
          # the businessland class. needs to be outside of story becuase ..
          ( @story = NS_Sheet_.new self ).add_option_sheet BRANCH_HELP
        end
        nil
      end

      -> do  # `use` - covered by cli/api-integration/with-namespaces_spec.rb
        h = { as: -> a, rest { a[ 0 ] = rest.shift } }
        define_method :use do |*x_a|
          p = @do_track_method_added ; @do_track_method_added = false
          x_a.each do | ( svc_i, *rest ) |
            r = [ ]
            while rest.length.nonzero?
              h.fetch( rest.shift )[ r, rest ]
            end
            m, = r
            m ||= svc_i
            define_method m do |*a, &b|
              @mechanics.send svc_i, *a, &b
            end
            private m
          end
          @do_track_method_added = p
          nil
        end
      end.call
    end

    #    ~ class section 2 - the only instance method (which is private) ~

    def initialize *a

      block_given? and raise ::ArgumentError, "this crap comes back after #100"

      @mechanics ||= ( if self.class.const_defined? :Mechanics_, false
        self.class.const_get :Mechanics_, false
      else
        self.class.const_set :Mechanics_, ::Class.new( self.class::Mechanics__ )
      end ).enhance( self, a )  # (`enhance` rabbit hole begins!)

      # (remember, no need to call up to super. we have no superclass.)

      # (lazily, only once the surface is created do we check and see if a
      # custom `Mechanics_` class has been subclassed, defined, whatever, and
      # if not; we subclass a default mechanics class (descending from the
      # appropriate base class) and put it there. whichever class was resolved
      # from the above is the one used to enhance this surface and resolve a
      # @mechanics instance.)

      nil
    end

    # note there are no public (and only 1 private) instance method defined.
  end

  class NS_Sheet_ < Node_Sheet_  # for facet 1

    # the abstract representation of a n-amespace. before you build any actual
    # things, you can aggreate the data around it progressively.

    # the CLI client class (like many other entities here) internally stores
    # *all* its "businessland data" in a "character-sheet"-ish object
    # (sometimes called a "story" when it is in regards to a n-amespace).
    # A n-amespace's story consists of properties and constituents. the
    # properties are things like the n-amespace's normalized local slug name
    # and aliases. the constituents represent the n-amespace's child nodes
    # (either terminal commands or other namespaces (themselves a special kind
    # of command)). we say "represents" because actual n-amespace classes or
    # command objects are not necessarily built at declaration time. instead,
    # we may have as our constituents one sheet for each of this node's child
    # nodes. (deeply nested namespaces are then stories inside stories yay.)

    def initialize surface_mod
      if surface_mod  # no surface mod is bound "statically" when e.g we
        # have a strange module loaded by a function lazily, or if an inline
        # n-amespace is defined with a block (these all happen elsewhere)
        # watch for this becoming a case for two child classes of a shared
        # base class..
        @box = MetaHell::Formal::Box::Open.new
        @surface_mod = -> { surface_mod }
        @surface_mod_origin_i = :module
        @node_open = false ; @methods_need_to_be_indexed = true
        @skip_h = { }  # sad
        @scooper = Scooper_.new -> m do
          close_node do |cl|
            cl.set_method_name m
          end
        end
        define_singleton_method :method_was_added, & @scooper.get_method_added
      end
    end

    #               ~ class section 1 - public instance methods ~

    def command_tree  # #called-by documenters, everything
      if @methods_need_to_be_indexed
        @methods_need_to_be_indexed = false  # avoid re-entrancy now & future!
        sm = @surface_mod.call
        black_a, white_h = @scooper.get_black_a_and_white_h
        addme = sm.public_instance_methods( false ) - @box._order - black_a
        addme.each do |norm_i|
          @box.add norm_i, Cmd_Sheet_.new( norm_i )
        end
        @box.sort_names_by! do |i|
          white_h.fetch i do
            raise ::KeyError, "element (n#{ }amespace?) name not found in #{
              }order list (#{ i.inspect } in #{ white_h.keys.inspect })"
          end
        end
      end
      @box.length.zero? ? false : @box
    end

    attr_reader :node_open

    def close_node &blk
      n = @node_open ; @node_open = nil ; blk[ n ]
      @box.add n.normalized_local_command_name, n
      nil
    end

    def node_open!  # #called-by e.g Namespace for adding aliases
      @node_open ||= Cmd_Sheet_.new nil  # no method name yet.
    end

    def _scooper  # #called-by facets only, and here. for hacks & experiments.
      @scooper
    end

    def if_constituent norm_i, yes, no  # #exposed-for-hacks #todo:cover
      @box.if? norm_i, yes, no
    end

    def fetch_constituent norm_i, &no  # #called-by api facet, hacks
      @box.fetch norm_i, &no
    end
  end

  class NS_Mechanics_  # #re-open for facet 1

    # (this class broke out of Namespace itself and became a standalone
    # class during [#037], to address the concerns therein. its funny name
    # ending in an underscore means it is not part of the public API, nor
    # stable. it follows [#hl-073] extrinsic / intrinsic ivars.)

    #           ~ class section 1 - singleton methods ~

    class << self
    private
      def _enhance surface, h  # mutates h!  part of "extremely clever" above
        a = method( :__enhance ).parameters[ 1 .. -1 ].reduce [] do |m, (_, i)|
          m << h.delete( i )  # (yes it's just a map. but map would bloat?)
          m
        end
        # (for those of you tuning in at home, n-amespace/facet.rb?)
        h.keys.length.nonzero? and raise ::ArgumentError, "is #{
          }#{ self.name } supposed to handle (#{ h.keys * ', ' })?"
        __enhance surface, *a
      end
    end

    def initialize sheet, surface, parent_services, slug_fragment
      @surface = -> { surface }  # a n-amespace always has a surface
      super sheet, parent_services, slug_fragment
      nil
    end

    #          ~ class section 2 - core public instance methods ~

    # (use the `initialize` of p-arent - (sheet, parent_services, slug))

    # `find_command` #existential-workhorse #called-by-main-invocation-loop
    # #result-is-tuple. assume `argv` length is greater than or equal to 1.
    # remove at most 1 element off the head of `argv. #result-is-tuple. if
    # command can be resolved, a *h-ot* subcommand is the payload element of
    # the pair.

    def find_command argv
      given = argv.fetch 0
      rx = /\A#{ ::Regexp.escape given }/
      found_a = when_puffed do
        @sheet.command_tree or break Empty_A_
        catch :break_two do
          @sheet.command_tree.reduce [] do |mem, (_, node)|
            num = node.all_aliases.reduce 0 do |m, nm|
              if given == nm
                throw :break_two, ( mem.clear << node )
              end
              rx =~ nm ? ( m + 1 ) : m  # keep looking, maybe exact match
            end
            mem << node if num.nonzero?
            mem
          end
        end
      end
      len = found_a.length
      if 1 == len
        sht = found_a[ 0 ]
        if ! (( @last_hot = sht.hot self, argv.shift ))
          @y << "(\"#{ sht.name.as_slug }\" command failed to load)"
          sht.is_ok = false
          len = 0
        end
      end
      case len
      when 0 ; unrecognized_command given
      when 1 ; [ true, @last_hot ]
      else   ; ambiguous_command found_a, given
      end
    end

    def pre_execute  # #called-by-main-invocation-loop
      # (we override this method of parent class (cmd) b.c we need to do kind
      # of like what cli does - we need the surface also to have ivars..)
      ps = parent_services
      @y = ps[ :y ]
      parent_shell.instance_exec do
        @out, @err, @y = ps[ :ostream, :estream, :y ]
      end
      @last_hot = nil
      nil
    end

    def parent_shell
      @surface.call
    end

    def istream
      parent_services.istream
    end

    def ostream  # necessary for true ouroborous
      parent_services.ostream
    end

    def estream
      parent_services.estream
    end

    def set_last_hot x  # #called-by Option_Block#build_into
      @last_hot = x     # this replaces the @command ivar we used to use,
      nil               # used when doing o.p hacks
    end
  end

  Empty_A_ = [ ].freeze  # detect shenarnigans, have OCD

  class Command  # #re-open for facet 1

    # @todo:#100.100.400 rename to 'Action'  (maybe..)

    # (note the pattern that emerges in the order)

    def initialize sheet, parent_services, _slug_fragment=nil
      @argv = nil  # only set in one place. usually for command-like options.
      @op = nil
      @queue_a = nil  # allows transactional o.p, command-like options.
      @sheet = sheet
      @parent_services = -> { parent_services } if parent_services
      # (`_slug_fragment` not currently stored insomuch as what the user typed
      # (or which alias was used) to get this command is unimportant to us now.)
    end

    #            ~ class section 1 - public instance methods ~

    attr_reader :sheet  # #called-by facets. because of [#037] we can again
    # reveal this with impunity.

    # `process_queue` #in-accordance-with: `o.p mechanics API`.
    # #result-is-tuple:complex. #called-by e.g. `process_options`.

    def process_queue
      q_a = option_parser_receiver.instance_exec do
        if instance_variable_defined? :@queue_a
          r = @queue_a
          @queua_a = nil
          r
        end
      end
      if ! q_a || q_a.length.zero?   # then stay. any opts that
        [ true, true ]                         # were parsed already expressed.
      else
        @queue_a and fail "sanity - test me - procede with caution"
        @queue_a = q_a
        [ true, false, self, :flush_queue ]
      end
    end

    # `method_name` #called-by-main-invocation-loop
    # #existential-workhorse
    # remeber it is not we who actually execute the implementation.

    def method_name  # called when the `parse` was successful - remember
      @sheet.method_name  # it is not we who actually execute the implementation
    end

    def pre_execute  # #called-by-main-invocation-loop
      @y = parent_services[ :y ]
      nil
    end

    #          ~ class section 2 - private instance methods ~

  private

    def parent_services
      @parent_services.call
    end

    alias_method :parent_shell, :parent_services

    # `flush_queue` - hookback for `process_queue` above. #result-is-exit-code

    def flush_queue
      ok = true ; q_a = @queue_a  # then activity happened.
      begin
        m, *a = @queue_a.shift ; recev = option_parser_receiver
        rcv = if recev.class.method_defined? m or
            recev.class.private_method_defined? m then recev else self end
        o, r = rcv.send m, *a
        ( ok &&= o ) or break     # stop if ever not ok
      end while q_a.length.nonzero?
      r                           # final exit status is whatever the last
    end                           # result was.
  end

  class Cmd_Sheet_ < Node_Sheet_   # open for facet 1.

    def initialize method_name=nil
      @name = nil ; @has_options = false
      if method_name
        @name_origin_i = :method ; @name_x = method_name
        # ( imagine this like an opcode sexp then it makes sense )
      else
        @name_origin_i = :none ; @name_x = nil
      end
    end

    #            ~ class section 1 - public instance methods ~

    # `hot` - #called-by `find_command` - a hot, live action is requested

    def hot parent_services, *rest_to_command
      # (`alias_used` nil e.g in the case of a command tree index listing)
      cmd = Command.new self, parent_services, *rest_to_command
      cmd.pre_execute
      cmd
    end

    attr_reader :name_origin_i, :name_x  # #called-by mech

    def set_method_name x
      :none == @name_origin_i or raise "won't set name with method when #{
        }name already set with #{ @name_origin_i }"
      @name_origin_i = :method ; @name_x = x
      x
    end

    # `method_name`
    -> do
      h = {
        method: -> { @name_x },
        nln: -> do
          raise "sanity - it is meaningless to speak of a method name in #{
            }association with this command"
        end
      }
      define_method :method_name do
        instance_exec( & h.fetch( @name_origin_i ) )
      end
    end.call

    -> do  # `name`  # #called-by command and children to be `name`
      f = -> x { Services::Headless::Name::Function.new x }
      h = {
        none: -> _ { false },
        method: f,
        nln: f
      }
      define_method :name do
        if @name.nil?
          @name = h.fetch( @name_origin_i ).call( @name_x )
        end
        @name
      end
    end.call
  end

  class Node_Sheet_  # open for facet 1

    #  ~ section 0 - notes for subclasses ~
    #    + restricted n-amespace "set_xtra_*" for class-internal API
    #    + must implement a (possibly false-ish resulting) private method
    #      `name` that memoizes its result to `@name`
    #    + there is no `initialize` defined here.

    #  ~ section 1 - public instance methods ~

    def normalized_local_command_name
      @name.normalized_local_name if name
    end

    def is_ok= b
      @not_ok = ! b
    end

    attr_reader :not_ok

    def is_ok
      ! not_ok
    end

  private

    # `absorb_xtra` - #called-by instance of child class : e.g NS_Sheet_
    # we do it this way and not with using the attr_writer b.c using `foo=`
    # is too conceptually limiting - its conventional interface is a) not the
    # same as ours and b) ambiguous for how to procede with errors and c)
    # semantically confusing if e.g we are concat'ign and not setting.
    # we use methods and not a function hash (for tacit validation of `k`)
    # for extensibility.

    def absorb_xtra xtra_pairs
      xtra_pairs.each_pair do |k, v|
        send :"absorb_xtra_#{ k }", v
      end
      nil
    end
  end

  #     ~ 1.4 - implement "parent services" with a new DSL wat ~

  class Services_  # ( basically a miniature version of Headless::Plugin )
    Services_Ivar_ = nil
    class << self
      alias_method :orig, :new

      def enhance host_mod, & defn_blk
        pxy = ( if host_mod.const_defined? :Services_, false
          host_mod.const_get :Services_, false
        else
          host_mod.const_set :Services_, Services_.new
        end )
        pxy.send :absorb_services_defn_blk, defn_blk  # we want to be private
        sam = pxy::Services_Accessor_Method_
        siv = pxy::Services_Ivar_ || :@services
        if ! ( host_mod.method_defined? sam or
                host_mod.private_method_defined? sam ) then
          host_mod.module_exec do
            define_method sam do |*a|
              svcs = if instance_variable_defined? siv then
                instance_variable_get siv
              else
                instance_variable_set siv, self.class::Services_.new( self )
              end
              svcs.send sam, *a
            end
            private sam
          end
        end
        nil
      end

      def new &defn_blk
        ::Class.new( self ).class_exec do
          class << self ; alias_method :new, :orig end
          initialize
          defn_blk and absorb_services_defn_blk defn_blk
          self
        end
      end

    private

      -> do  # `initialize`
        mf_h = {
          ivar: -> i, ivar=nil do
            ivar ||= "@#{ i }".intern
            -> { @ivar[ ivar ] }
          end,
          method: -> i, method=nil do
            method ||= i
            -> { @self_send[ method ] } if method != i
          end,
          up: -> i do
            -> { @up[ i ] }
          end
        }
        define_method :initialize do
          sam = siv = did_sam = did_siv = nil ; svc_queue_a = [ ]
          @absorb_services_defn_blk = -> blk do
            Conduit_.new(
              -> i do
                siv and fail "won't clobber existing #{
                  } services ivar - #{ @svc_ivar }"
                siv = i
              end,
              -> i do
                sam and fail "won't clobber existing #{
                  } services accessor method: #{ sam }"
                sam = i
              end,
              -> a { svc_queue_a.concat a ; nil }
            ).instance_exec( & blk )
            if ! did_siv && siv
              did_siv = true
              const_set :Services_Ivar_, siv
            end
            if ! did_sam && sam
              did_sam = true
              const_set :Services_Accessor_Method_, sam
              define_method sam do |*a|
                if 1 == a.length then __send__ a.fetch( 0 )
                else a.map { |i| __send__ i } end
              end
            end
            while svc_queue_a.length.nonzero?
              i, mf, *rest = svc_queue_a.shift
              if ! mf_h.key? mf
                AT_ == mf.to_s.getbyte( 0 ) or fail "syntax - ivar? #{ mf }"
                rest.unshift mf
                mf = :ivar
              end
              blk = mf_h.fetch( mf )[ i, * rest ]
              define_method i, & blk if blk
            end
            nil
          end
          nil
        end
        AT_ = '@'.getbyte 0
        class Conduit_
          def initialize siv, sam, svs
            @h = { siv: -> i { siv[ i ] },
                   sam: -> i { sam[ i ] },
                   svs: -> a { svs[ a ] } }
          end
          def services_ivar i ; @h[:siv][ i ] end
          def services_accessor_method i ; @h[:sam][ i ] end
          def services *a ; @h[:svs][ a ] end
        end
      end.call

      def absorb_services_defn_blk blk
        @absorb_services_defn_blk[ blk ]
      end
    end

    def initialize provider
      @ivar = -> ivar do
        if provider.instance_variable_defined? ivar
          provider.instance_variable_get ivar
        else
          raise "will not access ivar that is not defined (#{ ivar }) of #{
            }#{ provider.class }"
        end
      end
      @self_send = -> meth do
        __send__ meth, provider
      end
      @up = -> i do
        sam = self.class::Services_Accessor_Method_
        @up = provider.instance_exec do
          -> sym do
            parent_services.__send__ sam, sym
          end
        end
        @up[ i ]
      end
      nil
    end
  end

  CLI_Surface_Pxy_ = Services_.new do
    services_ivar :@surface_services
    services_accessor_method :[]
    services [ :y, :ivar ],
             [ :istream, :@sin ],
             [ :ostream, :@out ],
             [ :estream, :@err ],
             [ :program_name, :method, :_program_name ]

  end
  class CLI_Surface_Pxy_
    def _program_name surface
      surface.instance_exec do
        instance_variable_defined? :@program_name and @program_name
      end or ::File.basename( $PROGRAM_NAME )
    end
    def last_hot ; end ; def set_last_hot _ ; end  # we don't want the topmost
    # mechanics node to concern itself with the fact that it is topmost here
  end

  class NS_Mechanics_  # #re-open for 4.1. has parent.
    Services_.enhance self do
      services_ivar :@ns_mechanics_services
      services_accessor_method :[]
      services [ :y, :ivar ],
               [ :istream, :up ],
               [ :ostream, :up ],
               [ :estream, :up ],
               [ :program_name, :up ]
    end
    public :[]
  end

  class CLI_Mechanics_  # #re-open for 1.4. has parent.
  private
    def parent_services
      @parent_services ||= CLI_Surface_Pxy_.new @surface.call
    end
  end

  #            ~ facet 2 - option representation & parsing ~

  class Namespace  # #re-open for facet 2. no p-arent.
    class << self
    private
      def on first, *rest, &b  # make an intrinsic option for self.
        @story.on first, *rest, &b
      end

      def option_parser &blk  # make an o.p for the following command (method)
        @story.child_option_parser( &blk )
        nil
      end
    end
  end

  class NS_Sheet_  # #re-open for facet 2. has p-arent.

    def on first, *rest, &blk
      add_option_sheet Option_Sheet.new( rest.unshift( first ), blk )
    end

    def option_parser &blk  # NOTE own option parser. so named for consistency
      add_option_sheet Option_Block.new( blk )
    end

    def child_option_parser &blk
      node_open!.add_option_parser_block blk
      @scooper.do_scoop_next_method!  # re-stating true is fine.
      nil
    end
  end

  class NS_Mechanics_

    def surface_receiver  # #called-by-main-invocation-loop
      parent_shell
    end

    # `option_parser_receiver` - #buck-stopper different from a leaf node
    # (command), the receiver of whose option parser is ..  see [#039]
    # #called-by-child

    def option_parser_receiver
      parent_shell
    end

    def option_parser_mechanics
      self
    end

    attr_reader :last_hot  # #called-by api intergration services, `init_op`

  private

    def option_syntax
      super if ! @sheet.command_tree  # otherwise it just gets in the way
    end

    def terminal_option_syntax  # assume @op
      a = each_option.reduce [] do |m, opt|
        m << opt.as_shortest_full_parameter_signifier
      end
      "{#{ a * '|' }}" if a.length.nonzero?
    end
  end

  class Command  # #re-open for facet 2

    # `process_opttions` - #existential-workhorse #result-is-tuple:complex
    # #called-by-main-invocation-loop. #assume '-' == argv[0][0].

    def process_options argv, do_permute=false
      begin
        option_parser_receiver.instance_exec do
          instance_variable_defined? :@argv and fail "sanity - test me"
          @argv = argv  # #monadic #experimental some switches do custom
        end             # parsing.
        option_parser or break( r = [ true, true ] )  # pass the buck
        begin                                  # parse destructively, in order
          if do_permute                        # (permute is typically used
            @op.permute! argv                  # for terminal nodes ("commands")
          else                                 # as op. to namespaces.)
            @op.order! argv                    # NOTE stop at 1st non-{arg|opt}!
          end
        rescue ::OptionParser::ParseError => e
          parse_error = true                   # don't linger in this frame
        end
        if parse_error
          reason highlight_header( e.message )  # then don't stay. short-
          break( r = [ false, false, nil ] )  # circuit. early completion.
        end
        r = option_parser_mechanics.process_queue
      end while nil
      r
    end

    def option_parser_receiver                 # a command is not the receiver
      parent_services.option_parser_receiver   # for op blocks, #called-by.
    end

  private

    # `process_options` support

    def option_parser  # (this is not the `documenter`)
      @op.nil? and init_op
      @op
    end

    def op
      @op  # #avoid-warning
    end
    public :op  # experts only - might be called from an option parser block

    def init_op
      @op and fail "sanity" ; @op = op = build_empty_option_parser ; me = self
      @ugly_str, @ugly_id = op.banner.dup, op.banner.object_id  # for doc hack
      option_parser_receiver.instance_exec do  # stdlib o.p's default handling of help just
        # straight up exits after processing help, which is unacceptable here.
        op.base.long[ 'help' ] = op.class::Switch::NoArgument.new do
          ( @queue_a ||= [ ] ) << [ :show_help, me ]
        end  # life is then easier with this invisible option overriding it.
      end
      if @sheet.has_option_sheets
        p = parent_services.last_hot
        @sheet.option_sheet_a.each do |op_sheet|
          op_sheet.build_into op, self
        end
        parent_services.set_last_hot p  # `p` is for "pretty awful"
      end
      nil
    end

    def build_empty_option_parser
      op = Face::Services::OptionParser.new
      op.base.long.clear  # no builtin -h or -v
      op
    end

    def option_parser_mechanics
      parent_services.option_parser_mechanics
    end

    # maybe hackishly, maybe not, but our `documenter` is our option parser
    # (the same instance) but with the banner maybe set to an enhanced string.

    def documenter
      if has_partially_visible_op
        @op.nil? and init_op
        @did_prerender_help ||= prerender_help
        @op
      end
    end

    def has_fully_visible_op
      @sheet.has_option_sheets and
        @sheet.option_sheet_a.detect( & :is_fully_visible )
    end

    def has_partially_visible_op
      @sheet.has_option_sheets
    end

    def option_syntax
      if option_parser && has_partially_visible_op
        a = each_option.reduce [] do |m, opt|
          m << "[#{ opt.as_shortest_full_parameter_signifier }]"
        end
        a * ' ' if a.length.nonzero?
      end
    end

    def each_option  # assumes that @op (when constructed) will be an o.p
      @op_enum ||= begin
        @op.nil? and init_op
        opt = Services::Headless::CLI::Option.new_flyweight
        ea = Services::Headless::CLI::Option::Enumerator.new @op
        ea.filter = -> sw do
          opt.replace_with_switch sw
          opt
        end
        ea
      end
    end

    def options  # #called-by self `parameters`
      @options ||= -> do
        scn = nil ; op_x = option_parser ? @op : Empty_A_
        Face::Options.new(
          fetch: -> ref, &blk do
            scn ||= Services::Headless::CLI::Option::Parser::Scanner.new op_x
            scn.fetch ref, &blk
          end  )
      end.call
    end
    Face::Options = MetaHell::Proxy::Nice.new :fetch

  end

  class Node_Sheet_  # #re-open for facet 2.

    def add_option_sheet option_x
      @has_option_sheets ||= true
      ( @option_sheet_a ||= [ ] ) << option_x
      nil
    end

    attr_reader :option_sheet_a, :has_option_sheets

    def add_option_parser_block blk
      add_option_sheet Option_Block.new( blk )  # (we used to avoid creating
      nil                 # this extra object this early. but we simplified.)
    end
  end

  class Option_Sheet

    # the abstract representation of an option, so you can store the
    # arguments passed to `on` in a separate pass, before you build the o.p

    def initialize args, blk, is_fully_visible=true
      @args, @block, @is_fully_visible = args, blk, is_fully_visible
    end

    attr_reader :args, :block, :is_fully_visible

    def build_into op, svcs # #existential-workhorse
      if @block.arity.zero?
        op.define( * @args ) do
          svcs.option_parser_receiver.instance_exec( & @block )
        end
      else
        op.define( * @args ) do |v|
          svcs.option_parser_receiver.instance_exec( v, & @block )
        end
      end
      nil
    end
  end

  class Option_Block

    # the abstract representation of an option block, lets it get processed
    # harmoniously inline with `Option_Sheet`

    def initialize blk
      @block = blk
    end

    def is_fully_visible
      true
    end

    def build_into op, svcs  # #existential-workhorse
      b = @block
      svcs.option_parser_receiver.instance_exec do
        @mechanics.set_last_hot svcs  # some o.p blocks want it both ways -
        # that is, they expect their context to be the p-arent command node
        # ("n-amespace"), and also they want access to the particular command's
        # services, and that's OKAY.
        instance_exec op, & b  # (`option_parser`)
        @mechanics.set_last_hot nil
      end
      nil
    end
  end

  # ~ facet 3 - argv processing ~

  class CLI_Mechanics_  # #re-open for facet 3

    # we don't know if we love this or hate it. originally it was easy and
    # had high novelty value to let this isomorphicism extend all the way to
    # to this level but then it looked more ugly then elegant, but again now
    # it seems like it might be ok because it is in accord with the whole
    # spirit of this thing. meh who cares its just CLI [#fa-004].

    def argument_error ex, cmd  # result will be final result
      md = Services::Headless::FUN.call_frame_rx.match ex.backtrace.fetch( 1 )
      if __FILE__ == md[:path] && 'invoke' == md[:meth]  # #todo that one thing
        @y << ex.message
        cmd.usage @y
        cmd.invite @y
        nil  # final-result
      else
        raise ex  # then it didn't originate from the above spot .. ICK
      end
    end
  end

  class NS_Mechanics_  # #re-open for facet 3

    # `parse` - #called-by-main-invocation-loop. #result-is-tuple:complex
    # assume default argv was covered before. the below is characteristic
    # behavior of branches.

    def parse argv
      if argv.empty?
        report_expecting
      else
        super
      end
    end

    def get_command_parameters sheet  # #called-by-child when documenting
      if sheet.has_command_parameters_function
        sheet.command_parameters_function_value.call
      elsif :method == sheet.name_origin_i
        parent_shell.method( sheet.name_x ).parameters
      else
        fail "sanity - can't get method parameters from client when #{
          }name is #{ sheet.name_origin_i } (maybe set #{
          }`command_parameters_function`?) (for client #{
          }#{ surface_receiver.class })"
      end
    end
  end

  class Command  # #re-open for facet 3

    # `parse` - #existential-workhorse #called-by-main-invocation-loop
    # like `process_options` but for a terminal node ("command").
    # #result-is-tuple:complex.

    def parse argv
      if option_parser
        process_options argv, true  # very likely [ false, false, nil ]
      else
        fail 'test me - you have to try hard not to have an o.p'  # #todo
        [ true, true ]
      end
    end
  end

  class Node_Sheet_  # #re-open for face 3

    def set_command_parameters_function f
      has_command_parameters_function and fail "sanity - clobber cpf?"
      @has_command_parameters_function = true
      @command_parameters_function_value = f
      nil
    end

    attr_reader :has_command_parameters_function

    def command_parameters_function_value
      @has_command_parameters_function or fail "check `has_..` first"
      @command_parameters_function_value
    end
  end

  # ~ facet 4 - core help & UI ~

  # ~ facet 4.1 - a narrative about `normal_last_invocation_string` ~

  class CLI_Mechanics_  # #re-open for facet 4.1
    def normal_last_invocation_string          # for UI, narrative from here
      ( last_hot_recursive || self ).normal_invocation_string
    end
    def last_hot_recursive                     # #in-narrative,
      @last_hot.last_hot_recursive if @last_hot  # any last used command or nil
    end
    def get_normal_invocation_string_parts     # #in-narrative, #global-svc
      [ parent_services.program_name ]         # resolves a name for UI.
    end                                        # (note level 1 is included)`
  end
  class NS_Mechanics_  # #re-open for facet 4.1
    def normal_last_invocation_string          # for UI, narrative from here
      last_hot_recursive.normal_invocation_string
    end
    def last_hot_recursive                     # #in-narrative
      @last_hot ? @last_hot.last_hot_recursive : self
    end
  end
  class Command  # #re-open for facet 4.1
    def last_hot_recursive                     # #in-narrative #buck-stopper
      self
    end
    def normal_invocation_string               # #in-narrative
      get_normal_invocation_string_parts * ' '
    end
    def get_normal_invocation_string_parts     # #in-narrative
      parent_services.get_normal_invocation_string_parts << name.as_slug
    end
    def name                                   # #in-narrative
      @sheet.name
    end
  end

  #  ~ facet 4.2 - a related narrative about `anchorized_last` etc ~

  class NS_Mechanics_                          # #re-open for facet 4.2
    def anchorized_last                        # #in-narrative
      last_hot_recursive.anchorized_name
    end
  end
  class Command
    def anchorized_last                        # when @last_hot is command
      anchorized_name
    end
    def anchorized_name
      @anchorized_name ||= get_anchorized_name.freeze
    end
    def get_anchorized_name                    # #in-narrative
      parent_services.get_anchorized_name << name.normalized_local_name
    end
  end
  class CLI_Mechanics_                         # #re-open for facet 4.2
    undef_method :anchorized_last              # this is only ever for childs
    def get_anchorized_name                    # #in-narrative, for
      [ ]                                      # resolving an action's name.
    end
    def margin                                 # #buck-stopper (sneaks in here)
      MARGIN_                                  # one day `set_margin` here, or
    end                                        # appearance customoziation DSL
    MARGIN_ = '  '.freeze
  end

  #  ~ facet 4.3 - more cosmetic concerns ~

  class Namespace
  private

    def hi x  # in violation of [#037] we provide this common nerk for derking
      @mechanics.hi x
    end
  end

  class NS_Mechanics_  # #re-open for facet 4. has p-arent.

    # `subcommand_help` - #result-is-tuple #called-by `process_queue`

    def subcommand_help command, *rest
      argv = rest.unshift command  # (to be clear, it is a contiguous subset
      node = self                # of the received argv)
      while true  # imagine `find_command_recursive`
        stay, cmd = node.find_command argv
        stay or break
        argv.length.zero? and break
        if ! cmd.respond_to? :find_command
          stay, res = false, nil
          @y << "Unexpected argument#{ 's' if 1 != argv.length }: #{
            }#{ argv[0].inspect }#{ ' [..]' if 1 < argv.length }"
          @y << "#{ hi usage_header_text } #{ normal_invocation_string } #{
              parameters.fetch( :help ).as_shortest_nonfull_signifier
            } [cmd [sub-cmd [..]]]"
          invite @y
          break
        end
        node = cmd
      end
      if ! stay then [ stay, res ] else
        subcmd_help cmd  # just a little hook
      end
    end

  private

    def parameters  # #called-by self - `subcommand_help`
      @parameters ||= Face::Parameters.new(
        fetch: -> ref, &blk do
          ok = false
          res = options.fetch ref do ok = true end
          if ok
            res = arguments.fetch ref do ok = false end   # etc #todo
            if ! ok  # meh
              blk ||= -> _ { raise ::KeyError, "not found - #{ ref }" }
              res = blk[ ref ]
            end
          end
          res
        end )
    end
    Face::Parameters = MetaHell::Proxy::Nice.new :fetch  # only here b.c etc.

    # `subcmd_help` - #result-is-tuple. a hook for the benefit of both child
    # classes and nodes - it corrals help requests coming in from 2 places:
    # the both pre- and postfix forms.

    def subcmd_help cmd
      cmd.help
      any = option_parser_receiver.instance_exec do
        @argv.length.nonzero? || @queue_a.length.nonzero?
      end
      [ any, nil ]
    end

    def report_expecting
      reason "Expecting #{ expecting }."
      [ false, false ]
    end

    def expecting  # #styled
      when_puffed do
        if @sheet.command_tree
          a = @sheet.command_tree.reduce [] do |m, (_, x)|
            m << "#{ hi x.name.as_slug }" if x.is_ok
            m
          end
          a * ' or ' if a.length.nonzero?
        end or 'nothing'
      end
    end

    def unrecognized_command given
      reason "Unrecognized command: #{ given.inspect }. #{
        }Expecting: #{ expecting }"
      [ false, nil ]
    end

    def ambiguous_command found, given  # #todo not covered
      reason "Ambiguous command: #{ given.inspect }. #{
        }Did you mean #{ found.map { |c| hi c.name.as_slug } * ' or ' }?"
      [ false, nil ]
    end

    def invite y
      # override parent to include the "[sub-cmd]" part.
      y << "try #{ hi "#{ normal_invocation_string } -h [sub-cmd]" } #{
        }for help."
      nil
    end

    def argument_syntax
      if @sheet.command_tree
        a = @sheet.command_tree.reduce [] do |m, (_, c)|
          m << c.name.as_slug
        end
        if a.length.nonzero?
          "{#{ a * '|' }} [opts] [args]"
        end
      end
    end

    def additional_usage_lines
      if @sheet.command_tree && has_partially_visible_op
        if (( tos = terminal_option_syntax ))
          y = get_normal_invocation_string_parts
          y.unshift( ' ' * usage_header_text.length )
          [ ( y << tos ) * ' ' ]
        end
      end
    end

    def additional_help y
      a = @sheet.command_tree
      if a
        y << hi( "command#{ 's' if 1 != a.length }:" )
        item_a = a.reduce [] do |row, (_, sht)|
          hot = sht.hot self
          hot and row << Item_[ hot.name.as_slug, hot.summary ]
          row
        end
        w = item_a.map { |o| o.hdr.length }.reduce 2 do |m, l| m > l ? m : l end
        mar = margin
        fmt = "%#{ w }s#{ mar }"
        item_a.each do |item|
          if ! item.lines || item.lines.length.zero?
            y << "#{ mar }#{ hi( fmt % item.hdr ) } the #{ item.hdr } command"
          else
            y << "#{ mar }#{ hi( fmt % item.hdr ) }#{ item.lines.first }"
            item.lines[ 1 .. -1 ].each do |line|
              y << "#{ mar }#{ fmt % '' }#{ line }"
            end
          end
        end
        y << "Try #{ hi "#{ normal_invocation_string } -h <sub-cmd>" } #{
          }for help on a particular command."
      end
      nil
    end
    Item_ = ::Struct.new :hdr, :lines

    def margin
      parent_services.margin
    end
  end

  class Command  # #re-open for facet 4. no p-arent.

    # `help` - #result-is-tuple
    # #called-by `process_queue`, p-arent documenting child.

    def help
      when_puffed do
        y = @y
        if documenter
          y << @op.banner  # (cognizant of hack)
          @op.summarize y
        else
          y << usage_line
        end
        additional_help y
        # rather than ignoring args that came after us, we will let the main
        # loop decide what to do with them. stay if any args left.
        [ @argv && @argv.length.nonzero?, nil ]
      end
    end

    def invite y  # #called-by-p-arent documenting this child
      y << "Try #{ hi "#{ parent_services.normal_invocation_string } -h #{
        }#{ name.as_slug }" } for help."
      nil
    end

    def usage y  # #called-by-p-arent documenting child
      y << usage_line
      x = additional_usage_lines and y.concat x
      nil
    end

    def usage_line  # #called-by-p-arent (may be) documenting child
      "#{ hi usage_header_text } #{ syntax }"
    end

    # `summary` - # #called-by-p-arent documenting child #experimental
    # *lots* of goofing around here - this terrific hack tries to
    # distill a summary out of the first one or two lines of the option parser
    # -- it strips out all styling from them (b.c it looks wrong in summaries),
    # and indeed strips out the styled content all together unless (ICK) that
    # header says "usage:" #experimental proof-of-concept novelty hack.
    # not actually ok.

    -> do

      hack_excerpt_from_option_parser = -> do

        hl_is_loaded = load_hl = unstylize_sexp = parse_styles = chunker =
          header_rx = excerpt_str_h = unstyle_h = first_lines = nil

        hack_exp_fr_op = -> op, usage_header_txt do
          hl_is_loaded || load_hl[]
          lines = first_lines[ op, 2 ]
          excerpt_str_h ||=
            {  1 => -> a { a[0] },
               2 => -> a { "#{ a[0] } [..]" } }
          exrp_s = excerpt_str_h.fetch( lines.length ).call lines
          sexp = parse_styles[ exrp_s ]
          if ! sexp then [ exrp_s ] else  # if there was no styling we are done
            enum = chunker::Enumerator.new sexp
            unstyle_h ||= {
              string: -> m, x do
                m << unstylize_sexp[ x ]
                nil
              end,
              style: -> m, x do
                s = unstylize_sexp[ x ]
                # ICK only let a header through if it says "usage:" ICK
                m << s if usage_header_txt == s || header_rx !~ s
                nil
              end
            }
            pts = enum.reduce [] do |m, x|
              unstyle_h.fetch( x[0][0] )[ m, x ]
              m
            end
            [ pts.join( '' ).strip ]
          end
        end

        # because we just can't bare the thought of rendering the whole o.p..
        first_lines = -> op, num do
          lines = op.banner.split( "\n" )[ 0, num ]
          if lines.length < num
            catch :face_hack do
              op.summarize do |s|
                lines << s
                throw :face_hack if num <= lines.length
              end
            end
          end
          lines
        end

        load_hl = -> do
          # lazy load these, might be a beast, and the dependency is awkward
          chunker = Services::Headless::CLI::Stylize::Chunker
          parse_styles, unstylize_sexp =
            Services::Headless::CLI::FUN.at :parse_styles, :unstylize_sexp
          hl_is_loaded = true
        end

        # a_few_lines_rx = /\A[\n]*([^\n]*)(\n+[^\n])?/
        # (in case we ever go back to op.to_s, this is what we used #todo)

        header_rx = /\A[^ ]+:[ ]?\z/  # no tabs [#hl-055]

        hack_exp_fr_op
      end.call

      define_method :summary do
        if documenter
          exrp_a = hack_excerpt_from_option_parser[ @op, usage_header_text ]
        end
        if exrp_a then exrp_a else
          [ "usage: #{ syntax }" ]  # like `usage_line` but unstylized
        end
      end
    end.call

    # `hi` (highlight) #called-by self and possibly from the parent shell
    # (surface).. (we used to have ohno=red, yelo=yellow, bold=(bright,green))

    def hi str
      style str, :green
    end                    # (was once `Colors` in a different age)

    -> do  # `style` - same notes as `hi`

      h = { bright: 1, red: 31, green: 32, yellow: 33, cyan: 36, white: 37 }

      esc = "\e"  # "\u001b" ok in 1.9.2

      define_method :style do |str, *styles|
        codes = styles.reduce [] do |m, x|
          if ::Integer === x then m << x else
            xx = h[ x ] and m << xx
          end
          m
        end
        "#{ esc }[#{ codes * ';' }m#{ str }#{ esc }[0m"
      end
      private :style
    end.call

  private

    -> do  # `highlight_header` (first seen in `process_options`)

      header_rx = /\A([^:]+:)/

      define_method :highlight_header do |str|
        str.sub header_rx do
          "#{ hi $1 }"
        end
      end
      private :highlight_header
    end.call

    def reason txt  # atypical early exit with reason, e.g `report_expecting`
      @y << txt
      invite @y
      nil
    end

    def show_help cmd
      stay, res = cmd.help
      if stay then [ stay, res ] else
        [ @queue_a.length.nonzero?, res ]
      end
    end

    def prerender_help
      # we only "enchance" the main o.p if you didn't write or modify your
      # own banner (very ICK but also kind of MEH)
      if @ugly_str == @op.banner && @ugly_id == @op.banner.object_id
        y = [ ]
        usage y
        sum = @op.base.list.length + @op.top.list.length
        if sum.nonzero?
          y << "#{ hi "option#{ 's' if 1 != sum }:" }" # `options:` (#2 of 2)
        end
        @op.banner = y * "\n"
      end
      true  # important!
    end

    -> do  # `usage_header_text`
      txt = 'usage:'.freeze
      define_method :usage_header_text do txt end
      private :usage_header_text
    end.call

    def syntax
      x = nil
      a = get_normal_invocation_string_parts  # sneaky use of this
      a << x if ( x = option_syntax )
      a << x if ( x = argument_syntax )
      a * ' '
    end

    -> do  # `argument_syntax`
      reqity_brackets = nil
      define_method :argument_syntax do
        part_a = parent_services.get_command_parameters( @sheet ).
            reduce [] do |m, x|
          a, z = ( reqity_brackets ||=  # narrow the focus of the dep for now
            Services::Headless::CLI::Argument::FUN.reqity_brackets )[ x[0] ]
          m << "#{ a }<#{ FUN.slugulate[ x[1] ] }>#{ z }"
        end
        part_a * ' ' if part_a.length.nonzero?
      end
      private :argument_syntax

      FUN_[:slugulate] = -> x do
        Services::Headless::Name::FUN.slugulate[ x ]
      end  # (narrow focus of the dependency for now (but trivial))

    end.call

    def additional_help y  # (hook for child classes to exploit handily)
    end

    def additional_usage_lines  # (hook that is for now only by branch nodes.)
    end
  end

  BRANCH_HELP = Option_Sheet.new(
    [ '-h', '--help [cmd]', 'this screen [or sub-command help]' ].freeze,
    -> x do
      @queue_a ||= [ ]
      if ! x then @queue_a << :help else
        args = [ x ]  # cutely scoop any subsequent args off argv.
        while @argv.length.nonzero? and '-' != @argv[0][0]
          args << @argv.shift
        end
        @queue_a << [ :subcommand_help, * args ]
      end
    end,
    false
  ).freeze

  # ~ facet 5 - extrinsic features ~

  # ~ 5.1 - default argv ~

  class Namespace  # #re-open for 5.1. no parent.
    class << self
    private
      def default_argv *a
        @story.set_default_argv a
      end
    end
  end

  class NS_Sheet_  # #re-open for 5.1
    def set_default_argv a
      has_default_argv and raise ::ArgumentError,
        "won't overwrite existing `default_argv`"  # for now, but meh..
      @has_default_argv = true
      @default_argv_value = a
      nil
    end

    attr_reader :has_default_argv

    def default_argv_value
      @has_default_argv or fail "sanity - check `has_default_argv` first"
      @default_argv_value
    end
  end

  class NS_Mechanics_  # #re-open for 5.1
    def has_default_argv
      @sheet.has_default_argv
    end

    def default_argv_value
      @sheet.default_argv_value
    end
  end

  # ~ 5.2.1 - aliases ~

  class Namespace  # #re-open for face 5.2.1
    def self.aliases * i_a
      @story.node_open!.add_aliases i_a
    end
  end

  class Node_Sheet_  # #re-open for facet 5.2.1

    def add_aliases i_a
      @aliases_are_puffed = nil
      ( @alias_a ||= [ ] ).concat i_a
      nil
    end

    def all_aliases
      if ! name then Empty_A_ else  # otherwise too annoying
        if ! aliases_are_puffed
          @all_alias_a ||= [ @name.as_slug ]  # NOTE strings important
          if alias_a
            w = ( @alias_a.length - @all_alias_a.length + 1 )
            if w.nonzero?
              @all_alias_a.concat(
                @alias_a[ @all_alias_a.length - 1 .. -1 ].map(& :to_s ) )
            end
          end
          @aliases_are_puffed = true
        end
        @all_alias_a
      end
    end

    attr_reader :aliases_are_puffed ; private :aliases_are_puffed
    attr_reader :alias_a ; private :alias_a

  private

    def absorb_xtra_aliases x
      @aliases_are_puffed = nil
      ( @alias_a ||= [ ] ).concat x
      nil
    end
  end

  # ~ 5.3 - invocation function ~

  class Command  # #re-open for 5.3
    def invocation_function  # #called-by-main-invocation-loop
      @sheet.invocation_function
    end
  end

  class Cmd_Sheet_  # #re-open for 5.3
    attr_accessor :invocation_function
  end

  # ~ 5.4 - version officious facet ~

  class CLI
    def self.version *a, &b
      CLI::Version[ self, a, b ]
    end
  end

  # ~ 5.5 - actual namespacing ~

  class Namespace  # #re-open for facet 5.5
    extend MetaHell::MAARS
  end

  Magic_Touch_.enhance -> { Namespace::Facet.touch },
    [ Namespace, :singleton, :private, :namespace ]

  # ~ 5.6 - metastories [#fa-035] ~

  Magic_Touch_.enhance -> { CLI::Metastory.touch },
    [ Command, :singleton, :public, :metastory ],
    [ Namespace, :singleton, :public, :metastory ]

  # ~ 5.7 - adapters for when loading namespaces as a "strange module" ~

  class CLI
    module Adapter  # (this is actually a bit like "magic touch" pattern..)
      extend MAARS
    end
  end
  class Namespace
    module Adapter  # intermediate n.s's use a different adapter
      extend MAARS  # than level-1 clients
    end
  end

  # ~ 5.8 - "puffer" API for populating namespaces lazily [#038] ~

  class Command  # #re-open for facet 5.8

    def is_not_puffed!
      @is_puffed = false ; nil
    end

    def is_puffed!
      @is_puffed = true ; nil
    end

    attr_reader :is_puffed ; private :is_puffed  # #annoy

    def when_puffed
      false == is_puffed and puff  # this is just a hook. you must implement.
      yield
    end
  end

  # ~ 5.9 - API integration (*non*-revelation style)

  Magic_Touch_.enhance -> { CLI::API_Integration.touch },
    [ NS_Mechanics_, :public, :api, :call_api, :api_services ]
      # may be #called-by surface

  # ~ facet 6 - housekeeping and file finalizing (and consequently DSL mgmt). ~

  class CLI
    @do_track_method_added = false  # location 2 of 3 -
    # this is explained in depth in its third and final location below.
  end

  class Namespace

    @do_track_method_added = false  # location 3 of 3 - this is where it
    # happens for the `Namespace` class itself, which does *not* have its own
    # story (because stories are for holding "businessland" data, and the
    # Namespace class itself has no such data of its own to hold as explained
    # above.) however, because we define `method_added` in this file for this
    # class, when we add any methods subsequently to the class (like in
    # facets), we probably do not want the `method_added` mechanism to be
    # engaged at all, hence we define one such ivar for the class itself, and
    # subsequently use this ivar as a flag to indicate whether or not we want
    # to react when methods are added. (in the past this same ends was
    # achieved more opaquely with hacks like defining `method_added`
    # dynamically on the businessland subclass; but this alternate solution
    # here is seen as more transparent and less invasive.)

    class << self
    private

      def method_added m  # NOTE keep this at the end of the i.m's of the class
        if @do_track_method_added  # this prevents it from triggering on the
          @story.method_was_added m  # `CLI` class itself which has no story
        end  # as explained immediately above in painful but illuminating
        nil  # detail.
      end

    # `self.with_dsl_off` - in cases where you want to create (or re-define
    # existing) public methods on your client class that no *not* isomorph into
    # commands, define them inside such a block. see spec `dsl-off_spec.rb`.
    # use of this facility is considered a #smell, and as such the only
    # reasonable use for this is for something like overriding and extending
    # the one existing necessarily public method - `invoke`; something done
    # to wrap the invocation in extra UI, e.g. displaying an invitation to
    # more help when there is a soft failure.

      def with_dsl_off &blk  # #see
        if instance_variable_defined? :@story  # this will have to do for now
          @story._scooper.while_dsl_off blk
        else
          p = @do_track_method_added ; @do_track_method_added = false
          r = yield ; @do_track_method_added = p ; r
        end
      end

    # `self.dsl_off` - sadly this does not do exactly the same as above -
    # we use this alongside the canonical one location of the call to `private`
    # in a class so that we don't gather any extraneous data about (private)
    # methods added. in theory it has no functional effect, it is just to make
    # debugging easier by gathering less data (and is a micronic optimisation.)

      def dsl_off  # #see
        @story._scooper.dsl_off  # we do it a greasier way than we need to.
      end
    end
  end

  class Scooper_  # [#bm-001] - this one for sure!!

    # Scooper_ encapsulates *all* of the low-level `method_added` hacking
    # we do for `isomorphic command composition` [#041]. because there is
    # exactly one scooper per n-amespace class, it does not really need to
    # scale out much; hence we write it in the below style for fun and as
    # an experiment.

    def initialize scoop
      do_track_method_added = true
      do_scoop_next_method = false
      order_a = [] ; prev_a = [] ; black_a = []
      method_added = -> m do
        if do_track_method_added
          order_a << m
          if do_scoop_next_method
            scoop[ m ]
            do_scoop_next_method = false
          end
        end ; nil
      end
      method_added_when_dsl_off = -> m do
        black_a << m ; nil
      end
      my_gma = -> m do
        method_added[ m ]
      end
      define_singleton_method :get_method_added do
        r = my_gma ; my_gma = nil ; r
      end
      define_singleton_method :do_scoop_next_method! do
        do_scoop_next_method ||= true  # re-stating true is fine.
      end
      define_singleton_method :dsl_off do
        do_track_method_added = false
      end
      define_singleton_method :while_dsl_off do |blk|
        prev_a << method_added
        method_added = method_added_when_dsl_off
        r = blk.call
        method_added = prev_a.pop
        r
      end
      define_singleton_method :get_black_a_and_white_h do
        [ black_a, ::Hash[ order_a.each_with_index.to_a ] ]
      end
      define_singleton_method :add_name_at_this_point do |x|
        order_a << x ; nil
      end
    end
  end

  FUN = FUN_.to_struct

end
