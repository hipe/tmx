module Skylab::System

  module Doubles::Stubbed_System

    class Inline_Pool_Based

      def initialize
        @_pool = []
      end

      def _add_entry_by_ & matcher_p
        @_pool.push matcher_p ; nil
      end

      def popen3 * cmd_s_a

        d = nil ; p = nil

        @_pool.length.times do |d_|
          p = @_pool.fetch( d_ ).call cmd_s_a
          if p
            d = d_
            break
          end
        end

        if d
          @_pool[ d, 1 ] = EMPTY_A_

          if @_pool.length.zero?
            remove_instance_variable :@_pool  # for sanity
          end

          Here_::Popen3_Result_via_Proc_.new( & p ).produce
        else
          fail ___say_not_found cmd_s_a
        end
      end

      def ___say_not_found cmd_s_a
        "not found - #{ cmd_s_a.inspect }"
      end
    end
  end
end
