require 'rspec/core/formatters/snippet_extractor'

module RSpec
  module Core
    module Formatters
      RSpec.describe SnippetExtractor do
        it "falls back on a default message when it doesn't understand a line" do
          expect(RSpec::Core::Formatters::SnippetExtractor.new.snippet_for("blech")).to eq(["# Couldn't get snippet for blech", 1])
        end

        it "falls back on a default message when it doesn't find the file" do
          expect(RSpec::Core::Formatters::SnippetExtractor.new.lines_around("blech", 8)).to eq("# Couldn't get snippet for blech")
        end

        it "falls back on a default message when it gets a security error" do
          message = nil
          with_safe_set_to_level_that_triggers_security_errors do
            message = RSpec::Core::Formatters::SnippetExtractor.new.lines_around("blech", 8)
          end
          expect(message).to eq("# Couldn't get snippet for blech")
        end

        describe "snippet extraction" do
          let(:snippet) do
            SnippetExtractor.new.snippet(["#{__FILE__}:#{__LINE__}"])
          end

          before do
            # `send` is required for 1.8.7...
            @orig_converter = SnippetExtractor.send(:class_variable_get, :@@converter)
          end

          after do
            SnippetExtractor.send(:class_variable_set, :@@converter, @orig_converter)
          end

          it 'suggests you install coderay when it cannot be loaded' do
            SnippetExtractor.send(:class_variable_set, :@@converter, SnippetExtractor::NullConverter)

            expect(snippet).to include("Install the coderay gem")
          end

          it 'does not suggest installing coderay normally' do
            expect(snippet).to exclude("Install the coderay gem")
          end
        end
      end
    end
  end
end
