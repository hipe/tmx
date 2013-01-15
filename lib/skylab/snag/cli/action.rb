module Skylab::Snag
  class CLI::Action # just derping around for now, also [#sl-109]
    def self.porcelain            # compat all.rb [#sg-010]
      :porcelain_not_used
    end
  end

  module CLI::Action::InstanceMethods
    include Snag::Core::SubClient::InstanceMethods
    include Headless::CLI::Action::InstanceMethods

  protected

    def api
      @api ||= Snag::API::Client.new self
    end

    def api_build_wired_action normalized_action_name
      action = api.build_action normalized_action_name
      wire_action action
      action
    end

    def api_invoke normalized_name, param_h=nil
      res = nil
      begin
        act = api_build_wired_action( normalized_name ) or break( res = act )
        res = act.invoke param_h
      end while nil
      res
    end
  end

  class CLI::Client < Headless::DEV::Client
    # mash together something that lets us straddle two worlds

    include Snag::Core::SubClient::InstanceMethods

  protected

    def initialize legacy_client, pnum
      super()
      nis = legacy_client.invocation
      nis_a = nis.split ' '
      @normalized_invocation_string =
        nis_a[ 0 .. (- (pnum + 1)) ].join ' '
      @hack = -> do
        cfa = [ cf = legacy_client ] # KILL THIS WITH FIRE
        cfa.push( cf ) while ( cf = cf.below )
        cli = cfa[ -2 ].client_instance
        cli
      end
    end

    def invite x
      legacy_client.send :invite, x
    end

    def legacy_client
      @hack.call
    end

    attr_reader :normalized_invocation_string

    def request_client
      legacy_client # not memoizing it just for more attractive dumps!
    end

    def wire_action action
      legacy_client.send :wire_action, action
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

    def wire_action action
      @request_client.send :wire_action, action
      nil
    end
  end


  class CLI::Action::Box < CLI::Action
    include Headless::CLI::Box::InstanceMethods

    def self.action_box_module
      const_get :Actions, false
    end

    def self.actions              # temporary compat for all.rb
      @actions ||= CLI::Action::Enumerator.new self
    end                           # all of this is derp

    define_singleton_method :collapse_action do |legacy_client|
      client = CLI::Client.new legacy_client, 1
      new client
    end

                                  # #experimental #frontier #push-up candidate
                                  # all box classes will have an Actions
                                  # box module [#hl-035] that extends Boxxy so
                                  # why not automagicify it here
    def self.inherited klass
      ( klass.const_set :Actions, ::Module.new ).extend MetaHell::Boxxy
    end

    # --*--

    define_method :parse do |argv| # compat all.rb [#sg-010]
      [ self, :invoke, [argv] ]   # [ client, action_ref, args ]
    end

  protected

    def initialize *a
      @queue = []  # for hacks below
      super
    end

    def build_option_parser       # tracked by [#hl-037]
      o = Snag::Services::OptionParser.new
      o.on '-h', '--help', 'this screen, or help for particular sub-action' do
        box_enqueue_help!
      end
      o
    end
  end

  class CLI::Action
    ACTIONS_ANCHOR_MODULE = CLI::Actions # here b.c of an otherwise circ. dep.
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
      box_emissary.send :enqueue!, :help
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
