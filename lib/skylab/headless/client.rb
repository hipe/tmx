module Skylab::Headless

  module Client

    class << self

      def [] mod, * x_a
        edit_module_via_iambic mod, x_a
      end

      def edit_module_via_iambic mod, x_a

        x_a.length.zero? and raise ::ArgumentError, "cherry-picking only"

        Bundles.edit_module_via_iambic mod, x_a

        NIL_
      end
    end

    module Bundles

      Client_services = -> x_a do
        module_exec x_a, & Home_::Client_Services.to_proc ; nil
      end

      Home_.lib_.bundle::Multiset[ self ]
    end
  end

  module Client::InstanceMethods

    include Home_::SubClient::InstanceMethods

  private

    def initialize
      super  # "top-clients" (albeit "local" ones per
        # [#br-098] "turtles) never "see" any superclient they may have
    end

    def actual_parameters         # not all stacks use this. #sc-bound
    end                           # override it as you please.

    def build_pen
      pen_class.new
    end

    def call_digraph_listeners type, *payload       # bound to sub-client (#sc-bound)
      io_adapter.call_digraph_listeners type, *payload
    end

    def infer_valid_action_names_from_public_instance_methods  # not:[#017]
      a = [] ; _a = self.class.ancestors ; m = nil
      a << m if IGNORE_THIS_CONSTANT !~ m.to_s until ::Object == (m = _a.shift)
      a.map { |_m| _m.public_instance_methods false }.flatten
    end

    def io_adapter                # bound to sub-client (#sc-bound)
      @IO_adapter ||= build_IO_adapter
    end

    def io_adapter= x
      @IO_adapter = x             # e.g from tests
    end

    def pen                       # bound to sub-client (#sc-bound)
      io_adapter.pen
    end
  end

  IGNORE_THIS_CONSTANT = /\A#{to_s}\b/ # #todo
end
