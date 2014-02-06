module Skylab::GitViz

  module API

    class Action_  # read the API action narrative [#003]

      def self.[] * x_a
        new( x_a ).execute
      end

      GitViz::Lib_::Headless[]::API::Simple_monadic_iambic_writers[ self ]

      def initialize x_a
        self.class.defaults.each_pair do |k, v|
          send :"#{ k }=", v
        end
        absorb_iambic_fully x_a
        super()
      end

      a = %i( listener session VCS_listener VCS_adapter_name )  # #storypoint-20
      attr_writer( * a ) ; private( * a.map { |i| :"#{ i }=" } )

    private

      def absorb_iambic_passively x_a  # #storypoint-30
        atrs = self.class.attributes
        @x_a = x_a
        white_p = self.class.method :private_method_defined?
        while x_a.length.nonzero?
          i = x_a.first ; w_i = :"#{ i }="
          white_p[ w_i ] or break ; x_a.shift
          aa_i = if (( atr = atrs.fetch i do end ))
            atr.is? :argument_arity
          end
          if aa_i
            send w_i
          else
            send w_i, x_a.shift
          end
        end ; nil
      end

      extend MetaHell::Formal::Attribute::Definer

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
          @listener.call_any_listener( * i_a ) do x end
        end
      end

      # ~

      def _VCS_front
        @VCS_front ||= rslv_some_VCS_front
      end

      def rslv_some_VCS_front
        _anchor_mod = GitViz::VCS_Adapters_.const_fetch some_VCS_adapter_name
        _anchor_mod::Front.new @VCS_listener
      end

      def some_VCS_adapter_name
        @VCS_adapter_name or fail "VCS_adapter_name?"
      end
    end
  end
end
