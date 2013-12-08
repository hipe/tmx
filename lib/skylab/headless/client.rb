module Skylab::Headless

  module Client

    def self.[] mod, * x_a
      x_a.length.zero? and raise ::ArgumentError, "cherry-picking only"
      Bundles.apply_iambic_on_client x_a, mod ; nil
    end

    module Bundles
      Client_services = -> x_a do
        module_exec x_a, & Client_Services.to_proc ; nil
      end
      MetaHell::Bundle::Multiset[ self ]
    end
  end

  module Client::InstanceMethods

    include Headless::SubClient::InstanceMethods

  private

    def initialize
      super  # #transitional #todo
    end

    def actual_parameters         # not all stacks use this. #sc-bound
    end                           # override it as you please.

    def build_pen
      pen_class.new
    end

    def emit type, *payload       # bound to sub-client (#sc-bound)
      io_adapter.emit type, *payload
    end

    def infer_valid_action_names_from_public_instance_methods # [#017]
      a = [] ; _a = self.class.ancestors ; m = nil
      a << m if IGNORE_THIS_CONSTANT !~ m.to_s until ::Object == (m = _a.shift)
      a.map { |_m| _m.public_instance_methods false }.flatten
    end

    def io_adapter                # bound to sub-client (#sc-bound)
      @io_adapter ||= build_IO_adapter
    end

    def io_adapter= x
      @io_adapter = x             # e.g from tests
    end

    def pen                       # bound to sub-client (#sc-bound)
      io_adapter.pen
    end
  end

  IGNORE_THIS_CONSTANT = /\A#{to_s}\b/ # #todo
end
