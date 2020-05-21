require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class CsvTranslationHelper

      def self.csv_file_directory_name
        return ".fl_clone_csv_file"
      end

      def self.csv_file_directory_path
        return File.join(Dir.pwd, self.csv_file_directory_name)
      end

      def self.fetch_csv_file(params)
        repository_name = params[:repository_name]
        branch_name = params[:branch_name]

        # Setup csv_file folder for fresh git clone.
        git_clone_folder = self.csv_file_directory_path
        FileUtils.rm_rf(git_clone_folder) if File.directory?(git_clone_folder)
        Dir.mkdir(self.csv_file_directory_name)

        UI.success("Fetching csv file from git repo... ⏳")
        git_url = "git@github.com:#{repository_name}"
        Fastlane::Actions::sh("git clone #{git_url.shellescape} #{git_clone_folder.shellescape}")
        Fastlane::Actions::sh("cd #{git_clone_folder.shellescape} && git checkout #{branch_name}")

        return git_clone_folder
      end

      def self.create_feature_branch(params)
        git_clone_folder = self.fetch_csv_file(params)

        # creating and checkout new branch
        branch_name = params[:feature_branch_name]
        Fastlane::Actions::sh("cd #{git_clone_folder.shellescape} && git checkout -b #{branch_name}")

        # pushing newly created branch
        Fastlane::Actions::sh("cd #{git_clone_folder.shellescape} && git push -u origin #{branch_name}")

        return git_clone_folder
      end

      # add missing newline if not present, at the end of the file
      def self.append_missing_eof(file_path)
        File.open(file_path, "r+") do |file|
          file.seek(-1, 2)

          if file.read(1) != "\n"
            file.write("\n")
            file.seek(0)
          end
        end
      end

    end
  end
end
