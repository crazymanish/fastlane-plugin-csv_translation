describe Fastlane::Actions::CsvTranslationAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The csv_translation plugin is working!")

      Fastlane::Actions::CsvTranslationAction.run(nil)
    end
  end
end
