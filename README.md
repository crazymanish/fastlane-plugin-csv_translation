# Fastlane `csv_translation` plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-csv_translation)  [![Gem Version](https://badge.fury.io/rb/fastlane-plugin-csv_translation.svg)](https://badge.fury.io/rb/fastlane-plugin-csv_translation)  [![Twitter: @manish](https://img.shields.io/badge/contact-@manish-blue.svg?style=flat)](https://twitter.com/manish_rathi_)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-csv_translation`, add it to your project by running:

```bash
fastlane add_plugin csv_translation
```

## About csv_translation

A fastlane plugin to manage translation using a CSV file under git repository. 🚀

This plugin is inspired by and based on [Keep a CSV](https://en.wikipedia.org/wiki/Comma-separated_values) under git repository. This CSV file can contains translated details for different locales, which can be defined as CSV headers.
This plugin opens up an opportunity to automate reading from/writing of any `CSV` file with [`fastlane`](https://fastlane.tools). 

## CSV file (Example)
`CSV` file must have locale headers, and can have one identifier header. i.e Below CSV supports `"en-US","nl-NL","de-DE","fr-FR","it","es-ES","pt-PT","da","sv","no","zh-Hans","zh-Hant"` and `Ticket` column is the unique identifier column which later will be useful to a delete CSV row 

<img width="1476" alt="Example CSV" src="https://user-images.githubusercontent.com/5364500/81500222-fe912780-92d0-11ea-87a7-952a78b5cdf7.png">


## Example

You have to **remember to keep your release notes CSV file up-to-date** with translation and let [`fastlane`](https://fastlane.tools) do the rest. 

``` ruby
desc "Release a iOS appstore build to AppStore iTunesConnect with translated release notes."
lane :release do
  gym # Build the app and create .ipa file
  
  version_number = get_version_number # Get project version
  
  # Get translated release notes
  release_notes = get_csv_translation_requests(
                    repository_name: "repo_owner/repo",
                    file_path: "release_notes/#{version_number}.csv"
                  )

  # TODO: Inject release notes into fastlane meta-data

  deliver # Upload ipa file to iTunesConnect with localized release notes `meta-data`
  
  slack(message: "Hi team, New version #{version_number} is avaliable!) # share on Slack
end
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
