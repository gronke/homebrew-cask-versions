cask "parallels14" do
  version "14.1.3-45485"
  sha256 "34c9c345642fa30f9d240a76062c5672e399349d5e5984db9c208d22e099f8b9"

  url "https://download.parallels.com/desktop/v#{version.major}/#{version}/ParallelsDesktop-#{version}.dmg"
  name "Parallels Desktop"
  desc "Desktop virtualization software"
  homepage "https://www.parallels.com/products/desktop/"

  livecheck do
    url "https://kb.parallels.com/en/124521"
    regex(/(v?\d+(?:\.\d+)+\s*\(\d+\)|\(v?\d+(?:\.\d+)+-\d+\))/i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match| match.first.strip.tr("()", "").gsub(/\s+/, "-") }
    end
  end

  auto_updates true
  conflicts_with cask: [
    "parallels",
    "homebrew/cask-versions/parallels12",
    "homebrew/cask-versions/parallels13",
    "homebrew/cask-versions/parallels15",
    "homebrew/cask-versions/parallels16",
  ]
  depends_on macos: [
    :el_capitan,
    :sierra,
    :high_sierra,
    :mojave,
  ]
  # This .dmg cannot be extracted normally
  # Original discussion: https://github.com/Homebrew/homebrew-cask/pull/67202
  container type: :naked

  preflight do
    system_command "/usr/bin/hdiutil",
                   args: ["attach", "-nobrowse", "#{staged_path}/ParallelsDesktop-#{version}.dmg"]
    system_command "/Volumes/Parallels Desktop #{version.major}/Parallels Desktop.app/Contents/MacOS/inittool",
                   args: ["install", "-t", "#{appdir}/Parallels Desktop.app", "-s"],
                   sudo: true
    system_command "/usr/bin/hdiutil",
                   args: ["detach", "/Volumes/Parallels Desktop #{version.major}"]
  end

  postflight do
    # Unhide the application
    system_command "/usr/bin/chflags",
                   args: ["nohidden", "#{appdir}/Parallels Desktop.app"],
                   sudo: true

    # Run the initialization script
    system_command "#{appdir}/Parallels Desktop.app/Contents/MacOS/inittool",
                   args: ["init", "-b", "#{appdir}/Parallels Desktop.app"],
                   sudo: true
  end

  uninstall_preflight do
    set_ownership "#{appdir}/Parallels Desktop.app"
  end

  uninstall delete: [
    "/usr/local/bin/prl_convert",
    "/usr/local/bin/prl_disk_tool",
    "/usr/local/bin/prl_perf_ctl",
    "/usr/local/bin/prlcore2dmp",
    "/usr/local/bin/prlctl",
    "/usr/local/bin/prlexec",
    "/usr/local/bin/prlsrvctl",
    "/Applications/Parallels Desktop.app",
    "/Applications/Parallels Desktop.app/Contents/Applications/Parallels Link.app",
    "/Applications/Parallels Desktop.app/Contents/Applications/Parallels Mounter.app",
    "/Applications/Parallels Desktop.app/Contents/Applications/Parallels Technical Data Reporter.app",
    "/Applications/Parallels Desktop.app/Contents/MacOS/Parallels Service.app",
    "/Applications/Parallels Desktop.app/Contents/MacOS/Parallels VM.app",
  ]

  zap trash: [
    "~/.parallels_settings",
    "~/Library/Caches/com.parallels.desktop.console",
    "~/Library/Preferences/com.parallels.desktop.console.LSSharedFileList.plist",
    "~/Library/Preferences/com.parallels.desktop.console.plist",
    "~/Library/Preferences/com.parallels.Parallels Desktop Statistics.plist",
    "~/Library/Preferences/com.parallels.Parallels Desktop.plist",
    "~/Library/Preferences/com.parallels.Parallels.plist",
  ]
end
