# encoding: UTF-8

require 'commander/import'
require './lib/drawnapart'
require 'open4'
require 'colorize'

# The Commander gem requires these settings even though we
# just use its `ask_editor` command.
#
program :name, 'DrawnApart rake commands'
program :version, '1.0.0'
program :description, 'There is no description here'
default_command :nothing
command :nothing do |c| end

namespace :mt do

  desc "Runs mt:clean mt:tag mt:archive:appstore."
  task :appstore do
    Rake::Task['mt:clean'].invoke 'Release'
    Rake::Task['mt:tag'].invoke
    Rake::Task['mt:archive:appstore'].invoke
  end

  desc "Create an archive."
  task :archive do
    DrawnApart::Build.archive({for_appstore?: false})
  end

  namespace :archive do
    desc "Create an archive with APPSTORE=1."
    task :appstore do
      DrawnApart::Build.archive({for_appstore?: true})
    end

    desc "Create an archive with β appended to version."
    task :beta do
      DrawnApart::Build.archive({beta: true, for_appstore?: false})
    end
  end

  desc "Build the project."
  task :build, :configuration do |t, args|
    DrawnApart::Build.build for_appstore?: false, configuration: args[:configuration] || 'Debug'
  end

  namespace :build do
    desc "Build the project with APPSTORE=1, configuration=Release."
    task :appstore do
      DrawnApart::Build.build for_appstore?: true, configuration: 'Release'
    end
  end

  desc "Clean build products."
  task :clean, :configuration do |t, args|
    DrawnApart::Build.clean configuration: args[:configuration]
  end

  desc "Create .ipa file from existing .app."
  task :package do
    DrawnApart::Build.package
  end

  desc "Creates a new git tag from info.plist"
  task :tag do
    tag_name = DrawnApart::Build.tag
  end

  desc "Clean, archive, package, and distribute to TestFlight."
  task :testflight do
      notes = ask_editor "Release notes:\n\n"
      %x(echo "#{notes}" | pbcopy)
      Rake::Task['mt:clean'].invoke 'Release'
      Rake::Task['mt:archive:beta'].invoke
      Rake::Task['mt:package'].invoke
      DrawnApart::Build.testflight notify: true, notes: notes
  end

  namespace :testflight do
    desc "Clean, archive, package, and distribute to TestFlight but do not send notification emails."
    task :quiet do
      notes = ask_editor "Release notes:\n\n"
      %x(echo "#{notes}" | pbcopy)
      Rake::Task['mt:clean'].invoke 'Release'
      Rake::Task['mt:archive:beta'].invoke
      Rake::Task['mt:package'].invoke
      DrawnApart::Build.testflight notify: false, notes: notes
    end
  end

end
