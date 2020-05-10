require 'fastlane/action'
require_relative '../helper/csv_translation_helper'

module Fastlane
  module Actions
    module SharedValues
      GET_CSV_TRANSLATION_REQUESTS_INFO = :GET_CSV_TRANSLATION_REQUESTS_INFO
    end

    class GetCsvTranslationRequestsAction < Action
      def self.run(params)
        # fetching csv file
        csv_file_folder = Helper::CsvTranslationHelper.fetch_csv_file(
          repository_name: params[:repository_name],
          branch_name: params[:branch_name]
        )

        require 'csv'

        # reading csv file
        csv_file_path = "#{csv_file_folder}/#{params[:file_path]}"
        UI.success("Reading csv file from: #{csv_file_path} 🖥")
        translation_requests = CSV.foreach(csv_file_path, headers: true).map { |row| row.to_h }

        if params[:show_status]
          require 'terminal-table'

          # printing csv file translation status
          headers = CSV.open(csv_file_path, &:readline)

          csv_row_identifier = params[:identifier].strip
          unless csv_row_identifier.empty?
            translation_requests = translation_requests.select do |translation_request|
              translation_request.map { |value| value.to_s }.join("").include?(csv_row_identifier)
            end
          end

          printing_translation_requests = translation_requests.map do |translation_request|
            translation_request.map do |key, value|
              if key.to_s.match?(params[:show_headers])
                value
              else
                value.to_s.empty? ? "❌": "✅"
              end
            end
          end
          table = Terminal::Table.new(title: "Translation status", headings: headers, rows: printing_translation_requests)
          puts table
        end

        Actions.lane_context[SharedValues::GET_CSV_TRANSLATION_REQUESTS_INFO] = translation_requests
        return translation_requests
      end

      def self.description
        "Get CSV translation requests info"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :repository_name,
                                       env_name: "FL_GET_CSV_TRANSLATION_REQUESTS_REPOSITORY_NAME",
                                       description: "The name to your repository, e.g. 'fastlane/fastlane'",
                                       verify_block: proc do |value|
                                         UI.user_error!("No repository_name given in input param") unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :branch_name,
                                       env_name: "FL_GET_CSV_TRANSLATION_REQUESTS_BRANCH_NAME",
                                       description: "The branch name to your repository, (default master)",
                                       is_string: true,
                                       default_value: "master"),
          FastlaneCore::ConfigItem.new(key: :file_path,
                                       env_name: "FL_GET_CSV_TRANSLATION_REQUESTS_FILE_PATH",
                                       description: "The file path to your csv file",
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :show_status,
                                       env_name: "FL_GET_CSV_TRANSLATION_REQUESTS_SHOW_STATUS",
                                       description: "The flag whether to show the translation status, (default 'true')",
                                       optional: true,
                                       default_value: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :show_headers,
                                       env_name: "FL_GET_CSV_TRANSLATION_REQUESTS_SHOW_HEADERS",
                                       description: "Show CSV headers translation value while printing, (default 'Ticket|Timeline')",
                                       is_string: true,
                                       default_value: "Ticket|Timeline"),
          FastlaneCore::ConfigItem.new(key: :identifier,
                                       env_name: "FL_GET_CSV_TRANSLATION_REQUESTS_IDENTIFIER",
                                       description: "An identifier value of the CSV file row",
                                       is_string: true,
                                       optional: true,
                                       default_value: "")
        ]
      end

      def self.authors
        ["crazymanish"]
      end

      def self.example_code
        [
          'get_csv_translation_requests(
            repository_name: "fastlane/fastlane",
            file_path: "translation/some_csv_name.csv")',
          'get_csv_translation_requests(
            repository_name: "fastlane/fastlane",
            branch_name: "master",
            file_path: "translation/some_csv_name.csv")'
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
