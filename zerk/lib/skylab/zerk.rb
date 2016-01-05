require 'skylab/callback'

module Skylab::Zerk  # intro in [#001] README

  class << self

    def persist args, acs, & p

      _oes_p_p = handler_builder_for_ acs, & p

      Persist___[ args, acs, & _oes_p_p ]
    end

    def test_support
      if ! Home_.const_defined? :TestSupport
        load ::File.expand_path( '../../../test/test-support.rb', __FILE__ )
      end
      Home_.const_get :TestSupport, false
    end

    def unmarshal st, acs, & p

      _oes_p = handler_builder_for_ acs, & p

      Unmarshal___[ st, acs, & _oes_p ]
    end

    def handler_builder_for_ acs

      Require_ACS_[]

      if block_given?
        self._DESIGN_ME
      end

      acs.method :event_handler_for
    end

    def lib_
      @___lib ||= Callback_.
        produce_library_shell_via_library_and_app_modules Lib_, self
    end
  end  # >>

  Callback_ = ::Skylab::Callback

  Interface_stream_for_ = -> target_sym, acs do

    _ = ACS_::For_Interface::To_stream[ acs ]

    _.reduce_by do | qkn |
      sym = qkn.association.intent
      if sym
        target_sym == sym
      else
        true
      end
    end
  end

  Unmarshal___ = -> st, acs, & oes_p_p do

    if st.respond_to? :read
      json = st.read
    else
      json = ""
      while line = st.gets
        json.concat line
      end
    end

    _oes_p = oes_p_p[ acs ]

    o = ACS_::Modalities::JSON::Interpret.new( & _oes_p )
    o.ACS = acs
    o.JSON = json

    o.context_linked_list = begin

      _context_value = -> do
        'in input JSON'
      end

      Home_.lib_.basic::List::Linked[ nil, _context_value ]
    end

    o.execute
  end

  Persist___ = -> args, acs, & oes_p_p do

    y = args.shift

    _oes_p = oes_p_p[ acs ]

    o = ACS_::Modalities::JSON::Express.new( & _oes_p )

    o.downstream_IO_proc = -> do
      y
    end

    o.upstream_ACS = acs

    if args.length.nonzero?
      args.each_slice 2 do | k, x |
        o.send :"#{ k }=", x
      end
    end

    o.execute
  end

  Is_listy_ = -> sym do  # assume Fields_
    if sym
      Fields_::Can_be_more_than_zero[ sym ]
    else
      false  # the default is not listy
    end
  end

  Lazy_ = Callback_::Lazy

  Require_ACS_ = Lazy_.call do
    ACS_ = Home_.lib_.ACS
    NIL_
  end

  Require_field_library_ = Lazy_.call do
    Fields_ = Home_.lib_.fields
    NIL_
  end

  Autoloader_ = Callback_::Autoloader

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    ACS = sidesys[ :Autonomous_Component_System ]
    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Fields = sidesys[ :Fields ]
    Human = sidesys[ :Human ]
    Open_3 = stdlib[ :Open3 ]

    String_scanner = Lazy_.call do
      require 'strscan'
      ::StringScanner
    end

    system_lib = sidesys[ :System ]
    System = -> do
      system_lib[].services
    end
  end

  module View_Controllers_
    Autoloader_[ self ]
  end

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ] ]

  ACHIEVED_ = true
  EMPTY_A_ = [].freeze
  EMPTY_S_ = ''
  FINISHED_ = nil
  Home_ = self
  KEEP_PARSING_ = true
  NEWLINE_ = "\n"
  NIL_ = nil
  NOTHING_ = nil
  SUCCESS_EXITSTATUS = 0
  SPACE_ = ' '
  UNABLE_ = false
  UNRELIABLE_ = :_unreliable_  # if you're evaluating this, you shouldn't be
end
