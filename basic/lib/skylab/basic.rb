require 'skylab/common'

module Skylab::Basic  # introduction at [#020]

  class << self

    def default_property
      Default_property_instance__[]
    end

    def dup_mixed x
      if x
        if x.respond_to? :dupe
          x.dupe
        else
          case x
          when ::TrueClass, ::Symbol, ::Numeric
            x
          else
            x.dup
          end
        end
      else
        x
      end
    end

    def lib_
      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        Lib_, self )
    end
  end  # >>

  Common_ = ::Skylab::Common
  SimpleModel_ = Common_::SimpleModel

  Default_property_instance__ = Common_.memoize do
    MinimalProperty.via_variegated_symbol :argument
  end

  class Fuzzy  # :[#015].

    class << self

      def reduce_array_against_string a, s, * p_a, & p
        p and p_a.push p
        o = self.begin
        o.sparse_array = a
        o.string = s
        o.procs = p_a
        o.execute
      end

      def reduce_to_array_stream_against_string st, s, * p_a, & p
        p and p_a.push p
        o = self.begin
        o.stream = st
        o.string = s
        o.procs = p_a
        o.execute
      end

      def prototype_by
        o = self.begin
        yield o
        o.freeze
      end

      alias_method :begin, :new
      undef_method :new
    end  # >>

    def initialize
      @be_case_sensitive = false
      @candidate_map = nil
      @result_map = nil
    end

    def procs= p_a
      @candidate_map, @result_map = p_a
    end

    def sparse_array= a
      _nonsparse_array = a.select( & IDENTITY_ ).to_a
      @stream = Common_::Stream.via_nonsparse_array _nonsparse_array
      a
    end

    attr_writer(
      :be_case_sensitive,
      :candidate_map,
      :result_map,
      :stream,
      :string,
    )

    def execute

      a = []
      candidate_map = @candidate_map || IDENTITY_
      result_map = @result_map || IDENTITY_
      s = @string
      st = @stream

      rx = if @be_case_sensitive
        /\A#{ ::Regexp.escape @string }/
      else
        /\A#{ ::Regexp.escape @string }/i
      end

      # ->
        begin
          x = st.gets
          x or break
          s_ = candidate_map[ x ]
          if rx =~ s_
            if s == s_
              a.clear.push result_map[ x ]
              break
            end
            a.push result_map[ x ]
          end
          redo
        end while nil
        # <-
      a
    end
  end

  class Process < SimpleModel_  # [gi], [sy]

    class << self
      def via_five * five
        define do |o|
          o.__init_via_five five
        end
      end
    end  # >>

    def initialize
      yield self
    end

    def pid= pid
      @wait = ProcessWaiter___.new pid ; pid
    end

    def __init_via_five five
      @in, @out, @err, @wait, @command = five
      freeze
    end

    attr_accessor :in, :out, :err, :command

    attr_reader :wait

    # ==

    class ProcessWaiter___  # trying to make our own `::Process::Waiter` because ???
      def initialize pid
        @pid = pid
        @_value = :__value_initially
      end
      def value
        send @_value
      end
      def __value_initially
        ::Process.wait @pid  # result is same pid
        @__value = $?  # EEW - `::Process::Status`
        @_value = :__value_normally
        send @_value
      end
      def __value_normally
        @__value
      end
    end
    # ==
  end

  class MinimalProperty

    class << self

      def via_variegated_symbol i
        new Common_::Name.via_variegated_symbol i
      end

      alias_method :via_name_function, :new
      private :new
    end  # >>

    def initialize name
      @name = name
      freeze
    end

    attr_reader :name

    def name_symbol
      @name.as_variegated_symbol
    end

    def description
      "« #{ @name.as_slug } »"  # :+#guillemets
    end

    def parameter_arity
      :too_basic_for_arity
    end
  end

  module Simple_Selective_Sender_Methods_

    # for better regression, don't load the event lib until you need it

  private

    def maybe_send_event * i_a, & ev_p
      if @on_event_selectively
        @on_event_selectively[ * i_a, & ev_p ]
      else
        raise ev_p[].to_exception
      end
    end

    def build_argument_error_event_with_ * x_a, & msg_p
      x_a.push :error_category, :argument_error
      build_not_OK_event_via_mutable_iambic_and_message_proc x_a, msg_p
    end

    def build_not_OK_event_with * x_a, & msg_p
      build_not_OK_event_via_mutable_iambic_and_message_proc x_a, msg_p
    end

    def build_not_OK_event_via_mutable_iambic_and_message_proc x_a, msg_p
      Common_::Event.inline_not_OK_via_mutable_iambic_and_message_proc x_a, msg_p
    end
  end

  Proxy__PairStream_via_ArgumentArray_ = -> a do  # #stowaway
    if 1 == a.length
      Home_::Hash.pair_stream a.first
    else
      Home_::List.pair_stream_via_even_iambic a
    end
  end

  Stream_ = -> a, & p do
    Common_::Stream.via_nonsparse_array a, & p
  end

  Lazy_ = Common_::Lazy

  Assume_ACS_ = Lazy_.call do
    ACS_ = ::Skylab::Autonomous_Component_System
    NIL_
  end

  Attributes_actor_ = -> cls, * a do
    Home_.lib_.fields::Attributes::Actor.via cls, a
  end

  Scanner_ = -> a do
    Common_::Scanner.via_array a
  end

  # --

  Autoloader_ = Common_::Autoloader

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    Bundle_Directory = -> mod do
      Plugin[]::Bundle::Directory[ mod ]
    end

    Empty_string_scanner = -> do
      StringScanner__[].new ''
    end

    Enhancement_shell = -> a do
      Plugin[]::Bundle::Enhance::Shell.new a
    end

    IO_lib = -> do
      System_lib[]::IO
    end

    NLP_EN = -> do
      Human[]::NLP::EN
    end

    Oxford_or = -> a do
      Common_::Oxford_or[ a ]
    end

    Set = -> * a do
      Set__[].new( * a )
    end

    Some_stderr_IO = -> do
      System_lib[]::IO.some_stderr_IO
    end

    Strange = -> x do  # looks better in expressions for this to be here
      Home_::String.via_mixed x
    end

    String_IO = -> do
      StringIO__[].new
    end

    String_scanner = -> str do
      StringScanner__[].new str
    end

    StringScanner__ = Common_.memoize do
      require 'strscan'
      ::StringScanner
    end

    Treetop = Common_.memoize do
      require 'treetop'
      ::Treetop
    end

    Autonomous_component_system = sidesys[ :Autonomous_Component_System ]
    Brazen = sidesys[ :Brazen ]
    Fields = sidesys[ :Fields ]
    Human = sidesys[ :Human ]
    Parse_lib = sidesys[ :Parse ]
    Pathname = stdlib[ :Pathname ]
    Plugin = sidesys[ :Plugin ]
    Set__ = stdlib[ :Set ]
    StringIO__ = stdlib[ :StringIO ]
    System_lib = sidesys[ :System ]
    Test_support = sidesys[ :TestSupport ]
    Time = stdlib[ :Time ]
    Zerk = sidesys[ :Zerk ]  # for CLI styling in word wrappers
  end

  # --

  ArgumentError = ::Class.new ::ArgumentError

  ACHIEVED_ = true
  CLI = nil  # for host
  CONST_SEP_ = '::'.freeze
  Home_ = self
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  IDENTITY_ = -> x { x }
  KEEP_PARSING_ = true
  MONADIC_EMPTINESS_ = -> _ {}
  MONADIC_TRUTH_ = -> _ { true }
  NEWLINE_ = "\n".freeze
  NIL_ = nil
  NOTHING_ = nil
  NILADIC_FALSEHOOD_ = -> { false }
  PROCEDE_ = true
  SPACE_ = ' '.freeze
  UNABLE_ = false
  UNDERSCORE_ = '_'

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ] ]

  def self.describe_into_under y, _
    y << "generic data structures (and some algorithms) common enough to be"
    y << "used across projects but not so common that they are in \"common\""
  end
end
