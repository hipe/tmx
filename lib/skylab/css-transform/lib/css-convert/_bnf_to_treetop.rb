#!/usr/bin/env ruby -w

require 'strscan'
require 'ruby-debug'

# per http://www.w3.org/TR/REC-xml/

# yes we did


the_bnf = <<-HERE

Foobie ::= "A" "B" | "C"

NameStartChar ::= ":" | [A-Z] | "_" | [a-z] | [#xC0-#xD6] | [#xD8-#xF6] |
                  [#xF8-#x2FF] | [#x370-#x37D] "bazzle" | [#x37F-#x1FFF] |
                  [#x200C-#x200D] | [#x2070-#x218F] | [#x2C00-#x2FEF] |
                  [#x3001-#xD7FF] | [#xF900-#xFDCF] | [#xFDF0-#xFFFD] |
                  [#x10000-#xEFFFF]

NameChar  ::=     NameStartChar  | "-" | "." | [0-9] | #xB7 |
                  [#x0300-#x036F] | [#x203F-#x2040]

Name      ::=     NameStartChar (NameChar)*

Names     ::=     Name (#x20 Name)*
Nmtoken   ::=     (NameChar)+
Nmtokens  ::=     Nmtoken (#x20 Nmtoken)*


HERE



module Hipe; end
module Hipe::BnfToTreetop
  class << self; def instance; BnfToTreetop.new end end
  class BnfToTreetop
    def initialize
      @tree = [:rules]
      @stack = [@tree]
      @out = $stdout
      @err = $stderr
      @expecting = []
    end
    def push sexp
      @stack.last.push sexp
    end
    def one_of_or_fail &block
      reset_expecting!
      if found = block.call
        reset_expecting!
        found
      else
        msg = report_union_failure
        fail_with_context(msg)
      end
    end
    def reset_expecting!
      @expecting.clear
    end
    def oxford_comma items, last_glue = ' and ', rest_glue = ', '
      items.zip(
        items.size < 2 ? [] :
          ( [last_glue] + Array.new(items.size - 2, rest_glue) ).reverse
      ).flatten.join
    end
    def report_union_failure
      "Expecting #{oxford_comma(@expecting.map(&:to_s), ' or ')}"
    end
    def fail_with_context msg
      @err.puts msg
      before = @s.string[[0, @s.pos-20].max .. @s.pos].gsub("\n", " ")
      after = @s.peek(20).gsub("\n", " ")
      @err.puts "at: #{before}#{after}"
      @err.puts "----#{'-' * before.size}^"
      if (@s.eos?) then @err.puts("(before end of input)") end
      throw(:done, {:status => 1})
    end
    def run input_str
      @s = StringScanner.new(input_str)
      white!
      catch(:done) do
        until @s.eos?
          new_rule!
          rule_name!; white!; equals_thingy!; white!; rule_rhs!; white!
        end
      end
      # PP.pp @tree
      Nodes::Rules.new(@tree, @out, @err).to_treetop
    end
    def white!
      @s.skip(/[ \t\n\r\f]+/) || true
    end
    def new_rule!
      sexp = [:rule]
      push sexp                 # append sexp to sexp at the top of stack
      @stack.push sexp          # make new sexp be new top of stack
    end
    def rule_name!
      n = _rule_name! or fail_with_context("expected Rule Name")
      push n
    end
    def _rule_name!
      @expecting << :rule_name
      if str = @s.scan(/[_a-zA-Z][_a-zA-Z0-9]*/) then [:rule_name, str] end
    end
    def equals_thingy!
      _equals_thingy! or fail_with_context("expected \"::=\"")
    end
    def rule_rhs!
      sexp = [:rhs]
      push sexp
      @stack.push sexp
      rhs!
      @stack.pop # pop the rhs
      @stack.pop # pop the rule!!
    end
    def rhs!
      got = one_of_or_fail {
        _rule_name! || _character_class! || _nonempty_quoted_string! ||
        _unicodepoint_literal! || _parenthesized_group!
      }
      push got
      white!
      if @s.eos?        then return end
      if @s.check(/\)/) then return end # never processed here
      reset_expecting!
      @expecting << :end_of_input # maybe not used
      need_moar = false
      if got = _kleene!
        push got
        white!
        if @s.eos? then return end
      end
      if got = _or!
        push got
        need_moar = true
        white!
      end

      # ad-hoc lookahead to determine if rule name in LHS or RHS:
      # this way we don't need to care about use of newlines or really any
      # other whitespace

      noted = @s.pos
      if (! need_moar && got = _rule_name! && white! &&
          _equals_thingy! && @stack[@stack.size-2].first == :rule )
      then
        @s.pos = noted # if a symbol name followed by a '::=', rewind, done
        return
      end
      @s.pos = noted # rewind no matter what! let other call handle rhs symbol
      rhs!
    end
    def _parenthesized_group!
      @expecting << :parenthesized_group
      if @s.scan(/\(/)
        nu = [:parenthesized_group]
        # push nu sort of up in the air about whether to do this early or late
        @stack.push nu
        rhs!
        white!
        one_of_or_fail { @expecting << ')'; @s.scan(/\)/) }
        have = @stack.pop
        have
      end
    end
    def _character_class!
      @expecting << :character_class
      if found = @s.scan(/\[(?:[^\]]|\\\])+\]/)
        [:character_class, found]
      end
    end
    def _equals_thingy!
      @s.skip(/::=/)
    end
    def _kleene!
      @expecting << :kleene
      if found = @s.scan(/[*+]/)
        [:kleene, found]
      end
    end
    def _nonempty_quoted_string!
      @expecting << :nonempty_quoted_string
      if found = @s.scan(/"(?:\\"|[^"])+"/)
        [:nonempty_quoted_string, found]
      end
    end
    def _or!
      @expecting << :or
      if found = @s.scan(/\|/)
        [:or, found]
      end
    end
    def _unicodepoint_literal!
      @expecting << :unicodepoint_literal
      if found = @s.scan(/#x([a-zA-Z0-9]+)/)
        [:unicodepoint_literal, found]
      end
    end
  end
  module Nodes
    module Helpers
      def literalize_unicode str
        str.gsub(/#x([a-zA-Z0-9]+)/){ [$1.hex].pack('U*') }
      end
      def uncamelize str
        str.gsub(/([a-z])([A-Z])/){ "#{$1}_#{$2}" }.downcase
      end
    end
    class Node
      include Helpers
      def initialize tree, out, err
        @tree = tree; @out = out; @err = err
      end
      attr_accessor :tree
    end
    class Rules < Node
      def to_treetop
        stupid = Rule.new(nil, @out, @err)
        @tree[1..-1].each_with_index do |tree, idx|
          @out.write("\n") unless idx == 0
          stupid.tree = tree
          stupid.to_treetop
        end
        nil
      end
    end
    class Rule < Node
      def initialize *a
        super(*a)
        @rhs = Rhs.new(nil, @out, @err)
      end
      def to_treetop
        @rhs.tree = @tree[2]
        @out.puts "  rule #{uncamelize(@tree[1][1])}"
        @out.write "    "
        @rhs.to_treetop
        @out.write "\n  end"
        nil
      end
    end
    class Rhs < Node
      def to_treetop node=@tree
        node[1..-1].each_with_index do |_sexp, idx|
          send("_#{_sexp.first}", _sexp, idx)
        end
      end
      def _character_class s, idx
        @out.write(' ') unless idx == 0
        @out.write literalize_unicode(s[1]) # careful!
      end
      def _kleene s, idx
        @out.write(s[1])
      end
      def _nonempty_quoted_string s, idx
        @out.write(' ') unless idx == 0
        @out.write s[1] # careful!
      end
      def _or _, __
        @out.write(' ')
        @out.write('|')
      end
      def _parenthesized_group s, idx
        @out.write(' ') unless idx == 0
        @out.write '('
        to_treetop s
        @out.write ')'
      end
      def _rule_name s, idx
        @out.write(' ') unless idx == 0
        @out.write uncamelize(s[1])
      end
      def _unicodepoint_literal s, idx
        @out.write(' ') unless idx == 0
        @out.write literalize_unicode(s[1]).inspect # careful!
      end
    end
  end
end

Hipe::BnfToTreetop.instance.run(the_bnf)