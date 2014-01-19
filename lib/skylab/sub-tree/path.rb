module Skylab::SubTree

  module PATH

    o = -> m, p do
      define_singleton_method m, &p
      nil
    end

    class << o ; alias_method :[]=, :[] end

    o[:test_basename_rx] = -> do
      /^ (?: #{ glob_h.values.uniq.map( & Glob_to_rx_ ) * '|' } ) $/x
    end

    Glob_to_rx_ = -> glob do  # a hack
      scn = SubTree::Library_::StringScanner.new glob
      out_a = []
      until scn.eos?
        if scn.scan( /\*/ )
          out_a << '(.*)'
        elsif (( s = scn.scan( /[^\*]+/ ) ))
          out_a << "(#{ ::Regexp.escape s })"
        else
          fail "unexpected rest of string (don't use '**') - #{
            }#{ scn.rest.inspect }"
        end
      end
      out_a * ''
    end

    o[:test_dir_names_moniker] = -> do
      "[#{ SubTree::Constants::TEST_DIR_NAME_A * '|' }]"
    end

    o[:glob_h] = -> do
      p = -> do
        srbg = "*#{ SubTree::Library_::TestSupport::FUN::Spec_rb[] }"
        r = { 'features' => '*.feature',
              'spec'     => srbg,
              'test'     => srbg
            }.freeze
        p = -> { r }
        r
      end
      p.call
    end
  end
end
