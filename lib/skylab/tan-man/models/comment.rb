module Skylab::TanMan
  module Models::Comment
    # purely a namespace module, all defined in this file for now.
  end


  class Models::Comment::LineEnumerator < ::Struct.new :scn
    extend MetaHell::Boxxy

    def self.for str
      res = nil
      begin
        scn = TanMan::Services::StringScanner.new str
        scn.skip( /[[:space:]]+/ )
        type = nil
        if scn.skip( /\/\*/ )
          type = :c_style
        elsif scn.skip( /#/ )
          type = :shell_style
        end
        break( res = false ) if ! type
        klass = const_fetch type
        res = klass.new scn
      end while nil
      res
    end

    def each &block
      lines.each(& block)
    end
  end


  class Models::Comment::LineEnumerator::C_Style <
     Models::Comment::LineEnumerator

     def lines
       ::Enumerator.new do |y|
         while ! scn.eos?
           s = scn.scan( /((?!\*\/)[^\r\n])*/ )
           y << s if s
           break if scn.match?( /\*\// )
           scn.skip( /\r?\n/ )
         end
       end
     end
  end


  class Models::Comment::LineEnumerator::ShellStyle <
    Models::Comment::LineEnumerator

    def lines
      ::Enumerator.new do |y|
        scn.skip( /[[:space:]]*#/ )
        while ! scn.eos?
          s = scn.scan( /[^\r\n]*/ )
          s or break
          y << s
          scn.skip( /\r?\n/ ) or break
          scn.skip( /([ \t]*\r?\n)+/ )
          scn.skip( /[ \t]*#/ ) or break
        end
      end
    end
  end
end
