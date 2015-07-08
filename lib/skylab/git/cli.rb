module Skylab::Git

  class CLI < Home_.lib_.brazen::CLI

    Brazen_ = ::Skylab::Brazen

    def self.new * a
      new_top_invocation a, Home_::API.application_kernel_
    end

    def expression_agent_class
      Brazen_::CLI.expression_agent_class
    end

    def initialize a, ak

      @resources = Resources___.new a, ak.module
      super
    end

    class Resources___ < Resources

      # (this subclassing is questionable - would be better if ..)

      def initialize( * )
        @_cache = {}
        super
      end

      def knownness_for sym

        Callback_::Known.new_known send :"__#{ sym }__"
      end

      def __filesystem__

        @_cache[ :fs ] ||= Home_.lib_.system.filesystem
        # (directory? exist? mkdir mv open rmdir)
      end

      def __system_conduit__

        @_cache[ :sc ] ||= Home_.lib_.open_3
      end

      alias_method :system_conduit_, :__system_conduit__  # expose to this subsystem
    end

    # (( BEGIN
    Client = self
    module Adapter
      module For
        module Face
          module Of
            Hot = -> ns_sheet, my_client_class do

              -> mechanics, slug do

                annoy = mechanics.instance_variable_get( :@surface )[]
                Tmp___.new annoy, [ slug ]  # wrong, meht
              end
            end
          end
        end
      end
    end

    class Tmp___

      def initialize annoy, s_a

        _sin = annoy.instance_variable_get :@sin
        _sout = annoy.instance_variable_get :@out
        _serr = annoy.instance_variable_get :@err

        @_bridge = CLI.new _sin, _sout, _serr, s_a
      end

      def pre_execute
        ACHIEVED_
      end

      def invokee
        @_bridge
      end
    end
    # END ))
  end
end
