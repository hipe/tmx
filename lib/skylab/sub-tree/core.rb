require_relative '../callback/core'

module Skylab::SubTree

  Callback_ = ::Skylab::Callback

  module API

    class << self

      def call * x_a, & oes_p
        bc = application_kernel_.bound_call_via_mutable_iambic x_a, & oes_p
        bc and bc.receiver.send bc.method_name, * bc.args
      end

      define_method :application_kernel_, ( Callback_.memoize do
        SubTree_.lib_.brazen::Kernel.new SubTree_
      end )

      def action_class_
        SubTree_.lib_.brazen.model.action_class
      end
    end  # >>
  end

  class << self

    def lib_
      @lib ||= SubTree_::Lib_::INSTANCE
    end
  end  # >>

  Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  Autoloader_[ Models_ = ::Module.new, :boxxy ]

  ACHIEVED_ = true

  DASH_ = '-'.freeze

  DEFAULT_GLYPHSET_IDENTIFIER_ = :narrow

  DOT_ = '.'.freeze

  EMPTY_A_ = [].freeze

  EMPTY_P_ = -> {}

  EMPTY_S_ = ''.freeze

  KEEP_PARSING_ = true

  IDENTITY_ = -> x { x }

  stowaway :Library_, 'lib-'

  NEWLINE_ = "\n"

  NIL_ = nil

  SEP_ = ::File::SEPARATOR

  SubTree_ = self

  SPACE_ = ' '.freeze

  UNABLE_ = false

  UNDERSCORE_ = '_'.freeze
end

# :+#tombstone: dedicated API node
