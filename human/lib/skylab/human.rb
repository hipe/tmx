require 'skylab/callback'

module Skylab::Human  # :[#001].

  class << self

    def lib_
      @___lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end
  end  # >>

  Callback_ = ::Skylab::Callback

  Lazy_ = Callback_::Lazy

  # -- proc-like support methods

  atrs = attrs = nil

  Attributes_actor_ = -> cls, * a do
    ( atrs || attrs[] )::Actor.via cls, a
  end

  Attributes_ = -> h do
    ( atrs || attrs[] )[ h ]
  end

  attrs = -> do
    Require_fields_lib_[]
    atrs
  end

  Require_fields_lib_ = Lazy_.call do
    attrs = nil
    Field_ = Home_.lib_.fields
    atrs = Field_::Attributes
    NIL_
  end

  # -- would-be orphanic stowaways


  Autoloader_ = Callback_::Autoloader

  module NLP
    Autoloader_[ self ]
    NLP_ = self
  end

  # --

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ] ]

  ACHIEVED_ = true
  CLI = nil  # for host
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''
  Home_ = self
  IDENTITY_ = -> x { x }
  NEWLINE_ = "\n"
  NOTHING_ = nil
  NIL_ = nil
  NONE_ = nil
  KEEP_PARSING_ = true
  SPACE_ = ' '
  UNDERSCORE_ = '_'
end
