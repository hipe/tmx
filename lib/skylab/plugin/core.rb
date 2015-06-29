require_relative '..'
require_relative '../callback/core'

module Skylab::Plugin

  class << self

    def lib_
      @___lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        Lib_, self )
    end
  end  # >>

  class Dispatcher_

    def initialize resources, & oes_p
      @on_event_selectively = oes_p
      @plugin_a = []
      @resources = resources
    end

    undef_method :initialize_dup

    def load_plugins_in_module mod

      _st = Callback_::Stream.via_nonsparse_array mod.constants do | const |

        mod.const_get const, false

      end

      load_plugins_in_prototype_stream _st
    end

    def load_plugins_in_prototype_stream st

      st.each do | plugin_class_like |

        add_plugin_via_prototype plugin_class_like
      end
      NIL_
    end

    def add_plugin_via_prototype plugin_class_like

      pu_d = @plugin_a.length

      pu = plugin_class_like.new_via_plugin_identifier_and_resources(
        pu_d, @resources, & @on_event_selectively )

      receive_plugin pu_d, pu
      NIL_
    end

    def receive_plugin pu_d, pu

      @plugin_a[ pu_d ] = pu
      NIL_
    end
  end

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  module Lib_

    sidesys, _stdlib = Autoloader_.at :build_require_sidesystem_proc,
      :build_require_stdlib_proc

    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Parse = sidesys[ :Parse ]

    Stdlib_option_parser = -> do
      require 'optparse'
      ::OptionParser
    end

    IN_MOTION_table_actor = -> * x_a do

      _Face = Autoloader_.require_sidesystem :Face
      _Face::CLI::Table.call_via_iambic x_a
    end
  end

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  Autoloader_[ Bundle = ::Module.new ]

  ACHIEVED_ = true
  DASH_ = '-'
  EMPTY_A_ = [].freeze
  Home_ = self
  KEEP_PARSING_ = true
  NIL_ = nil
  SPACE_ = ' '
  UNABLE_ = false
  UNDERSCORE_ = '_'

end
