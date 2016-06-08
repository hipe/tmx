module Skylab::TMX::TestSupport

  module Mocks

    class Unbound < ::Module

      include Home_.lib_.brazen::Nodesque::Methods::Unbound_Methods

      attr_reader :sym

      def initialize sym
        @sym = sym
      end

      def description_under expag
        me = self
        expag.calculate do
          val me.sym.id2name
        end
      end

      def name_function
        @__nf ||= Common_::Name.via_variegated_symbol @sym
      end

      def is_branch
        true
      end

      def new k, & oes_p
        Bound___.new self, k, & oes_p
      end

      def __build_unordered_selection_stream

        mod = const_get :Models_, false
        _const_a = mod.constants
        _st = Common_::Stream.via_nonsparse_array _const_a do | const |

          mod.const_get const, false
        end

        _st.expand_by do | mdl |

          mod_ = mdl.const_get :Actions, false
          _const_a_ = mod_.constants

          Common_::Stream.via_nonsparse_array _const_a_ do | const |

            mod_.const_get const, false
          end
        end
      end
    end

    class Bound___

      def initialize mock_cls, k, & oes_p

        @_kr = k
        @_mock_class = mock_cls
        @_oes_p = oes_p
      end

      def is_visible
        true
      end

      def name
        @_mock_class.name_function
      end

      def after_name_symbol
        NIL_
      end

      def fast_lookup
        -> _nf do
          # we would have to walk the models
          NIL_
        end
      end

      def to_unordered_selection_stream
        @_mock_class.__build_unordered_selection_stream( & @_oes_p )
      end

      def kernel
        @_kr
      end
    end

    App_Kernels = ::Module.new
  end
end
