require 'fastlane/action'
require_relative '../helper/csv_translation_helper'

module Fastlane
  module Actions
    module SharedValues
      CREATE_CSV_TRANSLATION_REQUEST_INFO = :CREATE_CSV_TRANSLATION_REQUEST_INFO
    end

    class CreateCsvTranslationRequestAction < Action
      def self.run(params)
        # fetching csv file
        csv_file_folder = Helper::CsvTranslationHelper.fetch_csv_file(
          repository_name: params[:repository_name],
          branch_name: params[:branch_name],
          feature_branch_name: params[:feature_branch_name]
        )

        csv_file_path = "#{csv_file_folder}/#{params[:file_path]}"
        csv_payload = params[:payload]

        # adding new entry into csv file
        require 'csv'
        CSV.open(csv_file_path, 'a+', headers: csv_payload.keys) do |csv|
          csv << csv_payload.values
        end

        # creating csv translation request
        git_message = "New translation request: #{csv_payload}"
        git_commit_info = ""
        Dir.chdir(csv_file_folder) do
          GitCommitAction.run(path: ".", message: git_message)
          PushToGitRemoteAction.run(remote: "origin")
          git_commit_info = Actions.last_git_commit_dict
        end
        UI.success("Successfully created a #{git_message} 🚀")

        # building translation request info
        translation_request_info = {
          payload: csv_payload,
          git_commit_info: git_commit_info}

        Actions.lane_context[SharedValues::CREATE_CSV_TRANSLATION_REQUEST_INFO] = translation_request_info
        return translation_request_info
      end

      def self.description
        "Create a csv translation request."
      end

      def self.output
        [
          ['CREATE_CSV_TRANSLATION_REQUEST_INFO', 'Created translation request info i.e payload, git_commit info']
        ]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :repository_name,
                                       env_name: "FL_CREATE_CSV_TRANSLATION_REQUEST_REPOSITORY_NAME",
                                       description: "The name to your repository, e.g. 'fastlane/fastlane'",
                                       verify_block: proc do |value|
                                         UI.user_error!("No repository_name given in input param") unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :branch_name,
                                       env_name: "FL_CREATE_CSV_TRANSLATION_REQUEST_BRANCH_NAME",
                                       description: "The branch name to your repository, (default master)",
                                       is_string: true,
                                       default_value: "master"),
          FastlaneCore::ConfigItem.new(key: :feature_branch_name,
                                       env_name: "FL_CREATE_CSV_TRANSLATION_REQUEST_FEATURE_BRANCH_NAME",
                                       description: "The feature branch name for new translation request (Useful if no direct commit allowed in master)",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :file_path,
                                       env_name: "FL_CREATE_CSV_TRANSLATION_REQUEST_FILE_PATH",
                                       description: "The file path to your csv file",
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :payload,
                                       env_name: "FL_CREATE_CSV_TRANSLATION_REQUEST_PAYLOAD",
                                       description: "CSV request info. payload must be a hash containing CSV header key with value",
                                       is_string: false)
        ]
      end

      def self.authors
        ["crazymanish"]
      end

      def self.example_code
        [
          'create_csv_translation_request(
            repository_name: "fastlane/fastlane",
            file_path: "translation/some_csv_name.csv",
            payload: {header_name: "some_value"})',
          'create_csv_translation_request(
            repository_name: "fastlane/fastlane",
            branch_name: "master",
            file_path: "translation/some_csv_name.csv",
            payload: {header_name: "some_value"})'
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
