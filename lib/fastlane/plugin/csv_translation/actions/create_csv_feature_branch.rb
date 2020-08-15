require 'fastlane/action'
require_relative '../helper/csv_translation_helper'

module Fastlane
  module Actions
    module SharedValues
      CREATE_CSV_FEATURE_BRANCH_INFO = :CREATE_CSV_FEATURE_BRANCH_INFO
    end

    class CreateCsvFeatureBranchAction < Action
      def self.run(params)
        # fetching csv file
        csv_file_folder = Helper::CsvTranslationHelper.create_feature_branch(
          repository_name: params[:repository_name],
          branch_name: params[:branch_name],
          feature_branch_name: params[:feature_branch_name]
        )

        Actions.lane_context[SharedValues::CREATE_CSV_FEATURE_BRANCH_INFO] = csv_file_folder
        return csv_file_folder
      end

      def self.description
        "Create a csv feature branch."
      end

      def self.output
        [
          ['CREATE_CSV_FEATURE_BRANCH_INFO', 'Created feature branch info']
        ]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :repository_name,
                                       env_name: "FL_CREATE_CSV_FEATURE_BRANCH_REPOSITORY_NAME",
                                       description: "The name to your repository, e.g. 'fastlane/fastlane'",
                                       verify_block: proc do |value|
                                         UI.user_error!("No repository_name given in input param") unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :branch_name,
                                       env_name: "FL_CREATE_CSV_BASE_BRANCH_NAME",
                                       description: "The branch name to your repository, (default main)",
                                       is_string: true,
                                       default_value: "main"),
          FastlaneCore::ConfigItem.new(key: :feature_branch_name,
                                       env_name: "FL_CREATE_CSV_FEATURE_BRANCH_NAME",
                                       description: "The feature branch name for new translation request (Useful if no direct commit allowed in main)",
                                       is_string: true,
                                       optional: true)
        ]
      end

      def self.authors
        ["crazymanish"]
      end

      def self.example_code
        [
          'create_csv_feature_branch(
            repository_name: "fastlane/fastlane",
            feature_branch_name: "some_feature_branch_name")',
          'create_csv_feature_branch(
            repository_name: "fastlane/fastlane",
            branch_name: "main",
            feature_branch_name: "some_feature_branch_name")'
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
