require_relative '../../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] argument scanner - magnetics - flattened .." do

    TS_[ self ]
    use :memoizer_methods

    it 'loads' do
      _subject_magnetic || fail
    end

    context 'no filter' do

      it 'a variety of shape symbols' do
        _symz = _shape_symbols
        _symz == %i(
          OPERATOR_ze
          OPERATOR_ze
          OPERATOR_ze
          OPERATOR_ze
          PRIMARY_ze
        ) || fail
      end

      it 'a variety of injector symbols' do
        _injz = _injector_symbols
        _injz == %i(
          _INJECTION_0_
          _INJECTION_1_
          _INJECTION_1_
          _INJECTION_2_
          _INJECTION_3_
        ) || fail
      end

      it 'a variety of symbolic references' do
        _syms = _symbolic_references
        _syms == %i(
          xx
          xx_yy1
          he_ha
          xx_yy2
          zz
        ) || fail
      end

      it 'a variety of values' do
        p_a = _implications
        a = []
        p_a.each do |p|
          a.push p.call
        end
        a == %i(
          yy
          xxx
          yyy
          zzz
          __parse_zz
        ) || fail
      end

      shared_subject :_N_things do
        __build_N_things
      end

      def _build_subject
        _omni = _same_omni
        _omni.features.TO_FLATTENED_QUALIFIED_FEATURE_SCANNER
      end
    end

    context '(filter by injection symbol)' do

      it 'win' do
        _scn = _build_subject
        _a = Array_via_scanner_[ _scn ]
        _a.map( & :injection_symbol ) == %i(
          _INJECTION_0_
          _INJECTION_3_
        ) || fail
      end

      def _build_subject
        _omni = _same_omni
        _omni.features.TO_FLATTENED_QUALIFIED_FEATURE_SCANNER do |o|
          o.strict_injector_symbol_pass_filter = {
            _INJECTION_0_: true,
            _INJECTION_1_: false,
            _INJECTION_2_: false,
            _INJECTION_3_: true,
          }
        end
      end
    end

    def _shape_symbols
      _N_things.fetch 3
    end

    def _injector_symbols
      _N_things.fetch 2
    end

    def _symbolic_references
      _N_things.fetch 1
    end

    def _implications
      _N_things.fetch 0
    end

    def __build_N_things

      implications = []
      symbolic_references = []
      shape_symbols = []
      injection_symbols = []

      scn = _build_subject

      until scn.no_unparsed_exists

        qfeat = scn.gets_one

        implications.push qfeat.method :value
        shape_symbols.push qfeat.feature_shape_symbol
        injection_symbols.push qfeat.injection_symbol
        symbolic_references.push qfeat.symbolish_reference
      end

      [ implications, symbolic_references, injection_symbols, shape_symbols ]
    end

    def _same_omni
      TS_::No_Dependencies_Zerk::Features_Injections::Frozen_omni_one[]
    end

    def _subject_magnetic
      Home_::ArgumentScanner::Magnetics::FlattenedQualifiedFeatureScanner_via_Injections
    end
  end
end
# #born: during 2nd wave
