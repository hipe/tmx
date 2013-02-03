module Skylab::Snag
  class CLI::Action # just derping around for now, also [#sl-109]
    ACTIONS_ANCHOR_MODULE = -> { CLI::Actions }

    def self.porcelain            # compat all.rb [#sg-010]
      self
    end

    def self.summary_lines        # wicked old ways [#sg-010]
      nil
    end
  end

  module CLI::Action::InstanceMethods
    include Snag::Core::SubClient::InstanceMethods
    include Headless::CLI::Action::InstanceMethods

  protected

    def api
      @api ||= Snag::API::Client.new self
    end

    def api_build_wired_action normalized_action_name, wiring=nil
      action = api.build_action normalized_action_name
      if wiring
        wiring[ action ]
      else
        wire_action action
      end
      action
    end

    def api_invoke normalized_name, param_h=nil, wiring=nil
      res = nil
      begin
        act = api_build_wired_action normalized_name, wiring
        act or break( res = act )
        res = act.invoke param_h
      end while nil
      res
    end
  end

  class CLI::Client < Headless::DEV::Client
    # mash together something that lets us straddle two worlds

    # include CLI::Action::InstanceMethods # (used to be s.c)
    include Snag::Core::SubClient::InstanceMethods

  protected

    def initialize legacy_call_frame, pnum
      # super() don't call this - it only sets @io_adapter
      nis = legacy_call_frame.invocation
      nis_a = nis.split ' '
      @normalized_invocation_string =
        nis_a[ 0 .. (- (pnum + 1)) ].join ' '
      @hack = -> do
        cfa = [ cf = legacy_call_frame ] # KILL THIS WITH FIRE
        cfa.push( cf ) while ( cf = cf.below )
        cli = cfa[ -2 ].client_instance
        cli
      end
      @io_adapter = CLI::Client::IO_Adapter.new
    end

    def create_leaf_option_parser
      Snag::Services::OptionParser.new
    end

    def emit name, pay
      legacy_client.send :emit, name, pay
    end

    def invite x
      legacy_client.send :invite, x
    end

    def legacy_client
      @legacy_client ||= begin
        lc = @hack.call
        @hack = nil
        lc
      end
    end

    attr_reader :normalized_invocation_string

    def request_client
      legacy_client # not memoizing it just for more attractive dumps!
    end

    def wire_action action
      legacy_client.send :wire_action, action
    end
  end

  class CLI::Client::IO_Adapter

    attr_reader :pen

  protected

    def initialize
      @pen = Headless::CLI::Pen::MINIMAL
    end
  end

  class CLI::Action
    extend MetaHell::Autoloader::Autovivifying::Recursive
    extend Headless::CLI::Action::ModuleMethods

    include CLI::Action::InstanceMethods

                                  # (necessarily re-opened below)

    def self.action_name          # compat to all.rb
      normalized_action_name.last
    end

    def self.aliases              # compat to all.rb
    end

    def self.collapse_action legacy_client
      new legacy_client.actions_provider
    end

    # --*--

    def parse argv                # compat all.rb [#sg-010]
      [ self, :invoke, [ argv ] ] # [ client, action_ref, args ]
    end

  protected

    def initialize request_client
      super
      @param_h = { }
    end

    # --*--

    def dry_run_option o
      o.on '-n', '--dry-run', 'dry run.' do param_h[:dry_run] = true end
    end

    def verbose_option o
      o.on '-v', '--verbose', 'verbose output.' do param_h[:verbose] = true end
    end

    # --*--

    attr_reader :param_h
  end

  class CLI::Action::Box < CLI::Action
    include Headless::CLI::Box::InstanceMethods

    def self.action_box_module
      const_get :Actions, false
    end

    def self.actions              # temporary compat for all.rb
      @actions ||= CLI::Action::Enumerator.new self
    end                           # all of this is derp

    def self.collapse_intermediate_action legacy_client
      # when we are finding a leaf, we need a live parent
      new( CLI::Client.new legacy_client, 2 ) # TWO here
    end

                                  # #experimental #frontier #push-up candidate
                                  # all box classes will have an Actions
                                  # box module [#hl-035] that extends Boxxy so
                                  # why not automagicify it here
    def self.inherited klass
      ( klass.const_set :Actions, ::Module.new ).extend MetaHell::Boxxy
    end

    def actions
      self.class.actions
    end

  protected

    def initialize *a
      @queue = []  # for hacks below
      super
    end

    def build_option_parser       # tracked by [#hl-037]
      o = Snag::Services::OptionParser.new
      o.on '-h', '--help', 'this screen, or help for particular sub-action' do
        box_enqueue_help
      end
      o
    end

    # (we don't necessarily have to combine the dsl- and non-dsl-variant:)

    define_singleton_method :cli_box_dsl_leaf_action_superclass do
      CLI::Action::Box_DSL_Leaf
    end

    extend Headless::CLI::Box::DSL
  end

  class CLI::Action::Box_DSL_Leaf < CLI::Action
    # When we "def" a function in the dsl, what class do we use?
    # this will experimentally backpedal over some of the box logic around
    # collapsing in order to pass-off the same behavior to legacy porcelain.

    def self.collapse_action legacy_client
      # *EXPERIMENTAL*: make a dupe of box, collapse it
      box1 = legacy_client.actions_provider
      box2 = box1.class.allocate
      leaf_class = self
      box2.instance_exec do
        h = {
          :@error_count    => -> _ { @error_count = 0 },     # yes
          :@queue          => -> _ { @queue = [:dispatch] }, # hack city
          :@param_h        => -> x { @param_h = x },         # maybe
          :@request_client => -> x { @request_client = x }   # yes
        }
        box1.instance_variables.each do |ivar| # what to do with *each* one?
          h[ivar][ box1.instance_variable_get ivar ]
        end
        collapse! leaf_class
      end
      box2
    end

  protected

  end

  class CLI::Action::Enumerator < ::Enumerator # experimental derping - mind you
                                  # this *might* get flattened into a boxxy-ish
                                  # it belongs to a action box *class*

    def visible                   # compat all.rb
      self
    end

  protected

    def initialize box_class
      @box_class = box_class
      super( ) { |y| visit y }
    end

    def visit y
      abm = @box_class.action_box_module
      abm.each do |action_class|
        y << action_class
      end
      @help_emissary_fly ||= CLI::Action::Help_Emissary_Fly.new @box_class
      y << @help_emissary_fly
      nil
    end
  end

  class CLI::Action::Help_Emissary_Fly         # derping around however we need
                                               # to get help compat with all.rb
    def action_name
      :help
    end

    def aliases
    end
                                  # the caller wants a subclient to call parse
                                  # on. this way we don't have to have a "live"
                                  # object graph for every action in the box,
                                  # instead the "live" client passes itself
                                  # off only to those nerks it needs to enliven.
    def collapse_action request_client
      CLI::Action::Help_Emissary_SubClient.new request_client, @box_class
    end

  protected

    def initialize box_class
      @box_class = box_class
    end
  end

  class CLI::Action::Help_Emissary_SubClient # this is all retrofit derp
                                  # help was requested (all.rb) and to that
                                  # end we are derping by any means necessary

    define_method :parse do |argv|
      client = CLI::Client.new @request_client, 2
      box_emissary = @box_class.new client
      box_emissary.send :enqueue, :help
      box_emissary.invoke argv                 # (headless would let us
      nil                                      # continue to process queue.)
    end

  protected

    def initialize request_client, box_class
      @box_class = box_class
      @request_client = request_client
    end
  end
end
