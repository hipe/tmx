require 'skylab/common'

module Skylab::Plugin

  class << self

    def lib_
      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        Lib_, self )
    end
  end  # >>

  Common_ = ::Skylab::Common
  Autoloader_ = Common_::Autoloader
  Lazy_ = Common_::Lazy

  # ==

  Stream_ = -> a, & p do
    Common_::Stream.via_nonsparse_array a, & p
  end

  Scanner_ = -> a do
    Common_::Scanner.via_array a
  end

  Zerk_no_deps_ = Lazy_.call do
    require 'no-dependencies-zerk'
    ::NoDependenciesZerk
  end

  # ==

  ArgumentError = ::Class.new ::ArgumentError

  module Lib_

    sidesys, _stdlib = Autoloader_.at :build_require_sidesystem_proc,
      :build_require_stdlib_proc

    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Fields = sidesys[ :Fields ]
    Parse = sidesys[ :Parse ]
    Zerk = sidesys[ :Zerk ]

    Stdlib_option_parser = -> do
      require 'optparse'
      ::OptionParser
    end
  end

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ] ]

  ACHIEVED_ = true
  CLI = nil  # for host
  DASH_ = '-'
  EMPTY_A_ = [].freeze
  EMPTY_S_ = ''.freeze
  Home_ = self
  KEEP_PARSING_ = true
  NIL_ = nil
  NIL = nil  # #open [#sli-116.C]
  NOTHING_ = NIL
  SimpleModel_ = Common_::SimpleModel
  SPACE_ = ' '
  UNABLE_ = false
  UNDERSCORE_ = '_'

  def self.describe_into_under y, _
    y << "plugin/bundle frameworks. dependency injection. nothing very hot."
  end
end
