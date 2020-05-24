require 'fastlane/action'
require_relative '../helper/csv_translation_helper'

module Fastlane
  module Actions
    module SharedValues
      REBASE_CSV_TRANSLATION_REQUEST_INFO = :REBASE_CSV_TRANSLATION_REQUEST_INFO
    end

    class RebaseCsvTranslationRequestAction < Action
      def self.run(params)
        # fetching csv file
        csv_file_folder = Helper::CsvTranslationHelper.fetch_csv_file(
          repository_name: params[:repository_name],
          branch_name: params[:feature_branch_name]
        )

        csv_file_path = "#{csv_file_folder}/#{params[:file_path]}"
        csv_row_identifier = params[:identifier]

        require 'csv'

        # picking translation request-identifier entry from the feature_branch csv file
        feature_branch_translation_requests = CSV.table(csv_file_path, headers: true)
        feature_branch_translation_requests = feature_branch_translation_requests.select { |row| row.map { |value| value.to_s }.join("").include?(csv_row_identifier) }

        # rebasing CSV file
        git_commit_info = {}
        Dir.chdir(csv_file_folder) do
          # Step1: Checkout the target branch csv file
          sh("git fetch --all")
          sh("git checkout #{params[:branch_name]} -- #{params[:file_path]}")

          # Validate: Do we really need to perfoem `rebase` ?
          repo_status = Actions::sh("git status --porcelain")
          repo_clean = repo_status.empty?

          if repo_clean
            UI.important("Rebase is not required, CSV file is up to date! 💪")
          else
            git_commit_info = self.perform_rebase(params, csv_file_path, feature_branch_translation_requests)
          end
        end

        # building deleted translation request info
        rebase_translation_request_info = {
          identifier: csv_row_identifier,
          git_commit_info: git_commit_info}

        Actions.lane_context[SharedValues::REBASE_CSV_TRANSLATION_REQUEST_INFO] = rebase_translation_request_info
        return rebase_translation_request_info
      end

      def self.perform_rebase(params, csv_file_path, feature_branch_translation_requests)
        csv_row_identifier = params[:identifier]

        # Step2: Commit csv file so rebase can be performed
        git_message = "Rebase translation request: identifier:\n#{csv_row_identifier}"
        GitCommitAction.run(path: ".", message: git_message)

        # Step3: Perfoms rebasing, take all changes from target branch
        sh("git rebase -X theirs " + params[:branch_name])

        # Step4: Add missing newline if not present, at the end of the file
        Helper::CsvTranslationHelper.append_missing_eof(csv_file_path)

        # Step5: Append back feature branch translation_requests
        all_translation_requests = CSV.table(csv_file_path, headers: true)
        all_translation_requests.delete_if { |row| row.map { |value| value.to_s }.join("").include?(csv_row_identifier) }

        headers = CSV.open(csv_file_path, &:readline)
        CSV.open(csv_file_path, "w", write_headers: true, headers: headers, force_quotes: true) do |csv|
          all_translation_requests.each { |translation_request| csv << translation_request }
          feature_branch_translation_requests.each { |translation_request| csv << translation_request }
        end

        # Step6: Commit and push to remote
        GitCommitAction.run(path: ".", message: git_message)
        PushToGitRemoteAction.run(remote: "origin", force: true)

        UI.success("Successfully #{git_message} 🚀")
        Actions.last_git_commit_dict
      end

      def self.description
        "Rebase a translation request based on identifier value."
      end

      def self.output
        [
          ['REBASE_CSV_TRANSLATION_REQUEST_INFO', 'Rebased translation request info i.e identifier, git_commit info']
        ]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :repository_name,
                                       env_name: "FL_REBASE_CSV_TRANSLATION_REQUEST_REPOSITORY_NAME",
                                       description: "The name to your repository, e.g. 'fastlane/fastlane'",
                                       verify_block: proc do |value|
                                         UI.user_error!("No repository_name given in input param") unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :branch_name,
                                       env_name: "FL_REBASE_CSV_TRANSLATION_REQUEST_BRANCH_NAME",
                                       description: "The branch name to your repository, (default master)",
                                       is_string: true,
                                       default_value: "master"),
          FastlaneCore::ConfigItem.new(key: :feature_branch_name,
                                       env_name: "FL_REBASE_CSV_TRANSLATION_REQUEST_FEATURE_BRANCH_NAME",
                                       description: "The feature branch name for new translation request (Useful if no direct commit allowed in master)",
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :file_path,
                                       env_name: "FL_REBASE_CSV_TRANSLATION_REQUEST_FILE_PATH",
                                       description: "The file path to your csv file",
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :identifier,
                                       env_name: "FL_REBASE_CSV_TRANSLATION_REQUEST_IDENTIFIER",
                                       description: "An identifier value of the CSV file row",
                                       is_string: true)
        ]
      end

      def self.authors
        ["crazymanish"]
      end

      def self.example_code
        [
          'rebase_csv_translation_request(
            repository_name: "fastlane/fastlane",
            feature_branch_name: "some_feature_branch",
            file_path: "translation/some_csv_name.csv",
            identifier: "some_identifier_value")',
          'rebase_csv_translation_request(
            repository_name: "fastlane/fastlane",
            branch_name: "master",
            feature_branch_name: "some_feature_branch",
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
