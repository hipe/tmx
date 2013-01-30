module Skylab::Treemap
  class CLI::Action

    extend Headless::CLI::Action::ModuleMethods # let legacy trump frontier..

    MODALITIES_ANCHOR_MODULE = Treemap

    ACTIONS_ANCHOR_MODULE = -> { Treemap::CLI::Actions }

    include Headless::CLI::Action::InstanceMethods

    extend Bleeding::Action       # legacy

    include Treemap::Core::Action::InstanceMethods # might override some legacy

    def options                   # used by stylus ick to impl. `param`
      option_syntax.options
    end

    def option_syntax             # used all over the place by documentors
      @option_syntax ||= build_option_syntax
    end

    # --*--

    def adapters= box  # hacked for now..
      @adapters = box
    end

    attr_accessor :catalyzer

  protected

    def initialize rc=nil         # porcelain gives you nothing, but adapters
      @parent = nil               # in Action_Flyweight_ we make emissaries
      super( rc )                 # sets @parent via request_client=
    end

    def api_action                # experimentally the cli action builds the
      @api_action ||= begin       # api action, the tree grows downward
        kls = self.class.modalities_anchor_module::API::Actions.const_fetch(
          normalized_action_name ) # (was [#034])
        action = kls.new self
        wire_api_action action
        action
      end
    end

    def error msg                 # [#044] - - s.c#error ?
      emit :error, msg
      false
    end

    def request_client            # away at [#012]
      @parent
    end

    def request_client= x         # away at [#012]
      @parent and fail "sanity"
      @parent = x
    end

    def wire_api_action api_action
      request_client.send :wire_api_action, api_action
      stylus = request_client.send :stylus     # [#011] unacceptable
      api_action.stylus = stylus
      stylus.set_last_actions api_action, self # **TOTALLY** unacceptable
      nil
    end
  end

  module CLI::Action::InstanceMethods  # might be borrowd by motes, cards, flies


    def summary_lines  # public for legacy
      y = [ ]
      _summary_lines y
      if @adapters
        summary_lines_for_adapters y
      end
      y
    end

  protected

    def summary_lines_for_adapters y
      a = @adapters.reduce [] do |yy, adapter|
        yy << adapter.name.to_slug
      end
      x = and_ a.map(& method(:val))
      if @is_native
        y << "(can utilize plugin#{ s a } #{ x })"
      else
        y << "#{ val name.to_slug } for the #{ x } plugin#{ s a }"
      end
      y
    end
  end
end
