class Powerline < Formula
  homepage "https://github.com/powerline/fontpatcher"
  url "https://github.com/powerline/fontpatcher/archive/18a788b8ec1822095813b73b0582a096320ff714.zip"
  sha256 "c50a9c9a94e7b5a3f0cd0c149c5c394684c8b9b63e049a9277500286921c29ce"
  version "20150113"
  def initialize(name = "powerline", path = Pathname(__FILE__), spec = "stable")
    super
  end
  patch :DATA
end

class Ricty < Formula
  homepage "http://www.rs.tus.ac.jp/yyusa/ricty.html"
  url "http://www.rs.tus.ac.jp/yyusa/ricty/ricty_generator.sh"
  version "4.1.0"
  sha256 "6e2b656814ffdad5430f9c52bff89609b1350de1127f61966cdf441710ec60b3"
  revision 1

  option "powerline", "Patch for Powerline"
  option "vim-powerline", "Patch for Powerline from vim-powerline"
  option "disable-fullwidth", "Disable fullwidth ambiguous characters"
  option "disable-visible-space", "Disable visible zenkaku space"
  option "patch-in-place", "Patch Powerline glyphs directly into Ricty fonts without creating new 'for Powerline' fonts"

  depends_on "fontforge"

  resource "inconsolataregular" do
    url "https://github.com/google/fonts/raw/c6c7e432a29bd7c817feed0963f568a6d710625c/ofl/inconsolata/Inconsolata-Regular.ttf"
    sha256 "346eff8b8292ef2b8026cf1dbea3fc0c79eba444270d38d73da895ddcba74e15"
  end

  resource "inconsolatabold" do
    url "https://github.com/google/fonts/raw/c6c7e432a29bd7c817feed0963f568a6d710625c/ofl/inconsolata/Inconsolata-Bold.ttf"
    sha256 "0db9dc0cf39efef147a7b368c98e1b7588afd2bc4d30e4c9e313f5511e599a87"
  end

  resource "migu1mfonts" do
    url "https://osdn.jp/frs/redir.php?m=gigenet&f=%2Fmix-mplus-ipa%2F63545%2Fmigu-1m-20150712.zip"
    sha256 "d4c38664dd57bc5927abe8f4fbea8f06a8ece3fea49ea02354d4e03ac6d15006"
  end

  resource "vimpowerline" do
    url "https://github.com/Lokaltog/vim-powerline/archive/09c0cea859.tar.gz"
    sha256 "dde995aaf8e7f4a8d9ea3a9d34e55d760e4979314ff8c1bf0f6e25caf606b3b0"
    version "20120817"
  end

  def install
    share_fonts = share + "fonts"
    powerline_script = []

    resource("migu1mfonts").stage { share_fonts.install Dir["*"] }
    if build.include? "powerline"
      powerline = Powerline.new
      powerline.brew { buildpath.install Dir["*"] }
      powerline.patch
      powerline_script << buildpath + "scripts/powerline-fontpatcher"
      rename_from = "(Ricty|Discord)-?"
      rename_to = "\\1 "
    end
    if build.include?("vim-powerline") && !(build.include?("powerline") && build.include?("patch-in-place"))
      resource("vimpowerline").stage { buildpath.install "fontpatcher" }
      powerline_script << buildpath + "fontpatcher/fontpatcher"
      rename_from = "\.ttf"
      rename_to = "-Powerline.ttf"
    end
    resource("inconsolataregular").stage { share_fonts.install Dir["*"] }
    inconsolataregularttf = share_fonts + "Inconsolata-Regular.ttf"
    resource("inconsolatabold").stage { share_fonts.install Dir["*"] }
    inconsolataboldttf = share_fonts + "Inconsolata-Bold.ttf"

    ricty_args = [inconsolataregularttf, inconsolataboldttf, share_fonts + "migu-1m-regular.ttf", share_fonts + "migu-1m-bold.ttf"]
    ricty_args.unshift("-z") if build.include? "disable-visible-space"
    ricty_args.unshift("-a") if build.include? "disable-fullwidth"

    powerline_args = []
    powerline_args.unshift("--no-rename") if build.include? "patch-in-place"

    system "sh", "./ricty_generator.sh", *ricty_args

    ttf_files = Dir["Ricty*.ttf"]
    if build.include?("powerline") || build.include?("vim-powerline")
      powerline_script.each do |script|
        ttf_files.each do |ttf|
          system "fontforge -lang=py -script #{script} #{powerline_args.join(' ')} #{ttf}"
          mv ttf.gsub(/#{rename_from}/, rename_to), ttf if build.include? "patch-in-place"
        end
      end
    end
    share_fonts.install Dir["Ricty*.ttf"]
  end

  def caveats; <<-EOS.undent
    ***************************************************
    Generated files:
      #{Dir[share + "fonts/Ricty*.ttf"].join("\n      ")}
    ***************************************************
    To install Ricty:
      $ cp -f #{share}/fonts/Ricty*.ttf ~/Library/Fonts/
      $ fc-cache -vf
    ***************************************************
    EOS
  end

  test do
    system "false"
  end
end

__END__
diff --git a/scripts/powerline-fontpatcher b/scripts/powerline-fontpatcher
index ed2bc65..094c974
--- a/scripts/powerline-fontpatcher
+++ b/scripts/powerline-fontpatcher
@@ -73,0 +74,7 @@ class FontPatcher(object):
+				# Ignore the above calculation and
+				# manually set the best values for Ricty
+				target_bb[0]=0
+				target_bb[1]=-525
+				target_bb[2]=1025
+				target_bb[3]=1650
+
