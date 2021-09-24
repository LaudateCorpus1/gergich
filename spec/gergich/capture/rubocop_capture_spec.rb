# frozen_string_literal: true

require_relative "../../support/capture_shared_examples"

RSpec.describe Gergich::Capture::RubocopCapture do
  subject(:captor) { described_class.new }

  let(:output) do
    <<~OUTPUT
      Offenses:

      bin/gergich:47:8: C: Prefer double-quoted strings
      if ENV['DEBUG']
             ^^^^^^^
      foo/bar/baz.rb:1:2: W: no context for this one :shrug:
      lib/gergich.rb:10:9: E: this is a terrible name

      seriously, what were you thinking?
          def foo
              ^^^
      lib/gergich.rb:22:55: W: Line is too long. [55/54]
          def initialize(ref = "HEAD", revision_number = nil)
                                                           ^^

      1 file inspected, 35 offenses detected, 27 offenses auto-correctable
    OUTPUT
  end
  let(:comments) do
    [
      {
        path: "bin/gergich",
        position: 47,
        message: "[rubocop] Prefer double-quoted strings\n\n if ENV['DEBUG']\n        ^^^^^^^\n",
        severity: "info"
      },
      {
        path: "foo/bar/baz.rb",
        position: 1,
        message: "[rubocop] no context for this one :shrug:\n",
        severity: "warn"
      },
      {
        path: "lib/gergich.rb",
        position: 10,
        message: <<~OUTPUT,
          [rubocop] this is a terrible name

          seriously, what were you thinking?

               def foo
                   ^^^
        OUTPUT
        severity: "error"
      },
      {
        path: "lib/gergich.rb",
        position: 22,
        message: <<~OUTPUT,
          [rubocop] Line is too long. [55/54]

               def initialize(ref = "HEAD", revision_number = nil)
                                                                ^^
        OUTPUT
        severity: "warn"
      }
    ]
  end

  it_behaves_like "a captor"

  it "raises an error if it couldn't run" do
    expect { captor.run(<<-OUTPUT) }.to raise_error(/RuboCop failed to run properly/)
      Could not find i18n-1.8.9 in any of the sources
      Run `bundle install` to install missing gems.
    OUTPUT
  end
end
