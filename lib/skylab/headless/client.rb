module Skylab::Headless

  module Client
  end


  module Client::InstanceMethods
    include Headless::SubClient::InstanceMethods

  protected

    def initialize # override parent-child type constructor from s.c. [#004]
    end            # because a true 'client' is usually at some kind of root

    def actual_parameters         # not all stacks use this. #sc-bound
    end                           # override it as you please.

    def build_pen
      pen_class.new
    end

    def emit type, *payload       # bound to sub-client (#sc-bound)
      io_adapter.emit type, *payload
    end

    def error s                   # bound to sub-client (#sc-bound)
      emit :error, s              # this does *not* increment a counter [#006]
      false                       # *very* conventional to result in false!
    end

    def infer_valid_action_names_from_public_instance_methods # [#017]
      a = [] ; _a = self.class.ancestors ; m = nil
      a << m if IGNORE_THIS_CONSTANT !~ m.to_s until ::Object == (m = _a.shift)
      a.map { |_m| _m.public_instance_methods false }.flatten
    end

    def info s                    # bound to sub-client (#sc-bound)
      emit :info, s
      nil                         # result is undefined
    end

    def io_adapter                # bound to sub-client (#sc-bound)
      @io_adapter ||= build_io_adapter
    end

    attr_writer :io_adapter       # e.g. from tests

    def pen                       # bound to sub-client (#sc-bound)
      io_adapter.pen
    end

    def request_runtime # rename at [#005]
      fail 'sanity - buck stops here' # makes nasty bugs easier to find
    end

    alias_method :request_client, :request_runtime # away at [#005]

  end
  IGNORE_THIS_CONSTANT = /\A#{to_s}\b/ # #todo
end
