module Skylab::TMX

  class API

    # this has to be able to regress (A) and (B) there's custom syntax
    # to parse. because why not, we have no long-running process, just
    # a shortlived request client.

    class << self

      def call * x_a, & p
        bc = invocation_via_argument_array( x_a, & p ).to_bound_call_of_operator
        bc and bc.receiver.send bc.method_name, * bc.args, & bc.block
      end

      def invocation_via_argument_array x_a, & p
        o = self.begin( & p )
        # (below while #open [#ze-068])
        o.argument_scanner_narrator = Zerk_lib_[]::API::ArgumentScanner.via_array x_a, & p
        o
      end

      def to_didactic_operation_name_stream__
        To_didactic_operation_name_stream__[]
      end

      alias_method :begin, :new
      undef_method :new
    end  # >>

    # -

      def initialize & p
        @_emit = p
      end

      attr_writer(
        :argument_scanner_narrator,
      )

      def execute
        bc = to_bound_call_of_operator
        bc and bc.receiver.send bc.method_name, * bc.args, & bc.block
      end

#==FROM (experimental use of a [#ze-051])

      def to_bound_call_of_operator

        _ada = Operations_module_feature_branch___[]

        item = @argument_scanner_narrator.match_branch(
          :business_item, :against_branch, _ada )

        if item
          __when_operation_found item
        else
          item
        end
      end

      Operations_module_feature_branch___ = Lazy_.call do

        Zerk_::ArgumentScanner::FeatureBranch_via_AutoloaderizedModule.define do |o|

          o.module = Home_::Operations_

          o.express_unknown_by do |oo|
            oo.express_unknown_item_smart_prefixed "unknown operation"
            oo.express_via_template "available operations: {{ say_splay }}"
          end

          o.sub_branch_const = :Actions
        end
      end
#==TO

      def __when_operation_found branch_item

        # branch_item.branch_item_normal_symbol  # => normal symbol

        o = branch_item.branch_item_value

        name = Common_::Name.via_slug o.asset_reference.entry_group_head

        _const = name.as_camelcase_const_string

        _operation_class = o.module.const_get _const, false

        o = nil

        nar = @argument_scanner_narrator

        op = _operation_class.begin( & @_emit )

        op.argument_scanner_narrator = nar

        @_emit.call :data, :operator_resolved do |fr|

          fr.name = name
          fr.argument_scanner_narrator = nar
          fr.operator_instance = op

          fr.define_didactics_by do |dida|
            Zerk_::Models::Didactics.define_conventionaly dida, op
          end
        end

        @argument_scanner_narrator.advance_one

        Common_::BoundCall[ nil, op, :execute ]
      end

      def _parse_error_listener
        @_emit || Parse_error_listener___
      end

      attr_reader(
        :operation_session,
      )
    # -

    # ==

    # ==

    Parse_error_listener___ = -> *, & expression_p do

      buffer = nil

      p = -> line0 do
        buffer = line
        p = -> line1 do
          buffer = line1.dup
          last_line = line0
          punct_rx = /[-.?!]\z/
          p = -> line do
            if punct_rx !~ last_line
              buffer << DOT_
            end
            last_line = line
            buffer << " #{ line }"
          end
          p[ line1 ]
        end
      end

      _y = ::Enumerator::Yielder.new do |line|
        p[ line ]
      end

      Zerk_lib_[]::API::ArgumentScannerExpressionAgent.instance.
        calculate _y, & exp_p

      raise ArgumentError, buffer
    end

    ArgumentError = ::Class.new ::ArgumentError

    # ==
  end
end
# #history: born for "map" operation
