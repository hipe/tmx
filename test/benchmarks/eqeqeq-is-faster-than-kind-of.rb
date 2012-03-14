require 'benchmark'

class BenchmarkAltertnative < Struct.new(:label, :block)
  def initialize input
    case input
    when Alt
      (input.class.members | self.class.members).each{ |k| send("#{k}=", input.send(k)) }
    when Hash
      input.each { |k, v| send("#{k}=", v) }
    else
      raise ArgumentError.new("no: #{input.inspect}")
    end
  end
  def block= block
    super(block)
    singleton_class.send(:define_method, :execute) { instance_exec(&block) }
  end
end

class Alt < BenchmarkAltertnative
  def val
    if rand >= 0.5
      1
    else
      :foo
    end
  end
end

alts = [
  Alt.new(
    :label => "kind_of?",
    :block => ->() { val.kind_of?(Fixnum) }
  ),
  Alt.new(
    :label => "===",
    :block => ->() { Fixnum === val }
  ),
  Alt.new(
    :label => "==",
    :block => ->() { Fixnum == val.class }
  )
]

tests = lambda do
  tester = Class.new(Alt).class_eval do
    attr_accessor :val
    self
  end

  assert = ->(alt, input, output) {
    alt = tester.new(alt)
    alt.val = input
    $stderr.write "#{alt.label} with a val of #{input} executes as #{output.inspect}"
    if (ret = (output == alt.execute))
      $stderr.puts "."
    else
      $stderr.puts " .. FAILED"
    end
    ret
  }

  alts.each do |a|
    assert[a, 1, true]
    assert[a, 1.0, false]
  end
end

t = 4_000_000

make_bm_jobs = ->(x) {
  alts.each { |a| x.report(a.label) { t.times { a.execute } } }
}

# tests[]
Benchmark.bmbm(&make_bm_jobs)

