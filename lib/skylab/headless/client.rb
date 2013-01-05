module Skylab::Headless

  module Client
  end

  module Client::InstanceMethods
    include Headless::SubClient::InstanceMethods

  protected

    def initialize                # (remember this is the base module for those
                                  # clients that fall all the way back to this
                                  # and as such it must be modality-agnostic
                                  # here. anything fancy belongs elsewhere.)
      _headless_sub_client_init! nil                      # (part of [#hl-004])
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
      @io_adapter ||= build_io_adapter
    end

    attr_writer :io_adapter       # e.g. from tests

    def pen                       # bound to sub-client (#sc-bound)
      io_adapter.pen
    end

    def request_client
      fail 'sanity - buck stops here' # makes nasty bugs easier to find
    end
  end

  IGNORE_THIS_CONSTANT = /\A#{to_s}\b/ # #todo
end
