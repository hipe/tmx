require_relative '../../test-support'

module Skylab::Arc::TestSupport

  describe '[ac] git config magnetics - unit of work stream via capsulization' do

    TS_[ self ]
    use :memoizer_methods
    use :git_config_magnetics

    it 'loads' do
      magnet_500_ || fail
    end

    it 'add a component to the head of a cluster' do  # #coverpoint3.1

      st = _UoW_stream(
        number_of_components: 3,
        associated_component_offsets: [ 1, 2 ],  # component offset 0 not shown because not associated (is added)
        reallocation_schematic: [
          [
            [ :_static_associated__associated_offset_, 0 ],
            [ :_static_associated__associated_offset_, 1 ],
          ]
        ],
      )

      _1 = st.gets
      _2 = st.gets
      _3 = st.gets
      _4 = st.gets
      _quick_and_dirty 3, _1, _2, _3, _4
    end

    it 'add a component to the tail of a cluster' do  # #coverpoint3.2

      st = _UoW_stream(
        number_of_components: 2,
        associated_component_offsets: [ 0 ],
        reallocation_schematic: [
          [
            [ :_static_associated__associated_offset_, 0 ],
          ]
        ],
      )

      _1 = st.gets
      _2 = st.gets
      _3 = st.gets
      _4 = st.gets
      _quick_and_dirty 2, _1, _2, _3, _4
    end

    it 'add a component to the middle of a cluster' do  # #coverpoint3.3

      st = _UoW_stream(
        number_of_components: 4,
        associated_component_offsets: [ 0, 3 ],
        reallocation_schematic: [
          [
            [ :_static_associated__associated_offset_, 0 ],
            [ :_static_associated__associated_offset_, 1 ],
          ]
        ],
      )

      _1 = st.gets
      _2 = st.gets
      _3 = st.gets
      _4 = st.gets
      _quick_and_dirty 4, _1, _2, _3, _4
    end

    def _quick_and_dirty exp_num_components, * uow_a
      _stream_again = Home_::Stream_[ uow_a ]
      want_squential_component_offsets_are_represented_ _stream_again, exp_num_components
    end

    alias_method :_UoW_stream, :unit_of_work_stream_via_spoof_

    # ==
    # ==
  end
end
# #born.
