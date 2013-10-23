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


  private

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
        k = ::Class.new( ::Struct.new(*
          parameters.each.map(& :normalized_parameter_name ) ) )
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

    Headless::Parameter[ self, :parameter_controller, :oldschool_parameter_error_structure_handler ]

    include Headless::Parameter::Definer::InstanceMethods::IvarsAdapter
                                  # once we absorb the dsl actuals, we might
                                  # use this for reflection


  private

    def initialize request_client, dsl_body_p, event_p
      init_headless_sub_client request_client
      @dsl_body_p, @event_p = dsl_body_p, event_p
    end

    def absorb! struct
      struct.members.each do |name|
        instance_variable_set "@#{ name }", struct[ name ]
      end
      true
    end

    def build_joystick
      joystick_class.new
    end

    def call_body_and_absorb!     # the heart of the DSL pattern
      r = false
      begin
        @joystick ||= build_joystick  # persist across bodies
        @dsl_body_p[ @joystick ]
        actuals = @joystick.__actual_parameters
        set! nil, actuals or break # defaults, validation etc
        absorb! actuals           # now they are our ivars
        r = true
      end while false
      r
    end

    def callbacks
      @callbacks ||= begin        # cheap, compartmentalized pub-sub
        o = Headless::Parameter::Definer.new do
          param :error, hook: true, writer: true
          param :info,  hook: true, writer: true
          alias_method :on_error, :error # hm ..
          alias_method :on_info, :info
        end.new( & @event_p )
        @event_p = nil
        o.on_error ||= ->(msg) { fail("Couldn't #{verb} #{noun} -- #{msg}") }
        o.on_info  ||= ->(msg) { infostream.puts("(⌒▽⌒)☆  #{msg}  ლ(́◉◞౪◟◉‵ლ)") }
        o
      end
    end

    def infostream
      @infostream ||= Headless::CLI::IO.stderr
    end

    def emit type, payload
      callbacks[ type ][ payload ]  # to be cute we did this a different way
    end

    def formal_parameters         # you betcha those are our formal parameters
      joystick_class.parameters
    end

    def joystick_class
      self.class.const_get :DSL, false # descendent classes should define this
    end

    def noun ; 'grammar' end      # used in callback_h for val'n messages

    def verb ; 'load' end         # used in callback_h for val'n messages
  end
end
