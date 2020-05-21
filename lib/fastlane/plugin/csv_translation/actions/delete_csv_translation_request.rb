require 'fastlane/action'
require_relative '../helper/csv_translation_helper'

module Fastlane
  module Actions
    module SharedValues
      DELETE_CSV_TRANSLATION_REQUEST_INFO = :DELETE_CSV_TRANSLATION_REQUEST_INFO
    end

    class DeleteCsvTranslationRequestAction < Action
      def self.run(params)
        # fetching csv file
        csv_file_folder = Helper::CsvTranslationHelper.create_feature_branch(
          repository_name: params[:repository_name],
          branch_name: params[:branch_name],
          feature_branch_name: params[:feature_branch_name]
        )

        csv_file_path = "#{csv_file_folder}/#{params[:file_path]}"
        csv_row_identifier = params[:identifier]

        # deleting translation request entry from the csv file
        require 'csv'

        headers = CSV.open(csv_file_path, &:readline)
        translation_requests = CSV.table(csv_file_path, headers: true)
        translation_requests.delete_if { |row| row.map { |value| value.to_s }.join("").include?(csv_row_identifier) }

        CSV.open(csv_file_path, "w", write_headers: true, headers: headers, force_quotes: true) do |csv|
          translation_requests.each { |translation_request| csv << translation_request }
        end

        # deleting translation request from server
        git_commit_info = {}
        Dir.chdir(csv_file_folder) do
          # checking git status for modified files.
          git_status = Actions::sh("git status --porcelain")
          is_git_status_clean = git_status.empty?

          # log message if translation request not found.
          if is_git_status_clean
            UI.important("Please check \"#{csv_row_identifier}\", not found the translation request. ⁉️")
          else
            git_message = "Deleted translation request: identifier: #{csv_row_identifier}"
            GitCommitAction.run(path: ".", message: git_message)
            PushToGitRemoteAction.run(remote: "origin")
            git_commit_info = Actions.last_git_commit_dict

            UI.success("Successfully #{git_message} 🚀")
          end
        end

        # building deleted translation request info
        deleted_translation_request_info = {
          identifier: csv_row_identifier,
          git_commit_info: git_commit_info}

        Actions.lane_context[SharedValues::DELETE_CSV_TRANSLATION_REQUEST_INFO] = deleted_translation_request_info
        return deleted_translation_request_info
      end

      def self.description
        "Delete a translation request based on identifier value."
      end

      def self.output
        [
          ['DELETE_CSV_TRANSLATION_REQUEST_INFO', 'Deleted translation request info i.e identifier, git_commit info']
        ]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :repository_name,
                                       env_name: "FL_DELETE_CSV_TRANSLATION_REQUEST_REPOSITORY_NAME",
                                       description: "The name to your repository, e.g. 'fastlane/fastlane'",
                                       verify_block: proc do |value|
                                         UI.user_error!("No repository_name given in input param") unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :branch_name,
                                       env_name: "FL_DELETE_CSV_TRANSLATION_REQUEST_BRANCH_NAME",
                                       description: "The branch name to your repository, (default master)",
                                       is_string: true,
                                       default_value: "master"),
          FastlaneCore::ConfigItem.new(key: :feature_branch_name,
                                       env_name: "FL_DELETE_CSV_TRANSLATION_REQUEST_FEATURE_BRANCH_NAME",
                                       description: "The feature branch name for new translation request (Useful if no direct commit allowed in master)",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :file_path,
                                       env_name: "FL_DELETE_CSV_TRANSLATION_REQUEST_FILE_PATH",
                                       description: "The file path to your csv file",
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :identifier,
                                       env_name: "FL_DELETE_CSV_TRANSLATION_REQUEST_IDENTIFIER",
                                       description: "An identifier value of the CSV file row",
                                       is_string: true)
        ]
      end

      def self.authors
        ["crazymanish"]
      end

      def self.example_code
        [
          'delete_csv_translation_request(
            repository_name: "fastlane/fastlane",
            file_path: "translation/some_csv_name.csv",
            identifier: "some_identifier_value")',
          'delete_csv_translation_request(
            repository_name: "fastlane/fastlane",
            branch_name: "master",
            file_path: "translation/some_csv_name.csv",
            identifier: "some_identifier_value")'
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
