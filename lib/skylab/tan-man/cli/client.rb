module Skylab::TanMan

  class CLI::Client < Bleeding::Runtime        # changes at [#018]

    extend Core::Client::ModuleMethods         # per the pattern

    include Core::Client::InstanceMethods      # per the pattern


    emits Porcelain::Bleeding::EVENT_GRAPH     # b/c granulated UI events
                                               # note this gets merged with
                                               # 'parent' event graph above



    # This is the reasonable place to put the idea that for cli actions,
    # when an action's invoke() method results in false, we typically
    # want to display an invite for more help.  #convention [#hl-019]
    #
    # Since (at least for this client in this subproduct) we expect this
    # behavior to be the rule rather than the exception, child
    # actions who don't want this must result in other than false to us.
    #
    # (To try to push this behavior down to the cli action class (parent
    # or child class) creates ugliness because all of our `def invoke`
    # calls would have to dance around this, it's a wrappping problem -
    # for the time being we think things like 'outer_invoke' is ugly,
    # and we've got our naming #convention down pretty well ([#hl-020])
    #
    def invoke argv
      result = super argv # watch for this to break at [#018]
      if false == result
        bound_method, = resolve argv.dup # re-resolve, ick!!!
        if bound_method
          action = bound_method.receiver
          action.help invite_only: true
        else
          result = help invite_only: true
        end
        result = nil
      end
      result
    end

  protected

    def initialize sin=$stdin, sout=$stdout, serr=$stderr, &events
                                                       # patt. [#sl-114]

      ioa = Headless::CLI::IO::Adapter::Minimal.new sin, sout, serr # pen deflt
      self.io_adapter = ioa
      if block_given?
        fail 'do we really want this?'
        # events[ self ]
      else
        on_all { |e| io_adapter.emit e.type, e.message }
        # saying e.to_s is probably not what you want -- you will get a hash
        # if the message has been changed via message=
      end
    end

    def anchor_module # gone at [#022] maybe..
      CLI::Actions
    end

    attr_accessor :io_adapter # away at [#022]

    def infostream                # it is reasonable for some actions to
      io_adapter.errstream        # want to write certain kind of messages
    end                           # to this directly, at the byte-level
                                  # and note the intentional name-change

    def paystream
      io_adapter.outstream        # note the intentional name-change
    end

    def pen # gone at [#022]
      io_adapter.pen
    end
  end
end
