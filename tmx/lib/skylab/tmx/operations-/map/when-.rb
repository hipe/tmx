module Skylab::TMX

  class Operations_::Map

    When_ = ::Module.new
    module EventsScratchSpace___

      # ==

      When_::Contextually_missing = -> dep_sym, primary_sym, listener do

        listener.call :error, :expression, :parse_error, :contextually_missing do |y|

          _prim_name = Common_::Name.via_variegated_symbol primary_sym

          _dep_name = Common_::Name.via_variegated_symbol dep_sym

          y << "cannot use #{ say_primary_ _prim_name } without #{ say_primary_ _dep_name }"
        end

        UNABLE_
      end

      # ==

      When_::Contextually_invalid_primary = -> sym, listener do

        listener.call :error, :expression, :parse_error, :contextually_invalid do |y|

          _means = Misc_hard_coded_dependency_reflection__[].fetch sym

          exp = _means.sayer_under self

          _me = exp.say_self

          _dep = exp.say_dependency

          y << "#{ _me } must occur after #{ _dep }."
        end
        UNABLE_
      end

      # ==

      When_::Missing_requireds = -> missing_ivar_a, listener do

        listener.call :error, :expression, :parse_error, :missing_required_arguments do |y|

          h = Misc_hard_coded_dependency_reflection__[]

          missing_ivar_a.each do |key|

            exp = h.fetch( key ).sayer_under self

            _me = exp.say_self

            _dep = exp.say_dependency

            y << "#{ _me } was not resolved. (use #{ _dep }.)"
          end
          y
        end

        UNABLE_
      end

      # ==

      Misc_hard_coded_dependency_reflection__ = Lazy_.call do

        # hypothetically we can generate some of this with [ta] magnetics meh

        h = {}

        o = -> sym, & defn do
          means = Home_::Models_::Means.define sym, & defn
          h[ means.normal_symbol ] = means
        end

        o.call :result_in_tree do |y|
          y.yield :is_expressed_as, :primary
          y.yield :depends_on, :order, :which_is_expressed_as, :primary
        end

        o.call :unparsed_node_stream do |y|
          y.yield :is_expressed_as, :human
          y.yield :depends_on, :json_file_stream, :which_is_expressed_as, :primary
        end

        h
      end

      # ==
    end
  end
end
# #history: broke out of operation
