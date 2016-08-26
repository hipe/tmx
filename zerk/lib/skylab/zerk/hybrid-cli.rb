module Skylab::Zerk

  class HybridCLI < Home_::NonInteractiveCLI

    #   • see description of parent class - that holds here too.
    #
    # this client instance manages the invocation of two separate CLI
    # clients in *series*, a non-interative CLI and an interactive CLI.
    #
    #   • the initial invocation is controlled by the non-interactive CLI.
    #
    #   • *somehow* the n.i CLI "drops in" to an interactive client instance.

    # -- expression

    def handle_ACS_emission_ i_a, & ev_p
      # #cold-model (see tombstone) (hi.)
      super
    end

    # -- invocation

    def when_no_arguments_

      # (will likely become its own method..)

      ic = remove_instance_variable :@_interactive_CLI_in_progress

      _ACS = self.top_frame.ACS  # use own public API

      ic.root_ACS_by do  # #cold-model
        _ACS
      end

      ic = ic.finish

      @interactive_CLI = ic

      Common_::Bound_Call[ nil, ic, :invoke_when_zero_length_argv ]
    end

    # -- as instance (before invoke)

    def universal_CLI_resources sin, sout, serr, pn_s_a

      @_interactive_CLI_in_progress.universal_CLI_resources(
        sin, sout, serr, pn_s_a )

      super
    end

    def initialize_copy _

      # make a `dup` recurse down one level - the client may not want to
      # contaminate the prototype with configuration meant for the instance.

      _otr = @_interactive_CLI_in_progress.dup
      @_interactive_CLI_in_progress = _otr

      super
    end

    def finish
      # (hi.)
      super
    end

    def on_event_loop= p
      # only for a hack to make testing easier (inspect the event loop)
      @_interactive_CLI_in_progress.on_event_loop = p
    end

    # -- as hybrid prototype

    def init_as_prototype_
      @_interactive_CLI_in_progress = Home_::InteractiveCLI.begin
      super
    end

    def interactive_design= p
      @_interactive_CLI_in_progress.design = p
    end
  end
end
# #tombstone: was #hot-model
