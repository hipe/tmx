module Skylab::Brazen

  class Model_

    module Preconditions_

      class << self

        def establish_box * a
          if a.first.length.nonzero?
            if 3 == a.length
              a.push Graph__.new
            end
            Establish_preconditions_box_recursive__.execute_via_arglist a
          end
        end
      end

      class Graph__

        def initialize
          @state_h = {}
          @value_h = {}
        end

        def fetch_value i
          @value_h.fetch i
        end

        def with_state_of identifier, & p
          p[ @state_h.fetch( identifier.full_name_i ) { :none }, self ]
        end

        def change_state_and_associate_value identifier, i, x
          change_state identifier, i
          @value_h[ identifier.full_name_i ] = x ; nil
        end

        def change_state identifier, i
          @state_h[ identifier.full_name_i ] = i ; nil
        end
      end

      class Establish_preconditions_box_recursive__

        Actor_[ self, :properties,
          :identifier_a, :event_receiver, :kernel, :graph ]

        def execute
          ok = true
          @identifier_a.each do |identifier|
            @identifier = identifier
            ok = step
            ok or break
          end
          ok && flush
        end

        def step
          @graph.with_state_of @identifier do |state_i, o|
            case state_i
            when :none
              o.change_state @identifier, :processing
              @g = o
              process
            when :processing
              when_processing
            when :OK
              PROCEDE_
            end
          end
        end

        def when_processing
          _ev = build_not_OK_event_with :cyclic_dependency_in_precondition_graph,
            :model_name, @identifier.full_name_i
          @event_receiver.receive_event _ev
          UNABLE_
        end

        def process
          ok = rslv_cols_via_identifier
          ok &&= rslv_ctlr_via_identifier_and_cols
          ok && via_ctlr
        end

        def rslv_cols_via_identifier
          @cols = @kernel.collections_via_identifier @identifier, @event_receiver
          @cols ? PROCEDE_ : @cols
        end

        def rslv_ctlr_via_identifier_and_cols
          @ctlr = @cols.produce_controller_as_precondition_via_id_and_graph @identifier, @graph, @event_receiver
          @ctlr ? PROCEDE_ : @ctlr
        end

        def via_ctlr
          @g.change_state_and_associate_value @identifier, :OK, @ctlr
          PROCEDE_
        end

        def flush
          bx = Box_.new
          @identifier_a.each do |id|
            bx.add id.full_name_i, @graph.fetch_value( id.full_name_i )
          end
          bx
        end
      end
    end
  end
end
