module Skylab::TanMan

  class CLI::Client < Bleeding::Runtime        # changes at [#018]

    extend Core::Client::ModuleMethods         # per the pattern

    include Core::Client::InstanceMethods      # per the pattern


    emits Porcelain::Bleeding::EVENT_GRAPH     # b/c granulated UI events
                                               # note this gets merged with
                                               # 'parent' event graph above



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
