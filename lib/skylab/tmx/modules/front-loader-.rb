module Skylab::TMX

  module Modules::Front_Loader_

    # this is where sausage is made

    SKIP_H_ = {
      :'quickie' => :hop,
      :'regret' => :hop
    }.freeze

    BIN_PN_, PREFIX_ = TMX::Lib_::Pathnames[].at :bin, :binfile_prefix

    INITIALS_RX_ = /(?<=^|-)./  # "foo-bar".scan( rx )  # => ['f', 'b']

    Namespace_Ingredients_Generator_ = -> do

      basename_a = ::Dir.chdir BIN_PN_ do ::Dir[ "#{ PREFIX_ }*" ] end

      idx = -1 ; last = basename_a.length - 1 ; len = PREFIX_.length
      -> do
        begin
          idx < last or break
          basename = basename_a.fetch( idx += 1 )
          stem_i = ( stem = basename[ len .. -1 ] ).intern
          redo if :hop == SKIP_H_[ stem_i ]
          opt_h = { skip: false }
          if 1 < (( initials_a = stem.scan INITIALS_RX_ )).length
            opt_h[ :aliases ] = [ initials_a * '' ]
          end
          client_mod_p = Client_module_resolver_p_[ stem ]
          r = [ stem_i, client_mod_p, opt_h ]
        end while false
        r
      end
    end

    Client_module_resolver_p_ = -> stem do
      pn = ::Skylab.dir_pathname.join "#{ stem }/core#{ Autoloader_::EXTNAME }"
      -> do
        if pn.exist?
          Resolve_client_module_from_core_[ pn, stem ]
        else
          Produce_binfile_stub_class_from_stem_[ stem ]
        end
      end
    end

    Resolve_client_module_from_core_ = -> pn, stem do

      # (for now we do a hacky little dance involving allowing one subproduct
      # to use different casings of the same name for nefarious purposes of
      # letting legacy monoliths maintain their namespace purity. this might
      # be a tag expensive when we are generating index screens..)

      distill = Lib_::Distill
      tgt = distill[ stem ]
      require pn.to_s
      match_a = ::Skylab.constants.reduce [] do |m, c|
        tgt == distill[ c ] and m << c
        m
      end
      if (( len = match_a.length )).nonzero?
        const_i = if 1 == len
          match_a.fetch 0
        else
          match_a.sort_by!( & :length )
          penult, ult = match_a[ -2 .. -1 ]
          ult.length == penult.length and
            fail "unresolvable ambiguity - #{ penult }/#{ ult }"
          ult
        end
        ::Skylab.const_get( const_i, false )::CLI::Client
      end
    end

    Stubs_ = ::Module.new

    Produce_binfile_stub_class_from_stem_ = TMX::Front_Loader::
      Produce_binfile_stub_class_from_bin_pn_and_prefix_and_box_and_stem_.
        curry[ BIN_PN_, PREFIX_, Stubs_ ]

  end

  class CLI::Client

    skip_h = Modules::Front_Loader_::SKIP_H_

    g = Modules::Front_Loader_::Namespace_Ingredients_Generator_[]
    while (( a = g[] ))
      stem_i, client_const_p, opt_h = a
      skip_h[ stem_i ] and opt_h[ :skip ] = true
      namespace stem_i, client_const_p, opt_h
    end

    # here's the sort of thing that's happening above. this is how you
    # can add a sub-node explicitly. in this case it is a sub-node with
    # a nonstandard location:

    namespace :'quickie', -> do
      require 'skylab/test-support/core'
      ::Skylab::TestSupport::Quickie::Recursive_Runner
    end, :skip, false

    namespace :regret, -> do  # because names are not isomorphic with f.s
      require 'skylab/test-support/core'
      ::Skylab::TestSupport::Regret::CLI::Client
    end, :skip, false
  end
end
