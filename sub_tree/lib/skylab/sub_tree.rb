require 'skylab/callback'

module Skylab::SubTree

  Callback_ = ::Skylab::Callback

  def self.describe_into_under y, _
    y << "an umbrella node for varous operations on a filesystem tree.."
  end

  module API

    class << self

      def call * x_a, & oes_p
        bc = application_kernel_.bound_call_via_mutable_iambic x_a, & oes_p
        bc and bc.receiver.send bc.method_name, * bc.args
      end

      define_method :application_kernel_, ( Callback_.memoize do
        Home_.lib_.brazen::Kernel.new Home_
      end )

      def action_class_
        Home_.lib_.brazen::Action
      end
    end  # >>
  end

  class << self

    def lib_
      @lib ||= Home_::Lib_::INSTANCE
    end
  end  # >>

  Attributes_actor_ = -> cls, * a do
    Home_.lib_.fields::Attributes::Actor.via cls, a
  end

  Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ]]

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
  Home_ = self
  SPACE_ = ' '.freeze
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze
end

# :+#tombstone: dedicated API node
