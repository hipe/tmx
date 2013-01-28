module Skylab::Headless
  module CLI::Box::DSL

    #                         ~ never say never ~                          #


    def self.extended mod # [#sl-111]
      mod.extend CLI::Box::DSL::ModuleMethods
      mod.last_caller = caller[0]
      mod.send :include, CLI::Box::DSL::InstanceMethods
      mod
    end
  end

  module CLI::Box::DSL::ModuleMethods
    include CLI::Action::ModuleMethods         # #reach-up!

    def action_box_module
      if const_defined? :Actions, false
        const_get :Actions, false
      else
        mod = ::Module.new
        mod.extend MetaHell::Boxxy::ModuleMethods
        mod._boxxy_init_with_no_autoloading!
        mod.send :include, CLI::Box::InstanceMethods
        const_set :Actions, mod
      end
    end

    attr_reader :action_class_in_progress

    def action_class_in_progress!
      @action_class_in_progress ||= begin
        klass = ::Class.new cli_box_dsl_leaf_action_superclass
        klass.extend CLI::Box::DSL::Leaf_ModuleMethods
        klass.const_set :ACTIONS_ANCHOR_MODULE, action_box_module
        klass.send :include, CLI::Box::DSL::Leaf_InstanceMethods

        parent_module = self
        klass.send :define_method, :argument_syntax do
                                  # this is some gymnastics: the implementation
                                  # method is not defined in the action class
                                  # but in the semantic container class
          unbound = parent_module.instance_method leaf_method_name
          build_argument_syntax unbound.parameters
        end

        klass
      end
    end

    def build_option_parser &block # (This is the DSL block writer.)
      action_class_in_progress!.build_option_parser(& block)
      nil
    end

    alias_method :cli_box_dsl_original_desc, :desc

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

    def enable_autoloader!
      fail 'test me!'
      extend MetaHell::Autoloader::Autovivifying::Recursive::ModuleMethods
      fail 'sanity' unless @last_caller
      _autoloader_init! @last_caller
      @last_caller = nil
      # mod.dir_path = dir_pathname.join( 'actions' ).to_s # do this..
      # mod._autoloader_init! nil                          # before this.
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
      @queue = [ ]                # typically the user does this, not w/ dsl
    end

    alias_method :cli_box_dsl_original_argument_syntax, :argument_syntax

    def argument_syntax           # "hybridization"
      if collapsed
        build_argument_syntax_for @box_dsl_collapsed_to
      else
        cli_box_dsl_original_argument_syntax
      end
    end

    attr_reader :box_dsl_collapsed_to

    alias_method :collapsed, :box_dsl_collapsed_to # it *is* collapsed IFF..

    def build_option_parser       # popular default, [#hl-037]
      o = create_box_option_parser
      o.on '-h', '--help [<sub-action>]',
        'this screen [or sub-action help]' do |v|
        box_enqueue_help! v
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
        leaf_name = o.normalized_local_action_name
        @box_dsl_collapsed_to = leaf_name
        x = ( @prev_frame ||= frame_struct.new ) # really ask for it
        x.is_leaf = true ; @is_leaf = o.is_leaf
        x.option_parser = option_parser_ivar ; @option_parser = o.option_parser
        fail 'sanity' if :dispatch != queue.first
        queue[0] = o.leaf_method_name
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

    def enqueue_help!             # fragile and tricky: you are e.g. the root
                                  # modality client.  you received an
                                  # invoke ['foo', '-h'] which then called
                                  # dipatch, who then enqueued the method
                                  # name :foo.  Since we don't actually use
                                  # the method to process help (for that is
                                  # what we are now doing, we 1) remove that
                                  # method from the queue and then 2) add our
                                  # block to the queue that processes the help.
      queue.first == @box_dsl_collapsed_to or fail( 'sanity' )
      queue.shift                 # (done processing the name, shift it off.)
      box_enqueue_help! @box_dsl_collapsed_to
      @box_dsl_collapsed_to = nil
      nil
    end

    alias_method :cli_box_dsl_original_invite_line, :invite_line

    def invite_line               # hybridization hack
      if collapsed
        "use #{ kbd "#{ cli_box_dsl_original_normalized_invocation_string }#{
          } -h #{ @box_dsl_collapsed_to }" } for help"
      else
        cli_box_dsl_original_invite_line
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
                                  # vars and 2 an unitted var is nil is
                                  # false-ish.)

    alias_method :cli_box_dsl_original_normalized_invocation_string,
      :normalized_invocation_string

    def normalized_invocation_string  # our invocation string is dynamic based
                                  # on whether we have yet mutated or not!
                                  # (and/or rolled back some of the mutation)
      a = [ cli_box_dsl_original_normalized_invocation_string ]
      if collapsed
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
      leaf_name = leaf.normalized_local_action_name
      build_option_parser = leaf.class.build_option_parser_ivar
      build_option_parser ||= -> do
        o = leaf.leaf_create_option_parser || create_leaf_option_parser
        if a = leaf.class.option_parser_blocks
          a.each do |block|
            instance_exec o, &block
          end
        end
        o.on '-h', '--help', 'this screen' do
          if prev_frame
            uncollapse! leaf_name
          end # else hackery
          if queue.length.nonzero?
            fail 'sanity' if leaf_name != queue.first
            queue.shift
          end
          enqueue! -> do          # (almost same as `box_enqueue_help!`)
            leaf.help
            true                  # ask for trouble by name by parsing others
          end
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
      normalized_local_action_name_as_method_name
    end
  end
end
