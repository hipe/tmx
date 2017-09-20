module Skylab::Zerk

  module ArgumentScanner

    class Magnetics::FlattenedQualifiedFeatureScanner_via_Injections < Common_::MagneticBySimpleModel

      # features are in injections, and in the main code we hard code the
      # traversal of each injection to traverse each feature. here we abtract
      # the injections away so you can see it as a "flat" stream (scanner)
      # of features.
      #
      # each feature is "qualified" (wrapped) to reflection information about
      # the injection is is from, as well as other meta information.

      # -

        def initialize
          @__mutex_for_execution_mode = nil
          @_execute = :__execute_by_doing_all
          super
        end

        def strict_injector_symbol_pass_filter= h
          _will_execute :__execute_using_strict_injector_symbol_pass_filter
          @strict_injector_symbol_pass_filter = h
        end

        def INJECTION_PASS_FILTER_BY & p  # [tmx]
          _will_execute :__execute_using_injection_pass_filter
          @injection_pass_filter = p ; nil
        end

        def _will_execute m
          remove_instance_variable :@__mutex_for_execution_mode
          @_execute = m ; nil
        end

        attr_writer(
          :injections,
        )

        def execute
          send @_execute
        end

        # --

        def __execute_using_strict_injector_symbol_pass_filter

          _h = remove_instance_variable :@strict_injector_symbol_pass_filter
          pool = _h.dup

          a = _reduce do |inj_ref|
            _inj = inj_ref.injection  # #open #wish [#069]
            k = _inj.injection_symbol
            yes = pool.fetch k
            pool.delete k
            yes
          end

          pool.length.nonzero? and self._COVER_ME__you_forgot_some__  # or not

          _flush a
        end

        def __execute_using_injection_pass_filter
          p = remove_instance_variable :@injection_pass_filter
          _a = _reduce do |inj_ref|
            p[ inj_ref ]  # hi.
          end
          _flush _a
        end

        def _reduce
          a = nil
          _for_each_feature_type_that_has_some_injections do |my_type, aa|
            aaa = nil
            aa.each do |inj_ref|
              _yes = yield inj_ref
              _yes || next
              ( aaa ||= [] ).push inj_ref
            end
            aaa || next
            ( a ||= [] ).push [ my_type, aaa ]
          end
          a
        end

        def __execute_by_doing_all
          a = []
          _for_each_feature_type_that_has_some_injections do |*two|
            a.push two
          end
          _flush a
        end

        def _for_each_feature_type_that_has_some_injections

          if @injections.has_operators
            yield :_ops_, @injections.operators_injections
          end
          if @injections.has_primaries
            yield :_prims_, @injections.primaries_injections
          end
          NIL
        end

        def _flush a
          case 1 <=> a.length
          when -1 ; __expand a
          when  0 ; _scanner_for_features( * a[0] )
          else    ; self._COVER_ME__none__
          end
        end

        def __expand a
          _scn = ::NoDependenciesZerk::Scanner_via_Array.new a
          _scn.expand_by do |(sym, injs)|
            _scanner_for_features sym, injs
          end
        end

        def _scanner_for_features which, injs

          shape_sym = FEATURE_SHAPE_SYMBOLS___.fetch which

          ::NoDependenciesZerk::Scanner_via_Array.new( injs ).expand_by do |features_inj_ref|

            features_inj = features_inj_ref.injection

            injection_sym = features_inj.injection_symbol

            loader = features_inj.method :dereference

            features_inj.to_symbolish_reference_scanner.map_by do |ref|

              QualifiedFeature___.new ref, loader, injection_sym, shape_sym
            end
          end
        end
      # -

      # ==

      class QualifiedFeature___

        def initialize ref, loader, injection_sym, shape_sym
          @symbolish_reference = ref
          @__loader = loader
          @value = :__value_initially
          @injection_symbol = injection_sym
          @feature_shape_symbol = shape_sym
        end

        def value
          send @value
        end

        def __value_initially
          @value = :__cached_value
          @__cached_value = remove_instance_variable( :@__loader )[ @symbolish_reference ]
          freeze
          send @value
        end

        def __cached_value
          @__cached_value  # hi.
        end

        attr_reader(
          :injection_symbol,
          :symbolish_reference,
          :feature_shape_symbol,
        )
      end

      # ==

      FEATURE_SHAPE_SYMBOLS___ = {
        _ops_: :OPERATOR_ze,
        _prims_: :PRIMARY_ze,
      }

      # ==
      # ==
    end
  end
end
# #broke-out of "no dependencies zerk" during 2nd wave
