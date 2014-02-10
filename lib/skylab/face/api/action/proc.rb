module Skylab::Face

  class API::Action

    module Proc_

      class Isomorphic_

        def initialize p
          @keys_provided_set = @param_h = nil
          @proc = p ; @mod = Module.new
          Lib_::Field_box_enhance[ @mod, -> do
            field_class_instance_methods -> { API::Params_::Param_IMs_ }
            meta_fields( * API::Params_::METAFIELD_A_A_ )
            fields( * p.parameters.map do |opt_req_rest, i|
              [ i, * H_.fetch( opt_req_rest ) ]
            end )
          end ]
        end
        H_ = {  # map parameters as ruby reports them to fields as we
          opt: [ :arity, :zero_or_one ],  # describe them
          req: [ :arity, :one ]
        }.freeze

      end
    end

    Proc = Proc_::Isomorphic_.method :new  # sneak this in there

    class Proc_::Isomorphic_

      def execute
        # in theory, if the validaton of the normalization worked correctly
        # w/ re: to required fields, the below algo should be ok but note
        # it needs more testing.
        args = [ ] ; bx = field_box ; p_h = @param_h ; set = @keys_provided_set
        bx._order.each do |i|
          set && set.include?( i ) or next
          args << p_h[ i ]
        end
        @proc[ * args ]
      end

      def has_emit_facet  # fulfill [#027] - we do *not* want the event-
        # wiring hook. Procs are simple and have an atomic, monadic result.
        # if you need to do something like emitting events during the
        # execution of your proc you could attempt something convoluted
        # in its parameters, but you probably not *not* be using a proc
        # to implement your action in the first place ^_^
        false
      end

      def has_service_facet
        false
      end

      def has_param_facet
        true  # so we receive the call to normalize below
      end

      define_method :super_normalize, & API::Normalizer_::Normalize_method_

      def normalize y, par_h
        par_h and @keys_provided_set = Library_::Set.new( par_h.keys )
        super_normalize y, par_h
      end

      def field_value_notify fld, x
        @param_h ||= { }
        @param_h[ fld.local_normal_name ] = x
        nil
      end

    private

      def has_field_box
        true
      end

      def field_box
        @mod.field_box
      end

      def normalization_failure_line_notify msg
        raise ::ArgumentError, msg
      end

      def any_expression_agent
      end
    end
  end
end
