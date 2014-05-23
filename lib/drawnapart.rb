# encoding: UTF-8

require 'cfpropertylist'
require 'pty'

module DrawnApart
  module Build

    def self.add_beta_to_version
      %x(sed -i "" -E 's/>#{self.current_version}/&β/g' #{self.info_plist_file})
      yield
      %x(git checkout #{DrawnApart::Build.info_plist_file})
    end

    def self.archive(params = {})
      say_ok "Archiving..."
      params = {build_action: 'archive', configuration: 'Release', settings: %Q(GCC_PREPROCESSOR_DEFINITIONS="\\$(inherited) #{params.delete(:for_appstore?) ? "APPSTORE=1" : ""}"), redirect_output: true}.merge!(params)
      say_error "You have local changes. Please commit your changes before building." and abort if self.local_changes?
      if (params[:beta])
        DrawnApart::Build.add_beta_to_version do
          say_error "Build error." and self.git_reset_hard and abort if xctool(params) == false
        end
      else
        say_error "Build error." and self.git_reset_hard and abort if xctool(params) == false
      end
      say_error "Archive output looks wrong." and abort if self.post_archive_checks == false
      say_ok "Archive successful. File at #{latest_xcarchive}\n"
    end

    def self.build(params = {})
      say_ok "Building..."
      params = {build_action: 'build', settings: %Q(GCC_PREPROCESSOR_DEFINITIONS="\\$(inherited) #{params.delete(:for_appstore?) ? "APPSTORE=1" : ""}"), redirect_output: true}.merge!(params)
      say_error "You have local changes. Please commit your changes before building." and abort if self.local_changes?
      say_error "Build error." and self.git_reset_hard and abort if xctool(params) == false
      say_ok "Build successful.\n"
    end

    def self.clean(params = {})
      say_ok "Cleaning..."
      params = {build_action: 'clean', redirect_output: true, settings: 'ONLY_ACTIVE_ARCH=NO'}.merge!(params)
      say_error "You have local changes. Please commit your changes before building." and abort if self.local_changes?
      say_error "Error." and abort if xctool(params) == false
      say_ok "Clean successful.\n"
    end

    def self.git_reset_hard
      %x(git reset --hard)
    end

    def self.package
      say_ok "Packaging..."
      out = "/tmp/mt_lastbuild.log"
      # xctool does not yet support the `-export*` options of xcodebuild, so we use xcodebuild here. https://github.com/facebook/xctool/issues/242
      invocation = %Q(xcodebuild -exportArchive -exportFormat IPA -archivePath "#{latest_xcarchive}" -exportPath "#{latest_ipa}" -exportProvisioningProfile "#{provisioning_profile_name}" >> #{out} 2>&1)
      puts ".app location: ".bold + latest_app
      puts ".ipa destination: ".bold + "#{latest_ipa}"
      puts "Invocation: ".bold + "#{invocation}\n"

      %x(rm #{latest_ipa}) if File.exists? latest_ipa # `xcodebuild -exportArchive` will fail if the file at `-exportPath` already exists.
      %x(#{invocation})

      say_error "Packaging error. Check log #{out}\n" and git_reset_hard and abort if $? != 0
      say_ok "Packaging successful. File at #{latest_ipa}\n"
    end

    def self.tag
      tag_name = current_tag_name

      puts "This will create the tag, " + tag_name.red + ". OK? (y/N):"
      ok = STDIN.gets.chomp

      say_error "Jumping ship" and abort if ok.downcase != "y"

      %x(git tag #{tag_name})
      %x(git push --tags)
    end

    def self.testflight(params)
      say_ok "Distributing to TestFlight..."
      unless ENV['MT_TF_API_TOKEN'] and ENV['MT_TF_TEAM_TOKEN']
        puts "Please define the environment variables MT_TF_TEAM_TOKEN and MT_TF_API_TOKEN".red
        puts "\nTo get the team token, go to https://testflightapp.com/dashboard/team/edit/"
        puts "\nTo get the API token, go to https://testflightapp.com/account/#api"
        abort
      end

      say_error "You have local changes. Please commit your changes before building." and abort if self.local_changes?

      out = "/tmp/mt_lastbuild.log"
      invocation = %Q(ipa distribute --lists "Betas" #{params[:notify] ? '--notify' : ''} --replace --api_token #{ENV['MT_TF_API_TOKEN']} --team_token #{ENV['MT_TF_TEAM_TOKEN']} --notes "#{params[:notes]}" --file "#{latest_ipa}" >> #{out} 2>&1)
      puts ".ipa destination: ".bold + "#{latest_ipa}"
      puts "Invocation: ".bold + "#{invocation}\n"

      %x(#{invocation})

      say_error "Testfight distribution error. Check log #{out}\n" and abort if $? != 0
      say_ok "TestFlight distribution successful.\n"
    end

    private

    def self.current_tag_name
      version = self.info_plist["CFBundleShortVersionString"]

      tag = "rb"
      if tag
        "#{tag}-#{version}"
      else
        abort "Tag failed"
      end
    end

    def self.current_version
      self.info_plist["CFBundleShortVersionString"]
    end

    def self.info_plist
      plist = CFPropertyList::List.new(:file => self.info_plist_file)
      CFPropertyList.native_types(plist.value)
    end

    def self.info_plist_file
      "./#{self.scheme}/#{self.scheme}-Info.plist"
    end

    def self.latest_app
      "#{latest_xcarchive}/Products/Applications/#{self.product_name}.app"
    end

    def self.latest_dsym
      "#{latest_xcarchive}/dSYMs/#{self.product_name}.app.dSYM"
    end

    def self.latest_ipa
      "#{Dir.pwd}/#{self.scheme}.ipa"
    end

    def self.latest_xcarchive
      todays_dir = "#{ENV['HOME']}/Library/Developer/Xcode/Archives/#{Time.now.strftime("%Y-%m-%d")}"
      (todays_dir + "/" + %x(/bin/ls -t #{todays_dir} | /usr/bin/egrep "#{self.scheme}.*xcarchive" | /usr/bin/sed -n 1p)).strip
    end

    def self.local_changes?
      return true if %x(git diff --numstat | wc -l).to_i > 0
      return true if %x(git diff --cached --numstat | wc -l).to_i> 0

      return false
    end

    def self.post_archive_checks
      File.exists?(latest_xcarchive) && File.exists?(latest_dsym) && File.exists?(latest_app)
    end

    def self.product_name
      "Drawn Apart"
    end

    def self.provisioning_profile_name
      "Spangle Ad Hoc"
    end

    def self.scheme
      "DrawnApart"
    end

    def self.xctool(params)
      invocation = %Q(xctool
        -workspace DrawnApart.xcworkspace
        -scheme "#{self.scheme}"
        -configuration #{params[:configuration] || 'Debug'}
        #{params[:options]}
        #{params[:plain_output] ? '-reporter plain' : ''}
        #{params[:build_action]}
        #{params[:settings]}).gsub(/\s{2,}/, ' ')
        #
      invocation << ">> /tmp/mt_lastbuild.log 2>&1" if params[:redirect_output]

      puts "Invocation: ".bold + "#{invocation}\n"

      last_line, previous_line = '', ''

      if params[:redirect_output]
        %x(#{invocation})
      else
        PTY.spawn(invocation) do |stdin, stdout, pid|
          stdin.each do |line|
            previous_line, last_line = last_line, line # remember two last lines
            print line
          end
          Process.wait(pid)
        end
      end

      if $? != 0
        return false
      end

      true
    end

  end
end
