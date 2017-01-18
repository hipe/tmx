module Skylab::Zerk

  module ArgumentScanner

    class Magnetics::PrimaryValue_via_ParseRequest < Common_::Dyadic  # 1x

      # (for now [#007.D] tracks both this node and one API point in it below)

      # -
        def initialize as, req
          @argument_scanner = as
          @normalization_chain = req.normalization_chain
          @use_method = req.use_method
        end

        def execute
          if @argument_scanner.no_unparsed_exists
            __when_argument_value_not_provided
          else
            __when_argument_is_provided
          end
        end

        def __when_argument_value_not_provided
          Here_::When::Argument_value_not_provided[ @argument_scanner ]
        end

        def __when_argument_is_provided

          a = remove_instance_variable :@normalization_chain
          if a
            __via_normalization_chain a
          else
            # if an argument is provided and there is no norm chain, any.
            x = _head_as_is_or_should_be
            @argument_scanner.advance_one
            Common_::Known_Known[ x ]
          end
        end

        def __via_normalization_chain a

          x = _head_as_is_or_should_be
          scn = Common_::Scanner.via_array a
          begin
            _p = scn.head_as_is
            x = _p[ x, self ]
            x || break
            scn.advance_one
            if scn.no_unparsed_exists
              @argument_scanner.advance_one
              break
            end
            redo
          end while above
          x
        end

        def _head_as_is_or_should_be
          if @use_method
            @argument_scanner.send @use_method
          else
            @argument_scanner.head_as_is
          end
        end

        # -- for now,
        #    services for client ARE the subject, AND
        #    we don't bother making a new instance per call

        def receive_current_meta_primary_symbol__ sym
          @current_meta_primary_symbol__ = sym ; nil
        end

        def primary_parse_error reason_sym, & expression_p
          _error_expression :primary_parse_error, reason_sym, expression_p
        end

        def operator_parse_error reason_sym, & expression_p
          _error_expression :operator_parse_error, reason_sym, expression_p
        end

        def parse_error reason_sym, & expression_p
          _error_expression :parse_error, reason_sym, expression_p
        end

        def _error_expression error_sym, reason_sym, expression_p

          @argument_scanner.listener.call(
            :error, :expression, error_sym, reason_sym
          ) do |y|
            instance_exec y, & expression_p
          end

          UNABLE_
        end

        def subject_moniker
          sym = @argument_scanner.current_primary_symbol
          if sym
            # we kind of hate this, but
            _expag = @argument_scanner.expression_agent  # :[#007.D]
            _s = _expag.prim sym
            _s  # #todo
          end
        end

        attr_reader(
          :argument_scanner,
          :current_meta_primary_symbol__,
        )
      # -

      # ==

      # ==
    end
  end
end
# #history: broke out of core magnetics file
