module Skylab::SubTree

  class API::Actions::Cov

    class Actors__::Build_list_behavior

      # this actor resolves a valid "behavior plan", the process of which
      # is an encapsulation of resolving that the arguments express or imply
      # a valid combination of the the mutually exclusive, ancillary
      # listing behaviors as well as the auxiliary (and not mutually exclusive)
      # optional behavioral flourishes that these operations may variously
      # exhibit along the way.

      Callback_::Actor.call self, :properties,
        :hubs,
        :argument_symbol_list,
        :on_event_selectively

      SubTree_.lib_.event_lib.selective_builder_sender_receiver self

      def execute
        ok = normalize
        ok && flush
      end

    private

      def normalize
        resolve_three_boxes
        ok = via_three_boxes_send
        ok and resolve_mutex_value_and_union
      end

      def resolve_three_boxes
        @mutex, @union, @unrec = 3.times.map { Self_Rendering_Box__.new }
        @argument_symbol_list.each do |i|
          case i
          when :code
            @union.touch :code_tree
          when :ct, :tc
            @union.touch :code_tree
            @union.touch :test_tree
          when :list, :test_tree_shallow
            @mutex.touch i
          when :test
            @union.touch :test_tree
          else
            @unrec.touch i
          end
        end ; nil
      end

      def via_three_boxes_send
        @ok = true

        if @mutex.length.nonzero?
          if @union.length.nonzero?
            bork Unsupported__, @mutex, @union
          end

          if 1 < @mutex.length
            bork Many_Mutex__, @mutex
          end
        end

        if @unrec.length.nonzero?
          bork Some_Unrec__, @unrec
        end

        x = @ok ; @ok = nil ; x
      end

      Many_Mutex__ = Message_.new do |box|
        "#{ box.render_a * ' and ' } are mutually exclusive - #{
          }chose one or the other"
      end

      Unsupported__ = Message_.new do |mutex_bx, union_bx|
        "#{ mutex_bx.render_a * ' and ' } #{
          }cannot be used with #{ union_bx.render_a * ' and ' }"
      end

      Some_Unrec__ = Message_.new do |box|
        "unrecognized list/tree option(s) - #{ box.render }"
      end

      def resolve_mutex_value_and_union
        if @mutex.length.zero?
          @mutex_value = nil
          if @union.length.zero?
            @union = nil
          end
        else
          @mutex_value = @mutex.values.first
          @union = nil
        end
        ACHIEVED_
      end

      def bork mcls, * a
        @ok = false
        maybe_send_event :error, :bork do
          mcls.build_via_arglist( a ).to_event
        end
        nil
      end

      def flush
        List_Behavior__.new @union, @mutex_value, @hubs, @on_event_selectively
      end

      class List_Behavior__

        SubTree_.lib_.event_lib.selective_builder_sender_receiver self

        def initialize * a
          @union, @special_format_symbol, @hubs, @on_event_selectively = a
        end

        attr_reader :special_format_symbol

        def do_list_tree_for i
          @union and @union.has? i
        end

        def resolve_and_send_events
          hub_a = @hubs
          grand_total = 0
          hub_a.each do |hub|
            count = 0
            maybe_send_event :info, :hub_point do
              Hub_Point__[ hub, @special_format_symbol ]
            end
            hub._local_test_pathname_a.each do |ltpn|
              count += 1
              maybe_send_event :info, :test_file do
                Test_File__[ ltpn, hub, @special_format_symbol ]
              end
            end
            maybe_send_event :info, :number_of_test_files_in_hub do
              Number_of_Test_Files__[ count, :in_hub ]
            end
            grand_total += count
          end
          maybe_send_event :info, :number_of_test_files_total do
            Number_of_Test_Files__[ grand_total, :grand_total ]
          end
          nil
        end
      end

      Hub_Point__ = Data_Event_.new :hub, :list_as

      Number_of_Test_Files__ = Data_Event_.new :count, :scope_symbol

      Test_File__ = Data_Event_.new :short_pathname, :hub, :list_as

      class Self_Rendering_Box__ < LIB_.box_class

        def render
          case 1 <=> length
          when 0
            rndr_value @h.fetch( @a.first )  # while #open [#ba-039]
          when -1
            "(#{ render_a * ', ' })"
          end
        end

        def render_a
          values.map do |x|
            rndr_value x
          end
        end

      private

        def rndr_value x
          "'#{ x }'"
        end
      end
    end
  end
end
