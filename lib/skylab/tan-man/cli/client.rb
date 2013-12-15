module Skylab::TanMan

  class CLI::Client < Bleeding::Runtime        # changes at [#018]

    extend Core::Client::ModuleMethods         # per the pattern

    include Core::Client::InstanceMethods      # per the pattern


    emits Bleeding::EVENT_GRAPH                # b/c granulated UI events
                                               # note this gets merged with
                                               # 'parent' event graph above

    event_factory CLI::Event::Factory

    emits event_structure: :all

    def initialize i, o, e  # [#sl-114] these three are the convention
      @io_adapter = @IO_adapter = Headless::CLI::IO::Adapter::Minimal. # #todo:during-ta-merge
        new i, o, e, Pen__.new
      on_all do |ev|
        _msg = if ev.respond_to? :render_under
          ev.render_under expression_agent
        else
          ev.message
        end
        io_adapter.emit ev.stream_name, _msg
      end
      super()
    end

    public :io_adapter

    def io_adapter= x
      never  # #todo
    end

    def io_adapter_notify ioa
      @io_adapter = @IO_adapter = ioa ; nil  # #todo:during-ta-merge
    end

    def expression_agent_for_subclient  # #todo - until client services
      expression_agent
    end

    def expression_agent
      @io_adapter.pen or never
    end ; private :expression_agent

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
      @io_adapter.pen.invoke_notify
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

    def anchored_program_name_for_subclient  # #todo - client services
      program_name
    end

  private

    def action_anchor_module      # gone at [#022] maybe..
      CLI::Actions
    end

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

    class Pen__ < Headless::CLI::Pen::Minimal

      def invoke_notify
        FUN__.clear[]
      end
      #
      FUN__ = Headless::CLI::PathTools::FUN

      def escape_path path_x
        FUN__.pretty_path[ path_x ]
      end

      def ick x  # render an invalid value.  compare to `val`, we actually
        # want quotes here to make it look clinical, and like we are referring
        # to some foreign other object
        "\"#{ x }\""
      end

      def lbl x  # render a business parameter name
        kbd x
      end

      def par i  # [#sl-036] - super hacked for now
        kbd "--#{ i.to_s.gsub '_', '-' }"
      end

      def val x  # render a business value. for CLI we render as-sis. looks
        x  # good next to styled `lbl` phrases. looks cluttered to do more
      end

      def and_ a
        a * ' and '  # #todo
      end

      def s *a  # #todo
        if a.last.respond_to? :id2name then a.last
        elsif a[ 0 ].respond_to? :upto
          's' if 1 != a[ 0 ]
        end
      end

      alias_method :calculate, :instance_exec
    end
  end
end
