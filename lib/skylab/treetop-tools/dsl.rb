# encoding: UTF-8

module Skylab::TreetopTools
  # #abstraction-candidate: this (in some form) might one day go up
  # if it ever isn't painful to look at.

  module DSL
  end


  module DSL::Client
  end


  class DSL::Joystick
    # A "Joystick" is our cute moniker for the object that forms the
    # sole point of interface for a DSL. The entirety of the DSL
    # consists of messages that can be sent to the object.  (Conversely,
    # the interface of the Joystick *is* the DSL.)
    #
    # The developer would subclass this DSL::Joystick class and use
    # (ahem) DSL of the parameter definer (e.g.) to define the desired DSL.
    #
    # An instance of this Joystick would then be passed to e.g. some
    # user-provided block, during which the Joystick would "record" the
    # information from the user, which is then retrivable later by the
    # `__actual_parameters` method.
    #
    # (In this implementation, the 'actual parameters' is an object
    # of a simple, custom-built struct built dynamically from the
    # elements of the DSL.)

    extend Headless::Parameter::Definer::ModuleMethods # we do *not* want ..

    include Headless::Parameter::Definer::InstanceMethods::ActualParametersIvar

    def __actual_parameters       # we want to keep the namespace clear for
      @actual_parameters          # the DSL
    end


  protected

    def initialize
      @actual_parameters = # (per ActualParametersIvar it must be this name)
        self.class.build_actual_parameters
    end
  end

  class << DSL::Joystick
    const = :ActualParameters     # make a simple, custom actuals holder
    define_method :build_actual_parameters do # that is just a struct whose
      if const_defined? const, false # members are determined by the names
        const_get const, false    # of the parameters of our DSL
      else
        k = ::Class.new( ::Struct.new(* parameters.each.map(& :normalized_local_name ) ) )
        k.class_eval do
          include Headless::Parameter::Definer::InstanceMethods::StructAdapter
          public :known?
        end
        const_set const, k
      end.new
    end
  end

  class DSL::Client::Minimal # (used to be struct, too confusing w/ []=)
    # You, the DSL Client, are the one that runs the client (user)'s
    # block around your joystick instance, runs the validation etc,
    # emits any errors, does any normalization, and then comes out at the
    # other end with a `actual_parameters` structure that holds the client's
    # (semi valid) request

    include Headless::Parameter::Controller::InstanceMethods # for set!

    include Headless::Parameter::Definer::InstanceMethods::IvarsAdapter
                                  # once we absorb the dsl actuals, we might
                                  # use this for reflection


  protected

    def initialize request_client, dsl_body, events
      _headless_sub_client_init request_client
      self.body = dsl_body
      self.events = events
    end

    def absorb! struct
      struct.members.each do |name|
        instance_variable_set("@#{name}", struct[name])
      end
      true
    end

    attr_accessor :body           # user-provided callable body of the DSL

    def build_joystick
      joystick_class.new
    end

    def call_body_and_absorb!     # the heart of the DSL pattern
      result = false
      begin
        joystick = (self.joystick ||= build_joystick) # persist accross bodies
        body.call joystick
        actuals = joystick.__actual_parameters
        set! nil, actuals or break # defaults, validation etc
        absorb! actuals           # now they are our ivars
        result = true
      end while false
      result
    end

    def callbacks
      @callbacks ||= begin        # cheap, compartmentalized pub-sub
        o = Headless::Parameter::Definer.new do
          param :error, hook: true, writer: true
          param :info,  hook: true, writer: true
          alias_method :on_error, :error # hm ..
          alias_method :on_info, :info
        end.new(& events)
        self.events = nil
        o.on_error ||= ->(msg) { fail("Couldn't #{verb} #{noun} -- #{msg}") }
        o.on_info  ||= ->(msg) { $stderr.puts("(⌒▽⌒)☆  #{msg}  ლ(́◉◞౪◟◉‵ლ)") }
        o
      end
    end

    attr_accessor :events         # gets absorbed into callbacks

    def emit type, payload
      callbacks[type][ payload ]  # to be cute we did this a different way
    end

    def formal_parameters         # you betcha those are our formal parameters
      joystick_class.parameters
    end

    attr_accessor :joystick

    def joystick_class
      self.class.const_get :DSL, false # descendent classes should define this
    end

    def noun ; 'grammar' end      # used in callbacks for val'n messages

    def verb ; 'load' end         # used in callbacks for val'n messages
  end
end
