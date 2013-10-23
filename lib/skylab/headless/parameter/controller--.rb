module Skylab::Headless

  class Parameter

    module Controller__  # assumes `parameter_error_structure`

      p = -> a do
        include IM__
        if :without == a[ 0 ]
          :headless_sub_client == a[ 1 ] or fail "no - #{ a[ 1 ] }"
          a[ 0, 2 ] = MetaHell::EMPTY_A_
        else
          include Headless::SubClient::InstanceMethods
        end ; nil
      end
      define_singleton_method :to_proc do p end

      Struct_Adapter = -> a do

        # an experimental that asks:  what if you want your parameter superset
        # defined only by a ::Struct?  There can be no superset definitions of
        # specific parameters.  Merely it is that each member of the struct is
        # a required parameter (and it follows that no actual parameters could
        # be added that are not in the parameter superset, which is the point)

        extend Parameter::Definer # gets m.m and appropriate i.m

        include IM__

        members.each { |m| param m, required: true }

        def invoke param_h
          r = set! param_h
          r &&= execute
          r
        end
      end

      Ev__ = ::Module.new
      Event__ = Headless::Event_

      module IM__  # (changed event model at [#087])

    # Put request parameters from `actual_h' (if any) into `actual`
    # while doing the usual validation, normalization, defaultation, and
    # emitting of any resulting errors (#pattern [#sl-116]).
    # Result is a boolean indicating whether no errors occured.
    #

        def set! actual_h=nil, actual=self.actual_parameters # [#sl-116]

          # process depth first in order - actual_h might be a proxy for
          # an ordered collection whose elements target subsequent behavior

          befor = error_count
          write_p = -> par, x do
            m_i = par.writer_method_name
            ok = actual.respond_to? m_i
            ok or break parameter_error_structure Ev__::Not_Writable__[ par ]  # todo go this away
            actual.send m_i, x
          end
          actual_h and write_valid_actual_to_p actual_h, write_p
          write_defaults_against_actual_to_p actual, write_p
          check_missing_required_against_actual actual
          befor == error_count
        end

        Ev__::Not_Writable__ = Event__.new do | par_ |
          "not writable: #{ par par_.normalized_parameter_name }"
        end

      private
        def write_valid_actual_to_p actual_h, write_p
          fp = formal_parameters ; extra_i_a = intern_o_a = nil
          actual_h.each_pair do |i, x|
            par = fp[ i ]
            par or next( ( extra_i_a ||= [ ] ) << i )
            par.internal? and next( ( intern_o_a ||= [ ] ) << par )
            write_p[ par, x ]
          end
          extra_i_a and parameter_error_structure Ev__::Not_Param__[ extra_i_a ]
          intern_o_a and parameter_error_structure Ev__::Internal__[ intern_o_a ]
          nil
        end

        def write_defaults_against_actual_to_p actual, write_p  # :+#defaults [#sl-117]
          formal_parameters.each do |par|
            par.has_default? or next
            i = par.normalized_parameter_name
            actual.known?( i ) && ! actual[ i ].nil? and next
            write_p[ par, par.default_value ]
          end
        end
        #
        Ev__::Not_Param__ = Event__.new do |param_i_a|
          _s_a = param_i_a.map( & method( :em ) )
          "#{ and_ _s_a } #{ s :is } not #{ s :a }parameter#{ s }"
        end
        #
        Ev__::Internal__ = Event_.new do |param_a|
          _s_a = param_a.map( & method( :parameter_label ) )
          "#{ and_ _s_a } #{ s :is } #{ s :an }internal parameter#{ s }"
        end

        def check_missing_required_against_actual actual
          miss_a = formal_parameters.reduce [ ] do |m, (i, par)|
            par.required? or next m
            actual.known?( i ) && ! actual[ i ].nil? and next m
            m << par
          end
          miss_a.length.zero? or missing_required_failure miss_a ; nil
        end
        #
        def missing_required_failure param_o_a
          _ev = Ev__::Missing__[ agent_string, param_o_a ]
          parameter_error_structure _ev ; nil
        end
        #
        Ev__::Missing__ = Event__.new do |any_agent_string, param_o_a|
          a = param_o_a.map( & method( :parameter_label ) )
          any_agent_string and as = "#{ any_agent_string } "
          "#{ as }missing the required parameter#{ s a } #{ and_ a }"
        end

        def agent_string
          @agent_string ||= get_parameter_controller_moniker
        end
        #
        def get_parameter_controller_moniker
          a = self.class.to_s.split '::'
          a = a[ [ a.length, 2 ].min * -1 .. -1 ]
          a.reverse!  # assume Noun::Verb -> 'verb noun'
          a.map { |s| Autoloader::FUN.pathify[ s ] } * ' '
        end

        def formal_parameters
          formal_parameters_class.parameters
        end
        #
        def formal_parameters_class   # feel free to override!
          self.class
        end
      protected  # #protected-not-private
        def actual_parameters
          self  # the param controller is not necessarily the param container
        end
      end
    end
  end
end
