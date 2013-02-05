module Skylab::Headless
  module CLI::Box::DSL

    #                         ~ never say never ~                          #

    def self.extended mod # [#sl-111]
      mod.extend CLI::Box::DSL::ModuleMethods
      mod.send :include, CLI::Box::DSL::InstanceMethods
      nil
    end
  end

  module CLI::Box::DSL::ModuleMethods
    include MetaHell::Autoloader::Autovivifying::Recursive::ModuleMethods
    #
    # this deserves some explanation: we use Boxxy on our action box module
    # because that was exactly what it was designed for: to be an unobtrusive
    # hack for painless retrieval and collection management for constituent
    # module. now the point of this whole nerk here is to create such a
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
        box_mod.module_eval do
          extend MetaHell::Boxxy::ModuleMethods
          include CLI::Box::InstanceMethods

          if box.dir_path  # this noise is what the extnesive note above is abt.
            self.dir_path = box.dir_pathname.join 'actions'  # eew sorry
          else
            self.dir_path = false  # tell a.l do not try to induce our path
          end
          _boxxy_init nil  # (but no matter what, don't leave dir path nil
                           # when you send no caller_str up this chain.)
          self
        end
        box_mod
      end
    end

    attr_reader :action_class_in_progress

    def action_class_in_progress!
      @action_class_in_progress ||= begin
        box = self
        ::Class.new( cli_box_dsl_leaf_action_superclass ).class_exec do
          extend CLI::Box::DSL::Leaf_ModuleMethods
          const_set :ACTIONS_ANCHOR_MODULE, box.action_box_module
          include CLI::Box::DSL::Leaf_InstanceMethods
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
      action_class_in_progress!.build_option_parser(& block)
      nil
    end

    alias_method :box_desc, :desc  # when you want to describe the box..

    def desc first, *rest         # [#hl-033]
      action_class_in_progress!.desc first, *rest
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

    attr_accessor :last_caller

    cli_box_dsl_leaf_action_superclass = ::Object

    define_method :cli_box_dsl_leaf_action_superclass do # special needs
      cli_box_dsl_leaf_action_superclass
    end

    def method_added meth         # #doc-point [#hl-040]
      if ! dsl_is_disabled
        klass = action_class_in_progress!
        const = Autoloader::Inflection::FUN.constantize[ meth ]
        action_box_module.const_set const, @action_class_in_progress
        @action_class_in_progress = nil
      end
    end

    def option_parser &block      # (This is the DSL block appender.)
      action_class_in_progress!.option_parser(& block)
      nil
    end
  end

  module CLI::Box::DSL::InstanceMethods
    include CLI::Box::InstanceMethods

  protected

    def initialize request_client
      super request_client
      @queue = [ ]                # usu. lazy vivified in `invoke`, not so here
    end

    def argument_syntax           # "hybridization"
      if is_collapsed
        argument_syntax_for_method @box_dsl_collapsed_to
      else
        argument_syntax_for_method :dispatch
      end
    end

    attr_reader :box_dsl_collapsed_to

    alias_method :is_collapsed, :box_dsl_collapsed_to # it *is* is_collapsed IFF..

    def build_option_parser       # popular default, [#hl-037]
      o = create_box_option_parser
      o.on '-h', '--help [<sub-action>]',
        'this screen [or sub-action help]' do |v|
        box_enqueue_help v
        true
      end
      option_is_visible_in_syntax_string[ o.top.list.last.object_id ] = false
      o
    end

    def create_option_parser
      Headless::Services::OptionParser.new
    end

    # these two are "hard aliases" and not "soft" ones so if you need to
    # customize how the o.p is created you have to override them individually.

    alias_method :create_box_option_parser, :create_option_parser

    alias_method :create_leaf_option_parser, :create_option_parser

    # this is the core of this whole dsl hack.

    frame_struct = ::Struct.new :is_leaf, :option_parser

    define_method :collapse! do |action_ref|
      res = nil
      begin
        klass = if ::Class === action_ref then action_ref else
          fetch action_ref
        end
        klass or break( res = klass )
        o = klass.new self
        @box_dsl_collapsed_to = o.normalized_local_action_name
        x = ( @prev_frame ||= frame_struct.new ) # really ask for it
        x.is_leaf = true ; @is_leaf = o.is_leaf
        x.option_parser = option_parser_ivar ; @option_parser = o.option_parser
        fail 'sanity' if :dispatch != @queue.first
        @queue[0] = o.leaf_method_name
                                  # put the method name of the particular
                                  # action on the queue -- its placement is
                                  # sketchy
        res = true
      end while nil
      res
    end

    def uncollapse! normalized_leaf_name
      fail 'sanity' if @box_dsl_collapsed_to != normalized_leaf_name
      o = @prev_frame
      @is_leaf = o.is_leaf ; o.is_leaf = nil
      @option_parser = o.option_parser ; o.option_parser = nil
      @box_dsl_collapsed_to = nil
      nil
    end

    def default_action
      @default_action ||= :dispatch            # compare to box above
    end

    alias_method :cli_box_dsl_original_dispatch, :dispatch

                                  # because we are DSL we override Box's
                                  # straightforward implementation with these
                                  # shenanigans (compare!)
                                  # this method is the entrypoint for the
                                  # collection of methods in this file that
                                  # rewrite box i.m's
                                  # `action` and `args` (the names)
    def dispatch action=nil, *args # <-- are cosmetic here, careful
      if action
        res = collapse! action
        res &&= invoke args
      else
        res = cli_box_dsl_original_dispatch
      end
      res
    end

    def enqueue_help              # fragile and tricky: you are e.g. the root
                                  # modality client.  you received an
                                  # invoke ['foo', '-h'] which then called
                                  # dipatch, who then enqueued the method
                                  # name :foo.  Since we don't actually use
                                  # the method to process help (for that is
                                  # what we are now doing, we 1) remove that
                                  # method from the queue and then 2) add our
                                  # block to the queue that processes the help.
      @queue.first == @box_dsl_collapsed_to or fail( 'sanity' )
      @queue.shift                 # (done processing the name, shift it off.)
      box_enqueue_help @box_dsl_collapsed_to
      @box_dsl_collapsed_to = nil
      nil
    end

    def invite_line z=nil         # hybridization hack
      if is_collapsed
        render_invite_line "#{ normalized_invocation_string false } -h #{
          }#{ @box_dsl_collapsed_to }", z
      else
        super
      end
    end
                                  # please watch carefully: we 1) out of the box
                                  # identify as being a branch and 2) make this
                                  # hackishly mutable despite the fact that we
                                  # don't ever as a module have a clean way to
                                  # initialize ivars what with our being a
                                  # module by exploiting 2 ruby-ish things..
    attr_reader :is_leaf          # (out of box is nil and we are branch)
                                  # This is intimately depenedant on impl's
                                  # above it in the chain. (ok the 2 things
                                  # are: 1. attr_reader creates a reader
                                  # that does not emit warnings on uninitted
                                  # vars and 2. an unitted var is nil is
                                  # false-ish.)

                                  # our invocation string is dynamic based
                                  # on whether we have yet mutated or not!
                                  # (and/or rolled back some of
    def normalized_invocation_string as_collapsed=true
      a = [ super(  ) ]  # the mutation)
      if is_collapsed && as_collapsed
        a << @box_dsl_collapsed_to
      end
      a.join ' '
    end

    attr_reader :prev_frame
  end

  module CLI::Box::DSL::Leaf_ModuleMethods
    include CLI::Action::ModuleMethods         # #reach-up!

    def build_option_parser &block # (This is the DSL block writer.)
      raise ::ArgumentError.new( 'block required.' ) unless block
      raise ::ArgumentError.new( 'bop must come before op' ) if
        option_parser_blocks
      self.build_option_parser_ivar = block
      nil
    end

    attr_accessor :build_option_parser_ivar
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
            uncollapse! leaf_name
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
      # for custom overriding to e.g. use a custom class. it is so-named
      # to make the code more traceable, because it is differently used
      # than the other similarly-named method.  also we don't yet know
      # if we will ever need both! (leaf/branch hybrid)
    end

    def leaf_method_name
      name.normalized_local_name
    end
  end
end
