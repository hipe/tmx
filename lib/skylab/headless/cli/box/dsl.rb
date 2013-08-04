module Skylab::Headless

  module CLI::Box::DSL

    #                         ~ never say never ~                          #

    def self.extended mod # [#sl-111]
      mod.module_exec do
        include CLI::Box::DSL::InstanceMethods
        @tug_class = MAARS::Tug
        extend CLI::Box::DSL::ModuleMethods  # `method_added` - avoid troubl
        _headless_init_add :_headless_cli_box_dsl_init
        init_autoloader caller_locations( 3, 1 )[ 0 ]
      end
      nil
    end
  end

  module CLI::Box::DSL::ModuleMethods

    include Autoloader::Methods

    #
    # this deserves some explanation: we use Boxxy on our action box module
    # because that was exactly what it was designed for: to be an unobtrusive
    # hack for painless retrieval and collection management for constituent
    # modules. now the point of this whole nerk here is to _create_ such a
    # box module and, *as the file is being loaded*, blit it with classes
    # that are generated dynamically to model all of your actions from
    # methods as they are defined. that's the essence of why we are here.
    # While some actions (e.g. clients) may not need an autoloader, if
    # there's any chance they do it must be wired properly, and that is
    # convenient do below when the modules are created rather than at some
    # later point (e.g after the file is done loading, as recursive a.l does)
    #
    # BUT it is also nice to be able to extend a *base (action) class* with
    # this DSL extension and have it work in *child* classes. While we could
    # do some awful hacking to make the autoload hack work for subclasses
    # as they appear in other files .. just no.
    #
    # All of this is to say: 1) that is why we include a.l above, and
    # 2) this is why we have some conditional nerking around below, to charge
    # the module graph with autoloading only if it has signed on for it.
    #
    # (btw you would do that via either extending a.l explicitly on your class
    # *before* you extend this .. *and* i think the client DSL will do it
    # for you too if that fits your app.)
    #

    include CLI::Action::ModuleMethods         # #reach-up!

    def action_box_module
      if const_defined? :Actions, false
        const_get :Actions, false
      else
        box = self
        box_mod = const_set :Actions, ::Module.new
        box_mod.module_exec do
          include CLI::Box::InstanceMethods
          @tug_class = MAARS::Tug
          if box.dir_pathname  # see extensive note above about all this noise
            @dir_pathname = box.dir_pathname.join 'actions'  # eew sorry
          else
            @dir_pathname = false  # tells a.l not to try to induce our path
            box.add_dir_pathname_listener :Actions, self
          end
          MetaHell::Boxxy[ self ]
          self
        end
        box_mod
      end
    end

    attr_reader :action_class_in_progress

    def action_class_in_progress!
      @action_class_in_progress ||= begin
        box = self
        ::Class.new( _cli_box_dsl_leaf_action_superclass ).class_exec do
          extend CLI::Box::DSL::Leaf_ModuleMethods
          const_set :ACTIONS_ANCHOR_MODULE, box.action_box_module
          include CLI::Box::DSL::Leaf_InstanceMethods
          @tug_class = MAARS::Tug
          define_method :argument_syntax do
            Headless::CLI::Argument::Syntax::Inferred.new(
              box.instance_method( leaf_method_name ).parameters, nil )
          end
                                  # this is some gymnastics: the implementation
                                  # method is not defined in the action class
                                  # but in the semantic container class
          undef_method :invoke
          self
        end
      end
    end

    def box                       # #experimental un-dsl ..
      @box_proxy ||= CLI::Box::Proxy.new( desc: ->( *a ) { box_desc( *a ) } )
    end

    def build_option_parser &block # (This is the DSL block writer.)
      action_class_in_progress!.build_option_parser(& block )
      nil
    end

    def append_syntax str
      action_class_in_progress!.append_syntax str
      nil
    end

    alias_method :box_desc, :desc  # when you want to describe the box..

    def desc *a, &b                # [#hl-033] (general tracking of `desc`)
      if ! b || a.length.nonzero?
        # for anything other than the block form, simply propagate.
        # (it would typically be one descrption string as the lone item in `a`)
        action_class_in_progress!.desc( *a, &b )
      else
        # the block form is more complicated - evaluate the desc in the context
        # of the parent object, b.c that is where you would have defiend helpers
        # (Also, it won't do it now, it will do it later, which is good because
        # the block might access helpers that need metadata about the action,
        # which isn't complete yet! hence the 'current action' stuff..)
        #
        action_class_in_progress!.desc do |y|
          me = self  # at this spot now we are being lazy-evaluated (late)
          @request_client.instance_exec do  # spot [#064]
            if @downstream_action != me
              if @downstream_action # [#064]
                change_to me
              else
                collapse_to me
              end
            end
            instance_exec y, &b
          end
          nil
        end
      end
      nil
    end

    attr_reader :dsl_is_disabled # yeah .. ugly way to counteract [#040]

    def dsl_off
      @dsl_is_disabled = true
      nil
    end

    def dsl_on
      @dsl_is_disabled = false
      nil
    end

    cli_box_dsl_leaf_action_superclass = ::Object

    define_method :_cli_box_dsl_leaf_action_superclass do # special needs
      cli_box_dsl_leaf_action_superclass
    end

    def cli_box_dsl_leaf_action_superclass klass
      define_singleton_method :_cli_box_dsl_leaf_action_superclass do
        klass
      end
    end

    def method_added meth         # #doc-point [#hl-040]
      if ! dsl_is_disabled
        action_class_in_progress!
        const = Autoloader::FUN.constantize[ meth ]
        action_box_module.const_set const, @action_class_in_progress
        @action_class_in_progress = nil
      end
    end

    def option_parser &block      # (This is the DSL block appender.)
      action_class_in_progress!.option_parser(& block)
      nil
    end

    def option_parser_class x
      action_class_in_progress!.option_parser_class x
      nil
    end
  end

  module CLI::Box::DSL::InstanceMethods

    include CLI::Box::InstanceMethods

    def initialize request_client  # #!
      super request_client
      _headless_cli_box_dsl_init
    end

    alias_method :init_headless_cli_box_dsl, :initialize

  private

    define_singleton_method :private_attr_reader, & Private_attr_reader_

    def _headless_cli_box_dsl_init  # revealed for hybrids w/ client
      @downstream_action ||= nil
      @queue ||= [ ]              # usu. lazy vivified in `invoke`, not so here
      nil
    end

    #         ~ dispatch and friends (pre-order-ish) ~

    # this is the core of this whole dsl hack. because we are DSL we override
    # Box's straightforward implementation with these shenanigans (compare!)
    # this method is the entrypoint for the collection of methods in this
    # file that rewrite box i.m's `action` and `args` (the names)

    alias_method :cli_box_dsl_original_dispatch, :dispatch

    def dispatch action=nil, *args  # **NOTE** params cosmetic!
      action_ref = action  # clean that name up right away
      if ! action_ref then cli_box_dsl_original_dispatch else
        klass = if ::Class === action_ref
          fail "where?"  # #todo
        else
          fetch action_ref
        end
        if ! klass then klass else
          live_action = klass.new self
          if live_action.is_branch  # why deny the child its own autonomy
            live_action.invoke args
          else
            collapse_to live_action
            invoke args
          end
        end
      end
    end

    Frame_ = ::Struct.new :is_leaf, :option_parser

    def collapse_to live_action
      if @queue.length.nonzero?
        fail 'sanity' if :dispatch != @queue[0]
      end
      @prev_frame ||= Frame_.new  # really asking for it
      @prev_frame.is_leaf = false
      @prev_frame.option_parser = option_parser_ivar
      change_to live_action
      nil
    end

    def change_to live_action     # we hate this
      @downstream_action = live_action
      @is_leaf = live_action.is_leaf
      @option_parser = live_action.option_parser
      @queue[0] = live_action.leaf_method_name
                                  # put the method name of the particular
                                  # action on the queue -- its placement is
                                  # sketchy

      nil
    end
                                  # undoes the collapsing k.i.w.f oh lord
                                  # called from children corroborating
    def uncollapse_from normalized_leaf_name
      if @downstream_action.normalized_local_action_name !=
          normalized_leaf_name then
        fail 'sanity'
      end
      @is_leaf = @prev_frame.is_leaf
      @prev_frame.is_leaf = nil
      @option_parser = @prev_frame.option_parser
      @prev_frame.option_parser = nil
      @downstream_action = nil
      nil
    end
                                  # please watch carefully: we 1) out of the box
                                  # identify as being a branch and 2) make this
                                  # hackishly mutable despite the fact that we
                                  # don't ever as a module have a clean way to
                                  # initialize ivars what with our being a
                                  # module by exploiting 2 ruby-ish things..
    private_attr_reader :is_leaf  # (out of box is nil and we are branch)
                                  # This is intimately depenedant on impl's
                                  # above it in the chain. (ok the 2 things
                                  # are: 1. attr_reader creates a reader
                                  # that does not emit warnings on uninitted
                                  # vars and 2. an unitted var is nil is
                                  # false-ish.)


    def default_action                         # (called by `invoke`)
      @default_action ||= :dispatch            # compare to box above
    end

    #         ~  hacks to the components (in display- then pre-order) ~

                                  # our invocation string is dynamic based
                                  # on whether we have yet mutated or not!

    def normalized_invocation_string as_collapsed=true  # hybridized
      a = [ super(  ) ]
      if is_collapsed && as_collapsed
        a << @downstream_action.name.as_slug
      end
      a.join ' '
    end

    def is_collapsed
      @downstream_action
    end

    def build_option_parser       # popular default, [#hl-037]
      o = create_box_option_parser
      sw = o.define '-h', '--help [<sub-action>]',
        'this screen [or sub-action help]' do |v|
        box_enqueue_help v
        true
      end
      option_is_visible_in_syntax_string[ sw.object_id ] = false
      o
    end

    def create_option_parser
      op = Headless::Services::OptionParser.new
      op.base.long.clear  # never use builtin 'officious' -v, -h  # [#059]
      op
    end

    # these two are "hard aliases" and not "soft" ones so if you need to
    # customize how the o.p is created you have to override them individually.

    alias_method :create_box_option_parser, :create_option_parser

    alias_method :create_leaf_option_parser, :create_option_parser
      # this is for a box creating its child leaf o.p


    def argument_syntax           # [#063] hybridized
      if is_collapsed
        argument_syntax_for_method(
          @downstream_action.normalized_local_action_name )
      else
        argument_syntax_for_method :dispatch
      end
    end

    def render_argument_syntax syn, em_range=nil  # [#063] hybridized
      if @downstream_action && @downstream_action.class.append_syntax_a
        "#{ super } #{ @downstream_action.class.append_syntax_a * ' ' }"
      else
        super
      end
    end

    def invite_line z=nil         # [#063] hybridized
      if is_collapsed
        render_invite_line "#{ normalized_invocation_string false } -h #{
          }#{ @downstream_action.name.as_slug }", z
      else
        super
      end
    end

    def build_desc_lines          # [#063] hybridized, spot [#064]
      # check this awfulness out: when we build our desc lines we call for
      # the `summary_line` of each (visible) child. the summary line of each
      # child, in turn, may call *its* `desc_lines` which in turn calls
      # *its* version of this method, which in turns causes this object
      # to "collapse" around the child.. When all this whootenany is done,
      # we have to make sure to uncollapse so that we don't report child
      # parts as our own!
      x = super
      if is_collapsed
        uncollapse_from @downstream_action.normalized_local_action_name
      end
      x
    end

    # --*--

    def enqueue_help              # fragile and tricky: you are e.g. the root
                                  # modality client. you received an
                                  # invoke ['foo', '-h'] which then called
                                  # dipatch, who then enqueued the method
                                  # name :foo.  Since we don't actually use
                                  # the method to process help (for that is
                                  # what we are now doing, we 1) remove that
                                  # method from the queue and then 2) add our
                                  # block to the queue that processes the help.
      norm_name = @downstream_action.normalized_local_action_name
      @queue.first == norm_name or fail 'sanity'
      @queue.shift                 # (done processing the name, shift it off.)
      box_enqueue_help norm_name
      @downstream_action = nil
      nil
    end

    private_attr_reader :prev_frame
  end

  module CLI::Box::DSL::Leaf_ModuleMethods

    include CLI::Action::ModuleMethods         # #reach-up!

    def build_option_parser &block # (This is the DSL block writer.)
      raise ::ArgumentError, 'block required.' if ! block
      raise ::ArgumentError, 'bop must come before op' if option_parser_blocks
      self.build_option_parser_ivar = block
      nil
    end

    attr_accessor :build_option_parser_ivar

    def option_parser_class x
      if build_option_parser_ivar
        raise ::ArgumentError, "`b.o.p` and `o.p class` are mutex"
      else
        define_method :option_parser_class do x end
      end
    end
  end

  module CLI::Box::DSL::Leaf_InstanceMethods

    include CLI::Action::InstanceMethods # *not* box! this is crazier than we
                                  # want to be just yet. (leaf not branch here.)

    # This is the DSL so we've gotta provide a `bop` implementation --
    # there is a delicate, fragile dance that happens below because
    # we want to be able to leverage instance methods defined in the parent
    # and have this work both as a documentng and parsing pass.
    def build_option_parser
      leaf = self
      build_option_parser = leaf.class.build_option_parser_ivar
      build_option_parser ||= -> do
        o = leaf.leaf_create_option_parser || create_leaf_option_parser
        if leaf.class.option_parser_blocks
          leaf.class.option_parser_blocks.each do |block|
            instance_exec o, &block
          end
        end
        o.on '-h', '--help', 'this screen' do
          leaf_name = leaf.normalized_local_action_name
          if prev_frame
            uncollapse_from leaf_name
          end # else hackery
          if @queue.length.nonzero?
            leaf_name == @queue.first or fail "sanity - #{ @queue.first }"
            @queue.shift
          end
          enqueue [ :help, -> { leaf } ] # compare `box_enqueue_help`
          nil  # o.p ignores it newayz
        end
        o
      end
      request_client.instance_exec(& build_option_parser)
    end

    def leaf_create_option_parser
      if option_parser_class
        ref = option_parser_class
        ref = ref.call if ref.respond_to? :call
        ref.new
      end
    end

    def option_parser_class
      # hook for custom o.p class
    end

    def leaf_method_name
      name.local_normal
    end
  end
end
