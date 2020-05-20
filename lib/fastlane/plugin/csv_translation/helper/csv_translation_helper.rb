require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class CsvTranslationHelper

      def self.csv_file_directory_name
        return ".fl_clone_csv_file"
      end

      def self.fetch_csv_file(params)
        repository_name = params[:repository_name]
        branch_name = params[:branch_name]
        csv_file_directory_name = params[:directory_name] || self.csv_file_directory_name

        # Setup csv_file folder for fresh git clone.
        git_clone_folder = File.join(Dir.pwd, csv_file_directory_name)
        FileUtils.rm_rf(git_clone_folder) if File.directory?(git_clone_folder)
        Dir.mkdir(csv_file_directory_name)

        UI.success("Fetching csv file from git repo... ⏳")
        branch_option = "--branch #{branch_name}" if branch_name != 'HEAD'
        git_url = "git@github.com:#{repository_name}"
        Fastlane::Actions::sh("git clone #{git_url.shellescape} #{git_clone_folder.shellescape} --depth 1 -n #{branch_option}")
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

    end
  end
end
