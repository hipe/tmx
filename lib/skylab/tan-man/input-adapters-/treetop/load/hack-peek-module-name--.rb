module Skylab::TanMan

  module Input_Adapters_::Treetop

  class Load

  class Hack_peek_module_name__  # READ [#011]

    Callback_::Actor[ self, :properties, :path ]

    def execute

      file = LIB_.list_scanner ::File.open @path, 'r'

      scn = nil ; set_scanner_to_line = -> line do
        if scn then scn.string = line else
          scn = LIB_.string_scanner.new line
        end
        nil
      end
      say = -> exp_s do
        "expected #{ exp_s } near #{ Strange_[ scn.rest ] }"
      end
      fetch = -> rx do
        scn.scan( rx ) or raise say[ rx.inspect ]
      end
      first = true
      memo_a = [ ] ; eat_one_or_more_parts = -> do
        first &&= false
        begin
          memo_a << fetch[ RT_CNST_NM_RX_ ].intern
        end while scn.scan( /::/ )
        nil
      end
      pushed_back = nil
      gets = -> do
        line = if pushed_back
          r = pushed_back ; pushed_back = nil ; r
        else
          file.gets
        end
        if line
          set_scanner_to_line[ line ]
          true
        end
      end
      if gets[]  # so bad ..
        did = false ; have = true
        while scn.skip( /[ \t]*require(_relative)?[ \t(]/ )
          did = true
          have = gets[] or break
        end
        if have
          pushed_back = scn.string
        end
      end
      while gets[]
        scn.skip SPACE_RX_
        scn.eos? and next
        part = scn.scan( /(?:module|class|grammar)(?=[ \t]+)/ )
        if ! part
          if first then raise say[ 'module or class, e.g' ]
          else break end
        end
        scn.skip( /[ \t]+/ ) or fail "sanity - above"
        scn.skip( /::/ )  # fully qualified toplevel names meh
        eat_one_or_more_parts[]
        scn.skip SPACE_RX_
        scn.eos? or raise say[ 'eos' ]
      end
      memo_a.length.nonzero? and memo_a
    end

    RT_CNST_NM_RX_ = /[A-Z][A-Za-z0-9_]*/

    RIGHT_CONSTANT_NAME_RX_ = /\A#{ RT_CNST_NM_RX_.source }\z/

    SPACE_RX_ = /[ \t]*(#.*)?\n?/

    T_MODULE_ = 'module'.freeze

  end
  end
  end
end