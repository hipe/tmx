module Skylab::Tabular

  class API

    class << self

      def call * x_a, & p
        Zerk_lib_[]
        _as = Zerk_::API::ArgumentScanner.via_array x_a, & p
        bc = new( _as ).__to_bound_call_of_operator
        if bc
          bc.receiver.send bc.method_name, * bc.args, & bc.block
        else
          bc
        end
      end

      private :new
    end  # >>

    def initialize as
      @argument_scanner = as
    end

    def __to_bound_call_of_operator
      if __resolve_load_ticket
        if __load_ticket_value_looks_like_proc
          __bound_call_for_proc
        elsif __parse_args_for_operation
          __bound_call_for_operation
        end
      end
    end

    def __bound_call_for_operation
      Common_::BoundCall[ nil, @__operation, :execute ]
    end

    def __parse_args_for_operation
      _cls = remove_instance_variable :@_executor
      op = _cls.begin_operation_ @argument_scanner
      @__operation = op
      _ok = op.parse_arguments_for_operation_
      _ok  # #todo
    end

    def __bound_call_for_proc
      Common_::BoundCall[ @argument_scanner, @_executor, :call ]
    end

    def __load_ticket_value_looks_like_proc
      @argument_scanner.advance_one  # (no selection stack here)
      x = remove_instance_variable( :@__load_ticket ).const_value
      @_executor = x
      x.respond_to? :call
    end

    def __resolve_load_ticket

      _ada = Operations_module_operator_branch___[]

      _lt = @argument_scanner.match_branch(
        :business_item, :value, :against_branch, _ada )

      _store :@__load_ticket, _lt
    end

    define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
  end

  Operations_module_operator_branch___ = Lazy_.call do  # c.p/m from [tmx]
    Zerk_::ArgumentScanner::OperatorBranch_VIA_MODULE.define(
      Home_::Operations_
    ) do |defn|
      defn.express_unknown_by do |o|
        o.express_unknown_item_smart_prefixed "unknown operation"
        o.express_via_template "available operations: {{ say_splay }}"
      end
    end
  end
end
# #born: just to make testing easier
