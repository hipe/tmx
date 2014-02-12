class Skylab::Face::CLI::Client

  module API_Integration_  # see [#052] what is the deal with exp

    EXPRESSION_AGENT_ = (( class Expression_Agent__ <

        Face_::API::Normalizer_::Expression_agent_class[]

      def par fld
        kbd par_nonstyled fld
      end

    private  # ( make things public as necessary )

      define_method :kbd, Lib_::Stylify_proc[].curry[%i( green )]

      def par_nonstyled fld
        if fld.respond_to? :id2name
          i = fld ; p = As_arg_
        else
          i = fld.local_normal_name ; p = fld.is_required ? As_arg_ : As_long_
        end
        p[ i ]
      end
      #
      As_arg_ = -> i do
        As_arg__[ Chmp_[ i ] ]
      end
      #
      As_arg__, Chmp_ = Face_::API::Procs.
        at :Local_normal_name_as_argument_raw, :Chomp_single_letter_suffix
      #
      As_long_ = -> i do
        Lib_::Option_local_normal_name_as_long[ Chmp_[ i ] ]
      end

      self
    end )).new
  end
end
