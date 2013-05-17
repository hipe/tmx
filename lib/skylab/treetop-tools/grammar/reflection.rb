module Skylab::TreetopTools

  class Grammar::Reflection

    def initialize name, inpath_f, outdir_f
      @name, @inpath, @outdir = name, inpath_f, outdir_f
    end

    def inpath
      @inpath[].to_s
    end

    MetaHell::Function self, :@inpath, :inpathname

    def outpath
      outpathname.to_s
    end

    def outpathname
      @outdir[].join "#{ @name }.rb"
    end

    -> do

      name_rx = /[A-Z][a-zA-Z0-9_]+/  # consider functionalizing [#sl-115] these

      space_rx = /[ \t]*(#.*)?\n?/

      define_method :nested_const_names do
        # this implementation is a shameless & deferential tribute which, if
        # not obvious at first glance, is intended to symbolize the triumph
        # of the recursive buck stopping somewhere even if it perhaps doesn't
        # need to.  (i.e.: yes i know, and i'm considering it.)

        ea = ::Enumerator.new do |y|
          s = nil ; fh = @inpath[].open 'r'
          y << s while s = fh.gets
          fh.close
          nil
        end
        scn = nil
        failed = -> rsn do
          fail "expected #{ rsn } near #{ scn.rest[ 0, 12 ].inspect }"
        end
        fetch = -> rx do
          scn.scan rx or failed[ rx.inspect ]
        end
        ea.reduce [] do |memo, line|
          if scn
            scn.string = line
          else
            scn = Headless::Services::StringScanner.new line
          end
          scn.skip space_rx
          if ! scn.eos?
            if scn.scan( /module[ \t]+/ )
              memo << fetch[ name_rx ]
              while scn.scan( /::/ )
                memo << fetch[ name_rx ]
              end
            elsif scn.scan( /grammar[ \t]+/ )
              break( memo << fetch[ name_rx ] )
            else
              failed[ 'module or grammar' ]
            end
            scn.skip( /\n/ )
            scn.eos? or failed[ 'eos' ]
          end
          memo
        end
      end
    end.call
  end
end
