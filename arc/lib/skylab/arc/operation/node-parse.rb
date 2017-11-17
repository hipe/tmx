module Skylab::Arc

  module Operation

    class Node_Parse

      # required reading: [#015]

      class << self
        alias_method :begin_via_these__, :new
        private :new
      end  # >>

      def initialize stack, stream
        @stack = stack
        @stream = stream
      end

      def build_frame_by & p
        @build_frame = p ; nil
      end

      attr_writer(
        :stop_if,
      )

      def execute

        st = @stream
        stop_if = @stop_if  # || MONADIC_EMPTINESS_

        begin

          if st.no_unparsed_exists
            break
          end

          rw = @stack.last.reader_writer

          asc = rw.read_association st.head_as_is

          if ! asc
            break
          end

          _stop_now = stop_if[ asc ]
          if _stop_now
            break
          end

          if ! asc.model_classifications.looks_compound
            break
          end

          o = Home_::Magnetics::TouchComponent_via_Association_and_FeatureBranch.new
          o.component_association = asc
          o.reader_writer = rw
          qk = o.execute

          _f = @build_frame[ qk ]
          @stack.push _f
          st.advance_one  # always in lockstep with a stack push

          redo
        end while nil

        NIL_
      end
    end
  end
end
