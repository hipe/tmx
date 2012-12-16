module Skylab::Headless
  module Parameter::Controller::InstanceMethods
    include Headless::SubClient::InstanceMethods

    # Put request parameters from `actual_h' (if any) into `actual`
    # while doing the usual validation, normalization, defaultation, and
    # emitting of any resulting errors (#pattern [#sl-116]).
    # Result is a boolean indicating whether no errors occured.
    #
    def set! actual_h=nil, actual=self.actual_parameters # [#sl-116]
      actual_h = actual_h ? actual_h.dup : { } # don't change original
      error_count_before = error_count
      prune_bad_keys actual_h
      defaults actual_h
      actual_h.each do |name, value|
        if actual.respond_to? "#{name}="
          actual.send "#{name}=", value # not atomic with above as es muss sein
        else
          error "not writable: #{name}"
        end
      end
      missing_required actual
      error_count_before == error_count # returning anything otherwise would
      # be bad design via tight coupling of our implementation and the bool fact
    end

  protected

    def actual_parameters # for compatibility with the ever-flexible set!
      self           # but it is only a default -- parameter controllers are
    end              # not necessarily the actual parameters container!

    def defaults actual_h        # #pattern [#sl-117]
      formal_parameters.each do |o|
        if o.has_default? and actual_h[o.name].nil?
          actual_h[o.name] = o.default_value
        end
      end
      nil
    end

    def formal_parameters
      formal_parameters_class.parameters
    end

    def formal_parameters_class   # feel free to override!
      self.class
    end

    def missing_required actual
      a = formal_parameters.each.select do |p|
        p.required? and ! actual.known?(p.name) || actual[p.name].nil?
      end
      if ! a.empty?
        a.map! { |param| parameter_label param }
        error "missing the required parameter#{s a} #{and_ a}"
      end
      nil
    end

    def prune_bad_keys actual_h # internal defaults may exist hence ..
      bad = ->(k) { actual_h.delete(k) } # for non-atomic aggretation of errors
      not_param = intern = nil
      actual_h.keys.each do |key|
        param = formal_parameters[key]
        if param
          if param.internal?
            (intern ||= []).push parameter_label( param )
            bad.call key
          end
        else
          (not_param ||= []).push em(key)
          bad.call key
        end
      end
      not_param and error("#{and_ not_param} #{s :is} not #{s :a}parameter#{s}")
      intern and error("#{and_ intern} #{s :is} #{s :an}internal parameter#{s}")
      nil
    end
  end
end
