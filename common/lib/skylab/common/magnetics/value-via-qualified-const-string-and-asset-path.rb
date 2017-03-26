module Skylab::Common

  class Magnetics::Value_via_QualifiedConstString_and_AssetPath < Home_::MagneticBySimpleModel

    #   - 1x. [here] only. :[#068].
    #   - [cm] may have better version (was written once, before #history-A)

    attr_writer(
      :listener,
      :path,
      :qualified_const_string,
    )

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

      _s_a = @qualified_const_string.split CONST_SEPARATOR

      _s_a.reduce ::Object do | m, c |

        m.const_get c, false

      end
    end

    # ==
    # ==
  end
end
# #history-A: magnetic not session
