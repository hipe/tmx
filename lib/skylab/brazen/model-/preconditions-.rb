module Skylab::Brazen

  class Model_

    module Preconditions_

      class << self

        def establish_box_with * x_a
          Resolution__.call_via_iambic x_a
        end
      end

      class Graph

        def initialize action, kernel, & oes_p
          @action = action
          @matrix_h = ::Hash.new do |h, k|
            h[ k ] = ::Hash.new { |h_, k_| h_[ k_ ] = Node__.new }
          end
          @on_event_selectively = oes_p
          @kernel = kernel
        end

        attr_reader :action

        def touch lvl_i, id, silo
          node = @matrix_h[ id.full_name_i ][ lvl_i ]
          case node.state_i
          when :OK
            node.value_x
          when :none
            # touches do not change state, work does..
            x = silo.send :"provide_#{ lvl_i }", id, self, & @on_event_selectively
            if x
              if :none == node.state_i  # just kidding
                node.state_i = :OK
                node.value_x = x
              end
            end
            x
          else
            self._STATE_FAIL
          end
        end

        def work is_self_p, lvl_i, id  # assumes state 'none'
          silo = @kernel.silo_via_identifier id, & @on_event_selectively
          silo and begin
            node = @matrix_h[ id.full_name_i ][ lvl_i ]
            if is_self_p
              x = is_self_p[ id, self, silo ]
              if x
                # what is returned when self is relied upon,
                # do not cache for others to use
                node.self_value_x = x
                PROCEDE_
              else
                node.state_i = :NG
                x
              end
            else
              node.state_i = :processing
              x = silo.send :"provide_#{ lvl_i }", id, self, & @on_event_selectively
              if x
                node.state_i = :OK
                node.value_x = x
                PROCEDE_
              else
                node.state_i = :NG
                x
              end
            end
          end
        end

        def read_state lvl_i, id
          @matrix_h[ id.full_name_i ][ lvl_i ].state_i
        end

        def fetch_value lvl_i, id
          node = @matrix_h.fetch( id.full_name_i ).fetch( lvl_i )
          node.value_x || node.self_value_x
        end

        class Node__
          def initialize
            @state_i = :none
          end
          attr_accessor :state_i
          attr_accessor :value_x, :self_value_x
        end
      end

      class Resolution__

        Actor_[ self, :properties,
          :self_identifier,
          :identifier_a,
          :on_self_reliance,
          :graph,
          :level_i,
          :on_event_selectively ]

        def execute

          if @identifier_a.length.nonzero?
            @self_full_name_i = @self_identifier.full_name_i
            step_on_each_identifier
          end
        end

      private

        def step_on_each_identifier
          ok = true
          @identifier_a.each do |id|
            @id = id
            ok = step
            ok or break
          end
          ok && flush
        end

        def step
          state_i = @graph.read_state @level_i, @id
          case state_i

          when :none
            work

          when :processing
            raise "cyclic: #{ @level_i } #{ @id.full_name_i }"
            when_processing

          when :OK
            PROCEDE_

          else
            self._NEVER

          end
        end

        def when_processing
          @on_event_selectively.call :error, :cyclic_dependency_in_precondition_graph do
            bld_cyclic_dependency_in_precondition_graph_event
          end
          UNABLE_
        end

        def bld_cyclic_dependency_in_precondition_graph_event
          build_not_OK_event_with :cyclic_dependency_in_precondition_graph,
            :model_name, @id.full_name_i
        end

        def work
          if @self_full_name_i == @id.full_name_i
            @graph.work @on_self_reliance, @level_i, @id
          else
            @graph.work nil, @level_i, @id
          end
        end

        def flush
          bx = Box_.new
          @identifier_a.each do |id|
            bx.add id.full_name_i, @graph.fetch_value( @level_i, id )
          end
          bx
        end
      end
    end
  end
end
