module Skylab::Face

  module CLI::API_Integration  # [#052]

    class Expression_Agent__ < Face::API::Normalizer_::Expression_agent_class[]

      def par fld
        kbd par_nonstyled fld
      end

    private  # ( make things public as necessary )

      define_method :kbd, Face::CLI::FUN.stylify.curry[ %i( green ) ]

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
      As_arg__, Chmp_ = Face::API::Procs.
        at :Local_normal_name_as_argument_raw, :Chomp_single_letter_suffix
      #
      As_long_ = -> i do
        As_long__[ Chmp_[ i ] ]
      end
      #
      As_long__ = Headless::CLI::Option::Local_normal_name_as_long
    end

    EXPRESSION_AGENT_ = Expression_Agent__.new
  end
end
