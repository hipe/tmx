module Skylab::Autonomous_Component_System

  self._REVEW_dependencies_have_changed_and_this_whole_node_is_not_covered

  module Infer

    Description = -> y, expag, nf, acs do  # [#003]:#infer-desc

      # hackly made a ridiculous assumption that lets us guess whether
      # the verb takes a singular or plural noun for its object.
      # #experimental, will change.

      _st = ACS_::For_Interface::To_stream[ acs ]

      lemma = nf.as_human

      expag.calculate do

        _s_a = _st.join_into [] do |oper|

          _assume_plural = oper.formal_properties.length.zero?

          _noun_s = if _assume_plural
            plural_noun lemma
          else
            lemma
          end

          "#{ oper.name.as_human } #{ _noun_s }"
        end

        y << _s_a.join( ', ' )
      end
    end
  end
end
