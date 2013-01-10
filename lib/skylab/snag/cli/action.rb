module Skylab::Snag
  class CLI::Action # just derping around for now
    extend MetaHell::Autoloader::Autovivifying::Recursive
    extend Headless::CLI::Action::ModuleMethods
    include Headless::CLI::Action::InstanceMethods

    ACTIONS_ANCHOR_MODULE = CLI::Actions

    def self.action_name          # compat to all.rb
      normalized_action_name.last
    end

    def self.aliases              # compat to all.rb
    end

    o = { }

    o[:hack_me_a_modality_client] = -> legacy_client, pnum do
      hack_modality_client = Headless::DEV::Client.new
      nis = legacy_client.invocation
      nis_a = nis.split ' '
      pis = nis_a[ 0 .. (- (pnum + 1)) ].join(' ')
      hack_modality_client.define_singleton_method(
        :normalized_invocation_string ) { pis }
      hack_modality_client
    end

    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze
  end


  class CLI::Action::Box < CLI::Action
    include Headless::CLI::Box::InstanceMethods

    def self.action_box_module
      const_get :Actions, false
    end

    def self.actions              # temporary compat for all.rb
      @actions ||= CLI::Action::Enumerator.new self
    end                           # all of this is derp

    hack_me_a_modality_client = CLI::Action::FUN.hack_me_a_modality_client

    define_singleton_method :collapse_action do |legacy_client|
      new hack_me_a_modality_client[ legacy_client, 1 ]
    end

                                  # #experimental #frontier #push-up candidate
                                  # all box classes will have an Actions
                                  # box module [#hl-035] that extends Boxxy so
                                  # why not automagicify it here
    def self.inherited klass
      ( klass.const_set :Actions, ::Module.new ).extend MetaHell::Boxxy
    end

    # --*--

    def parse argv                # compat all.rb
      res = invoke argv
      res ? nil : res
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

    hack_me_a_modality_client = CLI::Action::FUN.hack_me_a_modality_client

    define_method :parse do |argv|
      hacked_modality_client = hack_me_a_modality_client[ @request_client, 2 ]
      box_emissary = @box_class.new hacked_modality_client
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
