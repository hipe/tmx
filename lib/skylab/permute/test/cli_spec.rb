require_relative 'test-support'

describe "#{ ::Skylab::Permute::CLI }" do
  before(:all) do  # just a bad idea all around, but we want to see how it goes
    extend ::Skylab # constants
    cli = Permute::CLI.new
    cli.program_name = 'permoot'
    spy = TestSupport::EmitSpy.new
    cli.singleton_class.send(:define_method, :emit) do |type, payload|
      spy.emit(type, payload)
    end
    @cli = cli ; @spy = spy
    # spy.debug!
  end
  after { @spy.clear! } # you are so dumb
  attr_reader :cli, :spy
  unstylize = ::Skylab::Headless::CLI::Pen::FUN.unstylize
  let :out do
    spy.emitted.map do |e| unstylize[ e.string || e.payload.to_s ] end
  end
  USAGE_RX = /usage.+permoot.+opts.+args/
  INVITE_RX = /try.+permoot.+for help/
  context 'no args' do
    it 'says expecting / usage / invite' do
      cli.invoke([])
      out.shift.should match(/expecting.+generate/)
      out.shift.should match(USAGE_RX)
      out.shift.should match(INVITE_RX)
      out.should be_empty
    end
  end
  context 'one wrong arg' do
    it 'says invalid action / usage / invite' do
      cli.invoke(['foiple'])
      out.shift.should match(/invalid action.+foiple.+expecting/)
      out.shift.should match(USAGE_RX)
      out.shift.should match(INVITE_RX)
      out.should be_empty
    end
  end
  context 'when using the "generate" subcommand' do
    context 'with no other args' do
      it 'says custom expecting / custom usage / invite' do
        cli.invoke(['generate'])
        out.shift.should match(/please provide one or more/)
        out.shift.should match(/usage.+permoot generate --attr-a/)
        out.shift.should match(INVITE_RX)
        out.should be_empty
      end
    end
    context 'with one lovely set of args' do
      it 'works splendidly' do
        cli.invoke( %w(generate --flavor vanilla -fchocolate
          --cone sugar -cwaffe -ccup) )
        exp = <<-HERE.gsub(/^ +/, '').strip
          flavor    cone
          vanilla   sugar
          chocolate sugar
          vanilla   waffe
          chocolate waffe
          vanilla   cup
          chocolate cup
        HERE
        act = out.map(&:strip).join("\n")
        act.should eql(exp)
      end
    end
  end
end
