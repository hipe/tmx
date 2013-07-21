module Skylab::Headless

  module CLI::Client::DSL

    # You leverage the dynamics for synergy presented herein when you want
    # a) the conveninece of a DSL but b) your CLI is simple and doesn't have
    # subcommands (i.e isn't a "box"). Everything is experimental and subject
    # to change and will definately break your app. Everything.

    def self.extended mod  # [#sl-111]
      mod.module_eval do
        include CLI::Client::DSL::InstanceMethods
        @tug_class = MAARS::Tug
        extend CLI::Client::DSL::ModuleMethods # `method_added` avoid trouble
        init_autoloader caller[2] # extensive note about this in box/dsl.rb
      end
      nil
    end
  end

  module CLI::Client::DSL::ModuleMethods

    include Autoloader::Methods   # (see extensive node in box/dsl.rb)

    include CLI::Action::ModuleMethods  # `option_parser`, `desc`

    # `default_action` - your default action is simply an instance method
    # your client defiines that iself results in the name of another method
    # to be used as the default "action method" - this in turn is the
    # method name to be used as an "action method" if for e.g the queue
    # is empty after parsing any opts, and the engine needs to decide what
    # method to use to process the request.
    #
    # This action method will in turn be used possibly to parse argv args
    # with, and then this method will be called with any valid-arity-having
    # argv.
    #
    # A common default name for this assumed elsewhere is `process`, however
    # it is the opinion of the present author that you should use a name
    # that is expressive (in one or two words) about what your particular
    # action actually does. Hence this method (er., dsl writer) can be used
    # to indicate that.
    #

    def default_action foo        # (shorthand for this)
      define_method :default_action do foo end
      nil
    end
  end

  module CLI::Client::DSL::InstanceMethods

    include CLI::Client::InstanceMethods

    # include CLI::Box::DSL::InstanceMethods WAS

  private

    # `build_option_parser` -- different than the other two (e.g) same-named
    # instance methods defined in another dsl module elsewhere, this is a
    # straightforward default implementation of b.o.p that creates a stdlib
    # o.p and runs any definition blocks on it that you may have specified
    # and adds a (hopefully) correctly wired help option iff you didn't
    # specify what looks like one ("-h") yourself in one of your o.p
    # definition blocks.
    #
    # If your option parser has a special plan for the '-h' switch, the below
    # default help wiring won't trigger, so you might want to wire help
    # differently (e.g just '--help') and follow the below as a model (that
    # is, do "enqueue :help" in the handler for your option).
    #

    def build_option_parser
      blks = self.class.option_parser_blocks
      op = Headless::Services::OptionParser.new
      if blks
        blks.each do |blk|
          instance_exec op, &blk
        end
      end
      if ! ( op.top.list.detect do |sw|
        sw.respond_to? :short and '-h' == sw.short.first
      end ) then
        op.on '-h', '--help', 'this screen' do
          enqueue :help
        end
      end
      op
    end
  end
end
