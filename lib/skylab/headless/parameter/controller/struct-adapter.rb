module Skylab::Headless
  module Parameter::Controller::StructAdapter
  # an experimental that asks:  what if you want your parameter superset
  # defined only by a ::Struct?  There can be no superset definitions of
  # specific parameters.  Merely it is that each member of the struct is
  # a required parameter (and it follows that no actual parameters could
  # be added that are not in the parameter superset, which is the point)

    def self.extended struct_class
      struct_class.class_eval do
        extend Parameter::Definer::ModuleMethods
        include Parameter::Controller::StructAdapter::InstanceMethods
        members.each { |m| param(m, required: true) }
      end
    end
  end

  module Parameter::Controller::StructAdapter::InstanceMethods
    include SubClient::InstanceMethods
    include Parameter::Controller::InstanceMethods
  protected
    def error msg
      emit(:error, msg)
      self.errors_count += 1
      false
    end
    def errors_count ; @errors_count ||= 0 end
    attr_writer :errors_count
    def formal_parameters ; self.class.parameters end
    def params ; self end # for compat. with set!
  end
end
