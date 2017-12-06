require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] state-machine - passive" do

    TS_[ self ]
    use :memoizer_methods
    use :want_event

    shared_subject :_state_machine do

      # (an ultra-simplified derivative of the target use-case, [#sy-023.1] diff)

      o = Home_::StateMachine.begin_definition

      o.add_state(
        :beginning,
        :can_transition_to, :first_ever_header,
      )

      header_rx = %r(\A[A-Z])

      o.add_state(
        :first_ever_header,
        :entered_by_regex,  header_rx,
        :on_entry, -> sm do
          sm.downstream.recv_header sm.user_matchdata
          NIL
        end,
        :can_transition_to, :item,
      )

      o.add_state(
        :item,
        :entered_by_regex, %r(\A[a-z]),
        :on_entry, -> sm do
          sm.downstream.recv_item sm.user_matchdata
          NIL
        end,
        :can_transition_to, [ :item, :header_after_item, :my_end ],
      )

      o.add_state(
        :header_after_item,
        :entered_by_regex, header_rx,
        :on_entry, -> sm do
          sm.TURN_PAGE_OVER
          sm.downstream.recv_header sm.user_matchdata
          NIL
        end,
        :can_transition_to, [ :item, :my_end ],
      )

      o.add_state(
        :my_end,
        :entered_by, -> st do
          # (you can enter the 'end' state IFF the upstream is empty)
          st.no_unparsed_exists
        end,
        :on_entry, -> sm do
          sm.receive_end_of_solution_when_paginated
        end,
      )

      class X_sm_pa_Guy
        def initialize
          @__header_mutex = nil
          @items = []
        end
        def recv_header md
          remove_instance_variable :@__header_mutex
          @header = md.string ; nil
        end
        def recv_item md
          @items.push md.string ; nil
        end
        def finish_when_paginated
          @items.freeze
          freeze
        end
        attr_reader(
          :header,
          :items,
        )
      end

      o.finish
    end

    it "builds" do
      _state_machine || fail
    end

    it "normal case (3 sections)" do

      sess = _against 'FOO', 'bar', 'BAZ', 'biffo', 'boffo', 'QUX', 'qizzy'
      _1 = sess.gets
      _1 || fail
      _2 = sess.gets
      _2 || fail
      _3 = sess.gets
      _3 || fail
      _4 = sess.gets
      _4 && fail
      _5 = sess.gets
      _5 && fail

      _1.header == 'FOO' || fail
      _2.header == 'BAZ' || fail
      _3.header == 'QUX' || fail
      _1.items == %w( bar ) || fail
      _2.items == %w( biffo boffo ) || fail
      _3.items == %w( qizzy ) || fail
    end

    def _against * s_a

      _scn = Home_::Scanner_[ s_a ]

      _sess = _state_machine.begin_passive_session_by do |o|

        o.upstream = _scn

        o.downstream_by = -> do
          X_sm_pa_Guy.new
        end
      end
      _sess
    end
  end
end
