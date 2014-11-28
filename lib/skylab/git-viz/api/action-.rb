module Skylab::GitViz

  module API

    class Action_  # see [#003]

      class << self

        def [] * x_a
          act = new
          ok = act.rcv_iambic x_a
          ok and act.execute
        end
      end

      Callback_::Actor.methodic self

      def initialize
        self.class.defaults.each_pair do |i, x|
          send :"#{ i }=", x
        end
        super
      end

      def rcv_iambic x_a
        prcss_iambic_passively x_a
        if x_a.length.zero?
          PROCEDE_
        else
          _ev = build_extra_iambic_event_via x_a[ 0, 1 ]
          receive_extra_iambic _ev  # #hook-in [cb]
          UNABLE_
        end
      end

      # #storypoint-20, #storypoint-25
      a = %i(
        listener session
        system_conduit
        VCS_adapter_name
        VCS_adapters_module
        VCS_listener )

      attr_writer( * a ) ; private( * a.map { |i| :"#{ i }=" } )

      def prcss_iambic_passively x_a  # #storypoint-30
        atrs = self.class.attributes
        @x_a = x_a
        pass_p = self.class.method :private_method_defined?
        while x_a.length.nonzero?
          i = x_a.first
          w_i = :"#{ i }="
          pass_p[ w_i ] or break
          x_a.shift
          atr = atrs.fetch i do end
          aa_i = if atr
            atr.is? :argument_arity
          end
          if aa_i
            send w_i
          else
            send w_i, x_a.shift
          end
        end ; nil
      end

      GitViz_._lib.formal_attribute_definer self

      def self.write_attribute_writer atr  # #storypoint-40
        super
        private atr.writer_method_name ; nil
      end

      # ~

      meta_attribute :argument_arity
      class << self
        def on_argument_arity_attribute name_i, atr  # #storyoint-30 (again)
          send :"on_arg_arity_of_#{ atr[ :argument_arity ] }", atr
        end
        def on_arg_arity_of_zero atr
          w_m_i = atr.writer_method_name ; ivar = atr.ivar
          define_method w_m_i do
            instance_variable_set ivar, true ; nil
          end ; private w_m_i ; nil
        end
        def on_arg_arity_of_one atr
          w_m_i = atr.writer_method_name ; ivar = atr.ivar
          define_method w_m_i do
            instance_variable_set ivar, @x_a.shift ; nil
          end ; private w_m_i ; nil
        end
      end

      meta_attribute :default
      class << self
        def defaults
          @default_h
        end

        def inherited mod
          mod.instance_variable_set :@default_h, {}
        end

        def on_default_attribute name_i, meta
          @default_h[ name_i ] = meta[ :default ] ; nil
        end
      end

      meta_attribute :pathname
      class << self
        def on_pathname_attribute name_i, atr
          w_m_i = atr.writer_method_name
          w_m_i_ = :"#{ name_i }_after_pathname="
          alias_method w_m_i_, w_m_i
          define_method w_m_i do |x|
            _x_ = x && ! x.respond_to?( :relative_path_from ) ?
              ::Pathname.new( x ) : x
            send w_m_i_, _x_ ; x
          end ; private w_m_i
        end
      end

      meta_attribute :reader, :writer

      # ~

      def build_yielder_for * i_a
        ::Enumerator::Yielder.new do |x|
          @listener.maybe_receive_event( * i_a, x )
        end
      end

      # ~

      def _VCS_front
        @VCS_front ||= rslv_some_VCS_front
      end

      def rslv_some_VCS_front
        vcs_adapter_i = some_VCS_adapter_name
        _const = Name_.via_variegated_symbol( vcs_adapter_i ).as_const
        vcs_mod = @VCS_adapters_module.const_get _const, false
        vcs_mod::Front.new vcs_mod, @VCS_listener do |front|
          front.set_system_conduit @system_conduit
        end
      end

      def some_VCS_adapter_name
        @VCS_adapter_name or fail "VCS_adapter_name?"
      end
    end
  end
end
