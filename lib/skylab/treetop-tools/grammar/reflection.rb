module Skylab::TreetopTools

  class Grammar::Reflection < ::Struct.new :name, :inpath_f, :outdir_f

    def inpath
      inpathname.to_s
    end

    def inpathname
      inpath_f.call
    end

    NAME_RX = /[A-Z][a-zA-Z0-9_]+/  # consider functionalizing [#sl-115] these

    SPACE_RX = /[ \t]*(#.*)?\n?/

    def nested_const_names
      # this implementation is a shameless & deferential tribute which, if not
      # obvious at first glance, is intended to symbolize the triumph of
      # the recursive buck stopping somewhere even if it perhaps doesn't
      # need to.  (i.e.: yes i know, and i'm considering it.)
      lines = build_lines_enumerator or return false
      require 'strscan'
      consts = [] ; scn = nil
      lines.each do |line|
        scn ? (scn.string = line) : (scn = ::StringScanner.new line)
        scn.skip SPACE_RX
        scn.eos? and next
        if scn.scan(/module[ \t]+/)
          consts << (scn.scan(NAME_RX) or fail("no: #{scn.rest}"))
          while scn.scan(/::/)
            consts << (scn.scan(NAME_RX) or fail("no: #{scn.rest}"))
          end
        elsif scn.scan(/grammar[ \t]+/)
          consts << (scn.scan(NAME_RX) or fail("no: #{scn.rest}"))
          break
        else
          fail("grammar grammar hack failed: #{scn.rest.inspect}")
        end
        scn.skip SPACE_RX
        scn.eos? or fail("grammar grammar hack failed: #{scn.rest.inspect}")
      end
      consts
    end

    def outpath
      outpathname.to_s
    end

    def outpathname
      outdir_f.call.join "#{ name }.rb"
    end

  protected

    def build_lines_enumerator
      ::Enumerator.new do |y|
        fh = inpath_f.call.open('r') ; s = nil
        y << s while s = fh.gets
        fh.close
      end
    end
  end
end
