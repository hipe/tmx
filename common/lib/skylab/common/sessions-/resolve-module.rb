module Skylab::Common

  class Sessions_::Resolve_Module  # :[#068].

    attr_writer(
      :path,
      :qualified_const_string,
    )

    def initialize & p
      @on_event_selectively = p
    end

    def execute

      _ok = __require_path
      _ok && __produce_module
    end

    def __require_path

      path = @path
      path = ::File.expand_path path  # #todo use filesystem conduit from rsx
      en = ::File.extname path

      if en.length.nonzero?
        path = path[ 0 ... - en.length ]
      end

      ::Kernel.require path

      ACHIEVED_
    end

    def __produce_module

      _s_a = @qualified_const_string.split CONST_SEP_

      _s_a.reduce ::Object do | m, c |

        m.const_get c, false

      end
    end
  end
end
