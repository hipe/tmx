module Skylab::Headless
  module CLI::Client::DSL

    #                         ~ never say never ~                          #


    def self.extended mod # [#sl-111]
      mod.send :include, CLI::Client::DSL::InstanceMethods
      mod.extend CLI::Client::DSL::ModuleMethods
      mod._autoloader_init! caller[0]
      mod
    end
  end



  module CLI::Client::DSL::ModuleMethods
    include MetaHell::Autoloader::Autovivifying::Recursive::ModuleMethods

    def action_box_module
      @action_box_module ||= begin
        mod = nil
        begin
          if const_defined? :Actions, false
            mod = const_get :Actions, false
            break
          end
          mod = ::Module.new
          mod.extend MetaHell::Boxxy::ModuleMethods
          mod.dir_path = dir_pathname.join( 'actions' ).to_s # do this..
          mod._autoloader_init! nil                          # before this.
          mod.send :include, CLI::Box::InstanceMethods
          const_set :Actions, mod
        end while nil
        mod
      end
    end

    def action_class_in_progress!
      @action_class_in_progress ||= begin
        klass = ::Class.new                    # (based on frontier (my-tree))
        klass.extend CLI::Action::ModuleMethods
        klass.const_set :ANCHOR_MODULE, action_box_module
        klass.send :include, CLI::Action::InstanceMethods
        parent_module = self
        klass.send :define_method, :argument_syntax do
          unbound = parent_module.instance_method normalized_local_action_name
          as = build_argument_syntax unbound.parameters
          as
        end
        klass.send :define_method, :build_option_parser do
          self.param_h ||= { }                 # here we see a monumental hack
          request_client.param_h = param_h     # (OMG) to be able to leverage
          op = request_client.instance_exec(&  # instance methods defined on
            self.class.build_option_parser_f ) # the CLI client, and have this
          op                                   # work both in a documenting
        end                                    # and a parsing pass.
        klass
      end
    end

    def build_option_parser &blk
      klass = action_class_in_progress!
      klass.define_singleton_method( :build_option_parser_f ) { blk } # see call
      nil
    end

    def method_added meth
      if @action_class_in_progress ||= nil
        const = Autoloader::Inflection::FUN.constantize[ meth ]
        action_box_module.const_set const, @action_class_in_progress
        @action_class_in_progress = nil
      end
    end
  end



  module CLI::Client::DSL::InstanceMethods
    include CLI::Client::InstanceMethods       # not all clients are boxen
    include CLI::Box::InstanceMethods          # not all boxen are clients


  protected


    def argument_syntax           # "hybridization"
      if @normalized_local_action_name
        build_argument_syntax_for @normalized_local_action_name
      else
        super
      end
    end


    def default_action
      @default_action ||= :dispatch            # compare to box above - terrible
    end

                                  # because we are DSL we override Box's
                                  # straightforward implementation with these
                                  # shenanigans (compare!)
    def dispatch action=nil, *args # `args` (the name) is cosmetic here, careful
      res = nil
      begin
        if ! action
          break( res = super )                 # (up to ancestor (box))!
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
        @leaf = o.leaf?                                     # eek
        tail = o.normalized_local_action_name
        @normalized_local_action_name = tail                # meh
        @option_parser = o.option_parser                    # eek
        @param_h = o.param_h                                # eek
        @queue.clear.push Autoloader::Inflection::FUN.methodify[ tail ]
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
      queue.first == @normalized_local_action_name or fail( 'sanity' )
      queue.shift                 # (done processing the name, shift it off.)
      box_enqueue_help! @normalized_local_action_name
      @normalized_local_action_name = nil
      nil
    end



    def invite_line               # hybridization hack
      if @normalized_local_action_name
        "use #{ kbd "#{ cli_client_dsl_original_normalized_invocation_string }#{
          } -h #{ @normalized_local_action_name }" } for help"
      else
        cli_box_invite_line
      end
    end


    alias_method :cli_client_dsl_original_normalized_invocation_string,
      :normalized_invocation_string


    def normalized_invocation_string  # our invocation string is dynamic based
                                  # on whether we have yet mutated or not!
                                  # (and/or rolled back some of the mutation)
      a = [ super ]
      if (@normalized_local_action_name ||= nil)
        a << @normalized_local_action_name
      end
      a.join ' '
    end


    def option_parser
      @option_parser ||= build_option_parser    # pretty terrible what happens
    end
  end
end
