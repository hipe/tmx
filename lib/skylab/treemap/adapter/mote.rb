module Skylab::Treemap
  module Adapter
  end

  module Adapter::Mote
    # a "mote" is an experimental construct, something like a flyweight
    # except it has identity, and something like a "catalyzer", which is
    # also a thing. The premise here is that we can represent a large action
    # graph quickly using only the filesystem if we only lazy load things
    # like descriptions and sub-actions as we need them.

    # for better or worse, these motes also encapsulate a lot of legacy
    # wiring we would like to leave behind.

    # (Should we rename "mote" to "card"?)
  end


  class Adapter::Mote::Actions < MetaHell::Formal::Box::Open
    include Treemap::Core::SubClient::InstanceMethods
    # all motes (almost by definition now) render themselves to screen.
    # we have implemented this by making a graph of subclients because
    # this is easiest. The rootmost node in the graph (the only one the
    # rest of the app should know about) has a handle on a parent client,
    # etc.

    def each
      @hot or load
      super
    end

  protected

    def initialize mc
      super nil  # init the box, by way of h.l s.c
      Treemap::CLI === mc or fail "we need the mode client to inspect actions"
      _treemap_sub_client_init -> { mc }  # init self as a s.c
      @hot = nil
    end

    def action_const_get const
      mode_client.class::Actions.const_get const, false
    end

    def load
      mode_client.class::Actions.constants.reduce self do |memo, const|
        action = Adapter::Mote::Action.new self, const
        memo.add action.name.normalized_local_name, action
        memo
      end # Now the box has cards for all the local (non adapter) actions.
      adapters = mode_client.api_client.adapter_box.each.which(&:has_cli_actions)
      adapters.reduce( self ) do |memo, (adname, adapter)|
        adapter.cli_action_names.reduce memo do |mem, (aname, nf)|
          mem.if? aname, -> x do
            x.add_adapter adapter
          end, -> do
            action = Adapter::Mote::Action.new self, nil, nf
            action.add_adapter adapter
            mem.add aname, action
          end
          mem
        end
        memo
      end

      @hot = true
      nil
    end

    def mode_client
      @rc.call
    end

    public :action_const_get, :mode_client  # (child s.c only)
  end

  class Adapter::Mote::Action
    include Treemap::Core::SubClient::InstanceMethods
    include Treemap::CLI::Action::InstanceMethods  # for rendering summaries

    def add_adapter catalyzer
      ( @adapters ||= [ ] ) << catalyzer  # trueishness of ivar used as test
      nil
    end

    def aliases
      [ @name.as_slug ]
    end

    def build mc  # this is a legacy request for a hot action, possibly for x
      if @is_native
        build_native mc
      else
        build_strange mc
      end
    end

    attr_reader :is_visible

    attr_reader :name

  protected

    def initialize rc, const, nf=nil
      _treemap_sub_client_init( rc.respond_to?(:call) ? rc : -> { rc } )
      @adapters = nil  # will be used ase true-ish test
      @is_visible = true
      if const
        @is_native = true
        @name = Headless::Name::Function.from_const const
      else
        @is_native = false
        @name = nf
      end
    end

    def build_native *a
      kls = request_client.action_const_get @name.as_const
      action = kls.new request_client.mode_client
      action.adapters = @adapters if @adapters
      action
    end

    # (we are implementing a feature we don't need yet - that of actions
    # that plugins have that the core app doesn't have - becaues we are crazy)

    def build_strange mc
      # things are very different if we have multiple v.s 1 adapter for the
      # a given action -- we want to pass control over to the adapter action
      # asap so:
      if 1 == @adapters.length
        kls = @adapters.first.resolve_cli_action_class @name.as_slug, -> e do
          usage_and_invite e
        end
        if kls
          charged = kls.new mc # (r.c is not self, it is not parent.)
          charged.legacy_proxy
        end
      else
        ub = Adapter::Action::Unbound.new mc, @adapters, @name
        ub.legacy_proxy
      end
    end

    def _summary_lines y  # this is the lightweight version
      if @is_native
        y << "the #{ val @name.as_slug } action."
      end
      nil
    end
  end
end
