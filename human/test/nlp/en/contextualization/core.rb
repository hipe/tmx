module Skylab::Human::TestSupport

  module NLP::EN::Contextualization

    def self.[] tcc
      tcc.include self
    end

    module Ham

      def self.[] tcc
        Expect_Event[ tcc ]
        tcc.send :define_singleton_method, :emit_by_, Emit_by___
        tcc.include self
      end

      # -
        Emit_by___ = -> & p do

          yes = true ; x = nil
          define_method :_ham_tuple do
            if yes
              yes = false
              x = ___build_ham_tuple_for_emission p
            end
            x
          end
        end
      # -

      def ___build_ham_tuple_for_emission p

        hs = __ham_read_DSL_specification p

        o = hs.c15n

        ham_ad_hoc_customizations_ o

        _oes_p = o.to_emission_handler
        _oes_p.call( * hs.chan, & hs.em_p )

        __ham_flush_to_tuple
      end

      DSL_Spec___ = ::Struct.new :ss, :assoc, :chan, :em_p, :c15n

      def selection_stack_as * x_a
        @_ham_spec.ss = x_a
      end

      def subject_association_as x
        @_ham_spec.assoc = x
      end

      def __ham_read_DSL_specification p

        hs = DSL_Spec___.new
        @_ham_spec = hs

        _fake_oes_p = -> * i_a, & x_p do
          hs.chan = i_a
          hs.em_p = x_p
          UNRELIABLE_
        end

        instance_exec _fake_oes_p, & p

        remove_instance_variable :@_ham_spec

        o = subject_class_.new( & event_log.handle_event_selectively )
        o.expression_agent = common_expag_
        o.selection_stack = hs.ss
        o.subject_association = hs.assoc
        hs.c15n = o
        hs
      end

      def __ham_flush_to_tuple

        a = remove_instance_variable( :@event_log ).flush_to_array
        1 == a.length or fail
        em = a.first
        em.reify_by do |y_p|
          common_expag_.calculate [], & y_p
        end

        [ em.channel_symbol_array, * em.cached_event_value ]
      end

      def assoc_ sym
        Callback_::Name.via_variegated_symbol sym
      end

      def channel_
        _ham_tuple.fetch 0
      end

      def first_line_
        _ham_tuple.fetch 1
      end

      def second_line_
        _ham_tuple.fetch 2
      end
    end

    define_method :no_name_, ( Lazy_.call do
      class No_Name____
        def name
          NOTHING_
        end
        self
      end.new
    end )

    def common_expag_
      Home_.lib_.brazen::API.expression_agent_instance
    end

    def subject_class_
      Home_::NLP::EN::Contextualization
    end
  end
end
