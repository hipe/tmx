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

    pen = -> do
      o = Headless::CLI::Pen::Minimal.new

      fun = Headless::CLI::PathTools::FUN

      o.define_singleton_method :escape_path do |str|
        fun.clear                 # always clear the `pwd` regexen .. it is hell
        fun.pretty_path[ str ]    # to debug if you don't.  The only reason
      end                         # not to is on a large number of files

      def o.ick x                 # render an invalid value.  compare to
        "\"#{ x }\""              # `val`, we actually want quotes here to make
      end                         # it look clinical, and like we are referring
                                  # to some foreign other object

      def o.lbl str               # render a business parameter name
        kbd str
      end

      def o.par sym               # [#sl-036] will be gathered up in the future
        kbd "--#{ sym.to_s.gsub('_', '-') }" # super hacked for
      end

      def o.val x                 # render a business value
        x                         # (for cli we render as-is.  looks good
      end                         # next to the stylized `lbl` labels. looks
                                  # cluttered to do more.
      o
    end.call


    define_method :initialize do |sin=$stdin, sout=$stdout, serr=$stderr|
      _tan_man_sub_client_init nil  # get it? # [#sl-114] above

      # self.io_adapter = build_io_adapter sin, sout, serr, pen # after [#018]
      self.io_adapter = Headless::CLI::IO_Adapter::Minimal.new(
        sin, sout, serr, pen )

      on_all { |e| io_adapter.emit e.stream_name, e.message }
        # saying e.to_s is probably not what you want -- you will get a hash
        # if the message has been changed via message=
    end

    def action_anchor_module      # gone at [#022] maybe..
      CLI::Actions
    end

    attr_accessor :io_adapter # away at [#022]

    def infostream                # it is reasonable for some actions to
      io_adapter.errstream        # want to write certain kind of messages
    end                           # to this directly, at the byte-level
                                  # and note the intentional name-change
    def normalized_invocation_string # #compat-headless
      program_name
    end

    def paystream
      io_adapter.outstream        # note the intentional name-change
    end
  end
end
