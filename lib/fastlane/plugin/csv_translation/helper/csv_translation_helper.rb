require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class CsvTranslationHelper
      # class methods that you define here become available in your action
      # as `Helper::CsvTranslationHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the csv_translation plugin helper!")
      end
    end
  end
end
