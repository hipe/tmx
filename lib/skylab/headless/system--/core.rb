module Skylab::Headless

  module System__  # read [#140] #section-1

    class Front  # read [#140] #section-2 introduction to the front client

      def initialize
        @mod = System__::Services__
        @svc_i_a = []
        @svc_h = {}

        use_name = ::Hash.new { |h, k| k }
        use_name[ :io ] = :IO  # hard-coded name changes meh

        @mod.entry_tree.to_scan.each do | normpath |
          name_i = use_name[ normpath.name.as_variegated_symbol ]
          @svc_i_a.push name_i
          define_singleton_method name_i, bld_reader_method_via_variegated_name_i( name_i )
        end
      end

      def members
        @svc_i_a.dup
      end

    private

      def bld_reader_method_via_variegated_name_i name_i

        -> * x_a do
          front = @svc_h.fetch name_i do
            @svc_h[ name_i ] = bld_any_service_by_variegated_name_i name_i
          end
          if x_a.length.zero?
            front
          elsif front
            front.call( * x_a )
          else
            raise ::SystemCallError, say_system_not_available( name_i )  # #note-40
          end
        end
      end

      def bld_any_service_by_variegated_name_i name_i
        name = Callback_::Name.via_variegated_symbol name_i
          # yes make a second name object, this one has the corrected name
        cls = System__::Services__.const_get name.as_const, false
        if cls.instance_method( :initialize ).arity.zero?
          cls.new
        else
          cls.new self
        end
      end

      def say_system_not_available name_i
        "system not available - '#{ name_i }'"
      end
    end

    PROCEDE_ = true
    UNABLE_ = false

  end
end
