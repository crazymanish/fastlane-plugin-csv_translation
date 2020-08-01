require 'fastlane/action'
require_relative '../helper/csv_translation_helper'

module Fastlane
  module Actions
    module SharedValues
      FETCH_CSV_BRANCH_INFO = :FETCH_CSV_BRANCH_INFO
    end

    class FetchCsvBranchAction < Action
      def self.run(params)
        # fetching csv file
        csv_file_folder = Helper::CsvTranslationHelper.fetch_csv_file(
          repository_name: repository_name,
          branch_name: branch_name
        )

        Actions.lane_context[SharedValues::CREATE_CSV_FEATURE_BRANCH_INFO] = csv_file_folder
        return csv_file_folder
      end

      def self.description
        "Fetch a csv file branch."
      end

      def self.output
        [
          ['FETCH_CSV_BRANCH_INFO', 'Fetched CSV file branch info']
        ]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :repository_name,
                                       env_name: "FL_FETCH_CSV_REPOSITORY_NAME",
                                       description: "The name to your repository, e.g. 'fastlane/fastlane'",
                                       verify_block: proc do |value|
                                         UI.user_error!("No repository_name given in input param") unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :branch_name,
                                       env_name: "FL_FETCH_CSV_BRANCH_NAME",
                                       description: "The branch name to your repository, (default main)",
                                       is_string: true,
                                       default_value: "main")
        ]
      end

      def self.authors
        ["crazymanish"]
      end

      def self.example_code
        [
          'fetch_csv_branch(repository_name: "fastlane/fastlane")',
          'fetch_csv_branch(
            repository_name: "fastlane/fastlane",
            branch_name: "some_feature_branch_name")'
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
