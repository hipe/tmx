# frozen_string_literal: true

module Skylab::Arc

  class Magnetics::QualifiedComponent_via_Value_and_Association

    # #open [#008.D] - could use a modern interface
      # -
        # [#006.A] "the universal component builder" explains everything

        class << self
          def call ma, asc, acs, & p_p
            new( ma, asc, acs, & p_p ).execute
          end
          alias_method :[], :call

          alias_method :begin, :new
          private :new
        end  # >>

        def initialize ma, asc, acs, & pp

          if pp && 1 != pp.arity
            self._WORLDWIDE_PROTEST
          end

          @ACS = acs
          @association = asc
          @construction_method = nil
          @emission_handler_builder = pp
          @mixed_argument = ma
        end

        attr_writer(
          :construction_method,
          :mixed_argument,
        )

        def looks_like_compound_component__

          @_did_prepare_call ||= _prepare_call

          COMPOUND_CONSTRUCTOR_METHOD_ == @_explicit_method_name
        end

        def execute

          @_did_prepare_call ||= _prepare_call

          @_listenerer = if @emission_handler_builder
            @emission_handler_builder
          else
            Home_::Magnetics_::EmissionHandlerBuilder_via_Association_and_ACS[ @association, @ACS ]
          end

          if @_explicit_method_name
            __via_construction_method
          else
            ___via_proc_like_call
          end
        end

        def ___via_proc_like_call
          kn = @_receiver[ @mixed_argument, & @_listenerer ]
          if kn
            kn.to_qualified_known_around @association
          else
            kn
          end
        end

        def _prepare_call

          if @construction_method

            cm = @construction_method
            recvr = @association.component_model

          else
            cx = @association.model_classifications
            if ! cx.looks_primitivesque
              m = cx.construction_method_name
              if m
                cm = m
              else
                raise ::NoMethodError, @association.say_no_method__
              end
            end
            recvr = @association.component_model
          end

          @_receiver = recvr
          @_explicit_method_name = cm

          ACHIEVED_
        end

        def __via_construction_method

          m = @_explicit_method_name

          if ! @_receiver.respond_to? m
            raise ::NameError, ___say_no_method( m )
          end

          d = @_receiver.method( m ).arity
          if 1 < d
            # see construction args [#003.F] "the super signature"
            xtra = []
            if 2 < d
              xtra.push @association
            end
            xtra.push @ACS
          end

          cmp = @_receiver.send m, @mixed_argument, * xtra, & @_listenerer
          if cmp
            Common_::QualifiedKnownKnown[ cmp, @association ]
          else
            cmp
          end
        end

        def ___say_no_method m

          x = @_receiver
          _ = if x.respond_to? :name
            x.name
          else
            "#{ x }"
          end
          # platform reporting of class name is not as helpful as it could be
          "undefined method `#{ m }` for #{ _ }"
        end
      # -

    class Entity_by_Simplicity_via_PersistablePrimitiveNameValuePairStream < Common_::MagneticBySimpleModel

      #   - vaguely 19 months after the start of [arc]
      #   - a simplified alternative
      #   - try to be an upgrade path
      #   - originated to make test code obvious, look like simple models
      #   - in this file because it's anemic, otherwise related
      #   - #coverpoint2.2 is the test (it might one day explain more)

      attr_writer(
        :listener,
        :model_class,
        :persistable_primitive_name_value_pair_stream,
      )

      def execute
        @model_index = ModelIndexBySimplicity_via_ModelClass[ @model_class ]
        extend Entity_via_PersistablePrimitiveNameValuePairStream_and_ModelIndex___
        execute  # careful
      end
    end

    module Entity_via_PersistablePrimitiveNameValuePairStream_and_ModelIndex___

      def execute
        ok = nil
        ent = @model_class.define do |o|
          @_entity = o
          ok = __construct_entity
        end
        ok && ent
      end

      def __construct_entity
        @__type_of = Primitive_type_of___[].method :against_value
        ok = true
        while __next_assignment
          ok = __resolve_association
          ok &&= __convert_and_or_normalize
          ok && __via_normal_value
          ok || break
        end
        ok
      end

      def __via_normal_value
        _x = remove_instance_variable :@__current_normal_value
        @_entity.send @_current_association.writer_method, _x
        NIL
      end

      # -- D:

      def __convert_and_or_normalize

        if @_current_association.has_normalization_method
          if @_current_association.has_type_symbol
            __when_both
          else
            _normalize_against _current_value
          end
        elsif _should_pass_thru_value_as_is
          _accept_normal_value _current_value
        elsif _convert_value_via_target_type
          _accept_normal_value _release_converted_value
        end
      end

      def __when_both  # rough sketch - VERY likely to change, but the
        # general idea is that when we have a custom normalizer method,
        # we don't want to be so liberal in our type induction (i.e from
        # number to string); howver if we don't, we do.

        if _should_pass_thru_value_as_is
          _normalize_against _current_value
        elsif __converting_between_numerics
          if _convert_value_via_target_type
            _normalize_against _release_converted_value
          end
        else
          _nope
        end
      end

      def __converting_between_numerics
        _type_is_numeric( @_existing_type ) && _type_is_numeric( @_target_type )
      end

      def _type_is_numeric sym  # ick/meh
        case sym
        when
          :_non_negative_integer_,
          :_non_negative_float_,

          :_positive_nonzero_integer_,
          :_positive_nonzero_float_,

          :_negative_nonzero_integer_,
          :_negative_nonzero_float_,

          :_zero_as_integer_,
          :_zero_as_float_ ; true
        end
      end

      def _normalize_against x
        kn = @_entity.send @_current_association.normalization_method, x, & @listener
        if kn
          _accept_normal_value kn.value
        end
      end

      def _accept_normal_value x
        @__current_normal_value = x ; true
      end

      # -- C:

      def _should_pass_thru_value_as_is

        existing_type = @__type_of[ _current_value ]
        target_type = @_current_association.type_symbol

        if existing_type == target_type
          # manually: if received type is target type, you're done
          true

        elsif :_nil_ == existing_type
          # manually: if received type is nil, pass it thru. validating requiredness is not in our scope
          true

        else
          @_existing_type = existing_type
          @_target_type = target_type
          false
        end
      end

      def _convert_value_via_target_type

        if :_string_ == @_target_type
          # manually: getting to a string is the same for
          # the 6 categories of number, for the 2 bools, for symbol
          _accept_converted_value _current_value.to_s

        else
          # base the next step around the target type and not the received
          # type, because there's a secret asymmetry: we don't want the
          # definitions to specify these types: nil, the zeros
          send RESOLVE_TYPE_X___.fetch @_target_type
        end
      end

      RESOLVE_TYPE_X___ = {
        _symbol_: :__symbol_via,
        _boolean_: :__boolean_via,
        _non_negative_float_: :__non_negative_float_via,
        _non_negative_integer_: :__non_negative_integer_via,
        _negative_nonzero_float_: :__negative_nonzero_float_via,
        _negative_nonzero_integer_: :__negative_nonzero_integer_via,
        _positive_nonzero_float_: :__positive_nonzero_float_via,
        _positive_nonzero_integer_: :__positive_nonzero_integer_via,
      }

      def __non_negative_float_via
        case @_existing_type
        when :_positive_nonzero_float_, :_zero_as_float_
          _accept_converted_value _current_value
        when :_string_
          _these :_float_via_string, :_must_be_non_negative
        else
          _nope
        end
      end

      def __non_negative_integer_via
        case @_existing_type
        when :_positive_nonzero_integer_, :_zero_as_integer_
          _accept_converted_value _current_value
        when :_string_
          _these :_integer_via_string, :_must_be_non_negative
        else
          _nope
        end
      end

      def __negative_nonzero_float_via
        case @_existing_type
        when :_negative_nonzero_integer_
          _accept_converted_value _current_value.to_f
        when :_string_
          _these :_float_via_string, :_must_be_negative
        else
          _nope
        end
      end

      def __negative_nonzero_integer_via
        case @_existing_type
        when :_string
          _these :_integer_via_string, :_must_be_negative
        else
          _nope
        end
      end

      def __positive_nonzero_float_via
        case @_existing_type
        when :_positive_nonzero_integer_
          _accept_converted_value _current_value.to_f
        when :_string
          _these :_float_via_string, :_must_be_positive
        else
          _nope
        end
      end

      def __positive_nonzero_integer_via
        case @_existing_type
        when :_positive_nonzero_float_
          _accept_converted_value _current_value.to_i
        when :_string
          _these :_integer_via_string, :_must_be_positive
        else
          _nope
        end
      end

      def __boolean_via
        if :_string_ == @_existing_type
          md = /\A(?:(true)|(false))\z/.match _current_value
          if md
            if md.offset[1].first
              _accept_converted_value true
            else
              _accept_converted_value false
            end
          else
            _doesnt_look_like { '"true" or "false"' }
          end
        else
          _nope
        end
      end

      def __symbol_via
        if :_string_ == @_existing_type
          _accept_converted_value _current_value.intern
        else
          _nope
        end
      end

      def _these * m_a
        ok = true
        m_a.each do |m|
          ok = send m
          ok || break
        end
        ok
      end

      def _must_be_non_negative
        _number_must_be { 0 <= @_number }
      end

      def _must_be_negative
        _number_must_be { 0 > @_number }
      end

      def _must_be_positive
        _number_must_be { 0 < @_number }
      end

      def _number_must_be
        if yield
          _accept_converted_value remove_instance_variable :@_number
        else
          loc = caller_locations( 1, 1 )[ 0 ]
          x = _current_value
          @listener.call :error, :expression, :range_error do |y|
            _ = /\A_must_be_(.+)\z/.match( loc.base_label )[ 1 ]
            _human = _.gsub UNDERSCORE_, SPACE_
            y << "must be #{ _human } (had: #{ x })"
          end
          UNABLE_
        end
      end

      def _float_via_string
        if /\A-?\d+(?:\.\d+)?\z/ =~ _current_value
          @_number = _current_value.to_f ; true
        else
          _doesnt_look_like { :float }
        end
      end

      def _integer_via_string
        if /\A-?\d+\z(?:\.0+)?\z/ =~ _current_value
          @_number = _current_value.to_i ; true
        else
          _doesnt_look_like { :integer }
        end
      end

      def _nope
        _doesnt_look_like do
          /\A_(.+)_\z/.match( @_target_type )[1].gsub UNDERSCORE_, SPACE_
        end
      end

      def _doesnt_look_like
        x = _current_value
        @listener.call :error, :expression, :type_error do |y|
          y << "doesn't look like #{ yield }: #{ ick_mixed x }"
        end
        UNABLE_
      end

      def _accept_converted_value x
        @__current_converted_value = x ; true
      end

      def _release_converted_value
        remove_instance_variable :@__current_converted_value
      end

      def _current_value
        @_current_assignment.value
      end

      # -- B:

      def __resolve_association

        _ = @model_index.procure @_current_assignment.name_symbol, & @listener
        _store :@_current_association, _
      end

      def __next_assignment
        qk = @persistable_primitive_name_value_pair_stream.gets
        if qk
          @_current_assignment = qk ; KEEP_PARSING_
        else
          @_current_assignment = nil
          remove_instance_variable :@_current_assignment
          remove_instance_variable :@persistable_primitive_name_value_pair_stream
          STOP_PARSING_
        end
      end

      # -- A: support

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    end

    # ==

    class ModelIndexBySimplicity_via_ModelClass  # ([arc] only. perhaps 1x)

      # (treat this as frozen. rather than using reflection to index
      # everything up-front (annoying for a couple reasons

      class << self

        def call cls
          ivar = THIS_IVAR___
          if cls.instance_variable_defined? ivar
            cls.instance_variable_get ivar
          else
            idx = new cls
            cls.instance_variable_set ivar, idx
            idx
          end
        end

        alias_method :[], :call
        private :new
      end  # >>

      def initialize cls
        @_cache = {}
        @model_class = cls
      end

      def procure name_sym, & p
        asc = @_cache[ name_sym ]
        if asc
          asc
        else
          __lookup p, name_sym
        end
      end

      def __lookup p, name_sym
        asc = Association_by_Simplicity_via_NameSymbol___.call_by do |o|
          o.name_symbol = name_sym
          o.model_index = self
          o.listener = p
        end
        if asc
          @_cache[ name_sym ] = asc
          asc
        end
      end
    end  # (will re-open)

    # ==

    class Association_by_Simplicity_via_NameSymbol___ < Common_::MagneticBySimpleModel

      attr_writer(
        :listener,
        :model_index,
        :name_symbol,
      )

      def execute
        if __writer_method_defined
          __all_the_rest
        end
      end

      def __all_the_rest

        # :#here1: you can define a normalization (n11n) method. you can
        # declare a type explicitly. if you do not declare a type explicitly,
        # we will try to infer a type from the name. experimentally, at least
        # one of these three techniques must be engaged per association, lest
        # we raise an exception.
        #
        #  yes n11n method    yes explicit type    : OK
        #  yes n11n method    yes inferred type    : OK
        #  yes n11n method           -             : OK
        #        -            yes explicit type    : OK
        #        -            yes inferred type    : OK
        #        -                   -             : NOT OK (for now)

        if __has_normalization_method
          if ! _has_explicitly_defined_type
            _infer_type_from_name
          end
        elsif ! _has_explicitly_defined_type
          if ! _infer_type_from_name
            raise Home_::RuntimeError, __say_all_this_stuff
          end
        end

        remove_instance_variable :@listener
        remove_instance_variable :@model_index
        freeze
      end

      def __has_normalization_method
        m = "normalize__#{ @name_symbol }__"
        if @model_index.model_class.method_defined? m
          @has_normalization_method = true
          @normalization_method = m.intern ; true
        end
      end

      def _infer_type_from_name
        md = THIS_RX___.match @name_symbol
        if md
          @has_type_symbol = true
          @type_symbol = THESE__.fetch md[ :type_symbol ] ; true
        end
      end

      def __say_all_this_stuff
        _ = THESE__.keys.map { |s| "_#{ s }" }
        "`#{ @name_symbol }` must end in (#{ _ * '|' }) #{
          }or have an entry in the TYPES hash"
      end

      THESE__ = {
        "string" => :_string_,
        "symbol" => :_symbol_,
      }

      THIS_RX___ = /\A
        .+
        _
        (?<type_symbol>
          string |
          symbol
        )
      \z/x

      def _has_explicitly_defined_type
        type_sym = @model_index.__explicitly_defined_type_ @name_symbol
        if type_sym
          @has_type_symbol = true
          @type_symbol = type_sym ; true
        end
      end

      def __writer_method_defined
        @writer_method = :"#{ @name_symbol }="
        if @model_index.model_class.method_defined? @writer_method
          ACHIEVED_
        else
          __when_extra
        end
      end

      def __when_extra

        sym = @name_symbol

        _use_listener = @listener || Listener_that_raises_exceptions_
          # (for clients that weren't expecting an error here, as a courtesy
          #  let's let them know what the issue is in the form of an exception)

        _use_listener.call :error, :expression, :unrecognized_property do |y|
          y << "unrecognized property #{ ick_prim sym }"
        end

        UNABLE_
      end

      attr_reader(
        :has_normalization_method,
        :has_type_symbol,
        :name_symbol,
        :normalization_method,
        :type_symbol,
        :writer_method,
      )
    end

    # ==

    class ModelIndexBySimplicity_via_ModelClass  # (re-open)

      def __explicitly_defined_type_ name_sym
        send ( @_explicitly_defined_type ||= :__explicitly_defined_type_initially ), name_sym
      end

      def __explicitly_defined_type_initially name_sym

        if @model_class.const_defined? :TYPES

          # :#history-A.2: new in this commit: allow the above to inherit
          # so that you can subclass different implementation variants for
          # models with the same constituency

          h = @model_class.const_get :TYPES
        end
        if h
          @__type_via_name_symbol = h
          @_explicitly_defined_type = :__explicitly_defined_type
        else
          @_explicitly_defined_type = :__MONADIC_EMPTINESS
        end
        send @_explicitly_defined_type, name_sym
      end

      def __explicitly_defined_type name_sym
        @__type_via_name_symbol[ name_sym ]
      end


      attr_reader(
        :model_class,
      )

      def __MONADIC_EMPTINESS _
        NOTHING_
      end
    end

    # ==

    Primitive_type_of___ = Lazy_.call do
      _proto = Home_.lib_.basic::OMNI_TYPE_CLASSIFICATION_HOOK_MESH_PROTOTYPE
      _proto.redefine do |o|
        # ..
        o.replace :string do
          :_string_
        end
        o.add :symbol do
          :_symbol_
        end
        o.add :false do
          :_boolean_
        end
        o.add :true do
          :_boolean_
        end
        o.add :nil do
          :_nil_
        end
        o.add :negative_nonzero_float do
          :_negative_nonzero_float_
        end
        o.add :negative_nonzero_integer do
          :_negative_nonzero_integer_
        end
        o.add :positive_nonzero_float do
          :_positive_nonzero_float_
        end
        o.add :positive_nonzero_integer do
          :_positive_nonzero_integer_
        end
        o.add :zero do |oo|
          if oo.value.respond_to? :bit_length
            :_zero_as_integer_
          else
            :_zero_as_float_
          end
        end
      end
    end

    # ==

    Listener_that_raises_exceptions_ = -> * chan, & em_p do  # #[#co-045]  # #testpoint

      if :error == chan[0]
        if :expression == chan[1]
          _expag = Autoloader_.require_sidesystem( :Zerk )::No_deps[]::API_InterfaceExpressionAgent.instance
          _msg = _expag.calculate ::String.new, & em_p
          raise _msg
        else
          raise em_p[].to_exception
        end
      end
    end

    # ==

    KEEP_PARSING_ = true
    STOP_PARSING_ = nil
    THIS_IVAR___ = :@_associations_index_for_ARC_

    # ==
    # ==
  end
end
# :#history-A.2 (might be temporary): as referenced
# #history-A.1: spike of injection of "by simplified" magnets
