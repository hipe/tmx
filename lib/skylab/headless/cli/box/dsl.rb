module Skylab::Headless
  module CLI::Box::DSL

    #                         ~ never say never ~                          #


    def self.extended mod # [#sl-111]
      mod.extend CLI::Box::DSL::ModuleMethods
      mod.send :include, CLI::Box::DSL::InstanceMethods
      mod._autoloader_init! caller[0]
      mod
    end
  end

  module CLI::Box::DSL::ModuleMethods
    include MetaHell::Autoloader::Autovivifying::Recursive::ModuleMethods
    include CLI::Action::ModuleMethods         # #reach-up!

    def action_box_module
      if const_defined? :Actions, false
        const_get :Actions, false
      else
        mod = ::Module.new
        mod.extend MetaHell::Boxxy::ModuleMethods
        mod.dir_path = dir_pathname.join( 'actions' ).to_s # do this..
        mod._autoloader_init! nil                          # before this.
        mod.send :include, CLI::Box::InstanceMethods
        const_set :Actions, mod
      end
    end

    def action_class_in_progress!
      @action_class_in_progress ||= begin
        klass = ::Class.new
        klass.extend CLI::Box::DSL::Leaf_ModuleMethods
        klass.const_set :ANCHOR_MODULE, action_box_module
        klass.send :include, CLI::Box::DSL::Leaf_InstanceMethods

        parent_module = self
        klass.send :define_method, :argument_syntax do
                                  # this is some gymnastics: the implementation
                                  # method is not defined in the action class
                                  # but in the semantic container class
          unbound = parent_module.instance_method normalized_local_action_name
          build_argument_syntax unbound.parameters
        end

        klass
      end
    end

    def build_option_parser &blk  # (note this is the *DSL* variant! a setter)
      kls = action_class_in_progress!
      if kls.option_parser_blocks
        raise ::ArgumentError.new "`option_parser` must occur *after* #{
        }`build_option_parser`"
      end
      kls.define_singleton_method( :build_option_parser_f ) { blk } # see call
      nil
    end

    def desc first, *rest                      # [#hl-033]
      action_class_in_progress!.desc first, *rest
      nil
    end

    def method_added meth
      if @action_class_in_progress ||= nil
        const = Autoloader::Inflection::FUN.constantize[ meth ]
        action_box_module.const_set const, @action_class_in_progress
        @action_class_in_progress = nil
      end
    end

    def option_parser &block
      action_class_in_progress!.option_parser(& block)
      nil
    end
  end

  module CLI::Box::DSL::InstanceMethods
    include CLI::Box::InstanceMethods


  protected

    alias_method :cli_box_dsl_original_argument_syntax, :argument_syntax

    def argument_syntax           # "hybridization"
      if collapsed
        build_argument_syntax_for @box_dsl_collapsed_to
      else
        cli_box_dsl_original_argument_syntax
      end
    end

    attr_reader :collapsed

    def default_action
      @default_action ||= :dispatch            # compare to box above
    end

    alias_method :cli_box_dsl_original_dispatch, :dispatch

                                  # because we are DSL we override Box's
                                  # straightforward implementation with these
                                  # shenanigans (compare!)
    def dispatch action=nil, *args # `args` (the name) is cosmetic here, careful
                                  # this method is the entrypoint for the
                                  # collection of methods in this file that
                                  # rewrite box i.m's

      res = nil
      begin
        if ! action
          break( res = cli_box_dsl_original_dispatch ) # (up to ancestor (box))!
        end
        klass = fetch action
        if ! klass
          break( res = klass )
        end
                                  # what follows is not suitable for children
                                  # or anyone: create a dummy action that we
                                  # use just for reflection but don't ever
                                  # invoke.  mutate the ever living mercy out
                                  # of *this* client, basically sacraficing it
                                  # to try to invoke the action method.
        o = klass.new self        # (let "eek" below mark places of sketchy,
        o.param_h ||= { }         # possibly irreversable mutation)
        tail = o.normalized_local_action_name
        @box_dsl_collapsed_to = tail
        @collapsed = true
        @is_leaf = o.is_leaf             # eek (futurize a bit)
        @option_parser = o.option_parser # eek
        @param_h = o.param_h             # eek (must be after o.p above)
        @queue.clear.push Autoloader::Inflection::FUN.methodize[ tail ]
                                  # put the method name of the particular
                                  # action on the queue!
        res = invoke args
      end while nil
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
  end

  module CLI::Box::DSL::Leaf_ModuleMethods
    include CLI::Action::ModuleMethods         # #reach-up!
    def build_option_parser_f # popular default, [#hl-037]
      -> do
        o = Headless::Services::OptionParser.new
        o.on '-h', '--help', 'this screen' do
          enqueue! -> { help cmd }
        end
        o
      end
    end
  end

  module CLI::Box::DSL::Leaf_InstanceMethods
    include CLI::Action::InstanceMethods # *not* box! this is crazier than we
                                  # want to be just yet. (leaf not branch here.)

                                  # here we see a monumental hack (OMG) to be
                                  # able to leverage instance methods defined
                                  # on the CLI client (or sub-client), and have
                                  # this work both in a documenting and a
                                  # parsing pass.
    def build_option_parser
      self.param_h ||= { }
      request_client.param_h = param_h
      o = request_client.instance_exec(& self.class.build_option_parser_f )
      if self.class.option_parser_blocks
        self.class.option_parser_blocks.each do |block|
          request_client.instance_exec o, &block
        end
      end
      o
    end
  end
end
