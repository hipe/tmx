module Skylab::Headless
  module Parameter::Controller::StructAdapter
  # an experimental that asks:  what if you want your parameter superset
  # defined only by a ::Struct?  There can be no superset definitions of
  # specific parameters.  Merely it is that each member of the struct is
  # a required parameter (and it follows that no actual parameters could
  # be added that are not in the parameter superset, which is the point)

    def self.extended struct_class # looks like [#sl-111] but has more
      struct_class.class_eval do
        extend Parameter::Definer # gets m.m and appropriate i.m
        include Parameter::Controller::StructAdapter::InstanceMethods

        members.each { |m| param m, required: true }

      end
    end
  end

  module Parameter::Controller::StructAdapter::InstanceMethods
    include Parameter::Controller::InstanceMethods

    def invoke param_h
      res = nil
      begin
        res = set!( param_h ) or break
        res = execute
      end while nil
      res
    end
  end
end
