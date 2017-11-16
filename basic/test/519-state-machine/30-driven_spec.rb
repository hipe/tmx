require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] state-machine - driven" do

    TS_[ self ]
    use :memoizer_methods
    use :want_event

    it "builds" do
      _state_machine || fail
    end

    blank = '-'
    item = 'who hah'

    it "MONEY ONEY" do

      result = []
      sm = _state_machine

      dvn = sm.begin_driven_session_by do |o|
        o.page_listener = -> page do
          result.push page ; nil
        end
        o.downstream_by = -> do
          X_sm_dvn_Section.new
        end
      end
      dvn.puts blank
      dvn.puts blank
      dvn.puts item
      dvn.puts "ingfish:"
      dvn.puts item
      dvn.puts 'item2'
      dvn.puts 'wingfish:'
      dvn.close

      2 == result.length || fail
      o = result.first
      o.header == 'ingfish' || fail
      o.items == ["who hah", "item2"] || fail
      o = result.last
      o.header == 'wingfish' || fail
      o.items.length == 0 || fail
    end

    shared_subject :_state_machine do

      o = Home_::StateMachine.begin_definition

      o.add_state(
        :beginning,
        :can_transition_to, [ :blank_at_beginning, :section, :line_at_beginning ],
      )
      blank_rx = /\A-\z/
      section_rx = /\A[^:]+(?=:\z)/
      line_rx = /\A[^:]{2,}\z/

      o.add_state(
        :blank_at_beginning,
        :entered_by_regex, blank_rx,
        :on_entry, -> sm do
          :beginning
        end
      )
      o.add_state(
        :line_at_beginning,
        :entered_by_regex, line_rx,
        :on_entry, -> sm do
          :beginning
        end
      )
      same = [ :line_of_section, :blank_of_section, :section ]
      o.add_state(
        :section,
        :entered_by_regex, section_rx,
        :on_entry, -> sm do
          sm.send_any_previous_and_reinit_downstream
          sm.downstream.receive_header sm.user_matchdata
          NIL
        end,
        :can_transition_to, same,
      )
      o.add_state(
        :line_of_section,
        :entered_by_regex, line_rx,
        :on_entry, -> sm do
          sm.downstream.receive_line sm.user_matchdata
          NIL
        end,
        :can_transition_to, same,
      )
      o.add_state(
        :blank_of_section,
        :entered_by_regex, blank_rx,
        :can_transition_to, same,
      )

      class X_sm_dvn_Section
        def initialize
          @__header_mutex = nil
          @items = []
        end
        def receive_header md
          remove_instance_variable :@__header_mutex
          @header = md[0] ; nil
        end
        def receive_line md
          @items.push md.string ; nil
        end
        def finish
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
  end
end
