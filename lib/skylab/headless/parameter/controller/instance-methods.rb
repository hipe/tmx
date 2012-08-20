module Skylab::Headless
  module Parameter::Controller::InstanceMethods
    # and_ em error errors_count formal_parameters params s
    def set! request=nil, params_arg=nil
      errors_count_before = errors_count
      request = request ? request.dup : {}
      prune_bad_keys request
      defaults request
      use_params = params_arg || params
      request.each do |name, value|
        if use_params.respond_to?(writer = "#{name}=")
          use_params.send(writer, value) # not atomic with above as es muss sein
        else
          error("not writable: #{name}")
        end
      end
      missing_required use_params
      errors_count_before == errors_count ? use_params : false
    end
  protected
    def defaults request
      fp = formal_parameters
      rks = request.keys ; dks = fp.all.select(&:has_default?).map(&:name)
      request.merge!  Hash[ (dks - rks).map { |k| [k, fp[k].default_value] } ]
      nil
    end
    def missing_required params
      a = formal_parameters.list.
        select { |param| param.required? and params[param.name].nil? }.
        map { |param| pen.parameter_label param }
      a.empty? or error("missing the required parameter#{s a} #{and_ a}")
      nil
    end
    def prune_bad_keys request # internal defaults may exist hence ..
      bad = ->(k) { request.delete(k) } # for non-atomic aggretation of errors
      not_param = intern = nil
      request.keys.each do |key|
        param = formal_parameters[key]
        if param
          if param.internal?
            (intern ||= []).push pen.parameter_label(param)
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
