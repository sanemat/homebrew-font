class Powerline < Formula
  homepage "https://github.com/powerline/fontpatcher"
  url "https://github.com/powerline/fontpatcher/archive/c3488091611757cb02014ed7ed2f11be0208da83.zip"
  sha256 "bf736ea3d18395ba197a492fc8b0ddb47b44142e101b6c780b2a8380503d5a36"
  version "20160320"
  def initialize(name = "powerline", path = Pathname(__FILE__), spec = "stable")
    super
  end
  patch :DATA
end

class Ricty < Formula
  desc "Font for programming"
  homepage "http://www.rs.tus.ac.jp/yyusa/ricty.html"
  url "http://www.rs.tus.ac.jp/yyusa/ricty/ricty_generator-4.1.0.sh"
  sha256 "6e2b656814ffdad5430f9c52bff89609b1350de1127f61966cdf441710ec60b3"
  revision 2

  option "with-powerline", "Patch for Powerline"
  option "without-fullwidth", "Disable fullwidth ambiguous characters"
  option "without-visible-space", "Disable visible zenkaku space"
  option "with-patch-in-place", "Patch Powerline glyphs directly into Ricty fonts without creating new 'for Powerline' fonts"
  option "with-oblique", "make oblique fonts"

  deprecated_option "powerline" => "with-powerline"
  deprecated_option "disable-fullwidth" => "without-fullwidth"
  deprecated_option "disable-visible-space" => "without-visible-space"
  deprecated_option "patch-in-place" => "with-patch-in-place"
  deprecated_option "oblique" => "with-oblique"

  depends_on "fontforge" => :build

  resource "oblique_converter" do
    url "http://www.rs.tus.ac.jp/yyusa/ricty/regular2oblique_converter.pe"
    sha256 "365c7973a02abf3970f09a557f8f93065341885f9e13570fd2e901e530c4864d"
  end

  resource "inconsolataregular" do
    url "https://github.com/google/fonts/raw/f0e90b27b6e567af9378952a37bc8cf29e2d88e9/ofl/inconsolata/Inconsolata-Regular.ttf"
    sha256 "e28c150b4390e5fd59aedc2c150b150086fbcba0b4dbde08ac260d6db65018d6"
    version "f0e90b2"
  end

  resource "inconsolatabold" do
    url "https://github.com/google/fonts/raw/f0e90b27b6e567af9378952a37bc8cf29e2d88e9/ofl/inconsolata/Inconsolata-Bold.ttf"
    sha256 "c268fae6dbf17a27f648218fac958b86dc38e169f6315f0b02866966f56b42bf"
    version "f0e90b2"
  end

  resource "migu1mfonts" do
    url "https://osdn.jp/frs/redir.php?m=gigenet&f=%2Fmix-mplus-ipa%2F63545%2Fmigu-1m-20150712.zip"
    sha256 "d4c38664dd57bc5927abe8f4fbea8f06a8ece3fea49ea02354d4e03ac6d15006"
  end

  patch do
    # workaround for #43 and #46
    url "https://raw.githubusercontent.com/sanemat/homebrew-font/cb5d2304f62226e3aa821a2563d3f7278342e2fe/ricty_generator.patch"
    sha256 "c27000c9f76d07781254e9a9122b018ad74e7bb5e7df0c0961251b43f00c9b26"
  end

  def install
    resource("migu1mfonts").stage { buildpath.install Dir["*"] }
    resource("inconsolataregular").stage { buildpath.install Dir["*"] }
    resource("inconsolatabold").stage { buildpath.install Dir["*"] }

    if build.with? "oblique"
      resource("oblique_converter").stage { buildpath.install Dir["*"] }
    end

    if build.with? "powerline"
      powerline = Powerline.new
      powerline.brew { buildpath.install Dir["*"] }
      powerline.patch
      rename_from = "(Ricty|Discord|Bold(?=Oblique))-?"
      rename_to = "\\1 "
    end

    ricty_args = ["Inconsolata-Regular.ttf", "Inconsolata-Bold.ttf", "migu-1m-regular.ttf", "migu-1m-bold.ttf"]
    ricty_args.unshift("-z") if build.without? "visible-space"
    ricty_args.unshift("-a") if build.without? "fullwidth"

    system "sh", "./ricty_generator-#{version}.sh", *ricty_args

    if build.with? "oblique"
      Dir["Ricty*.ttf"].each do |ttf|
        system "fontforge", "-script", buildpath/"regular2oblique_converter.pe", ttf
      end
    end

    if build.with? "powerline"
      powerline_args = []
      powerline_args.unshift("--no-rename") if build.with? "patch-in-place"
      Dir["Ricty*.ttf"].each do |ttf|
        system "fontforge", "-lang=py", "-script", buildpath/"scripts/powerline-fontpatcher", *powerline_args, ttf
        mv ttf.gsub(/#{rename_from}/, rename_to), ttf if build.with? "patch-in-place"
      end
    end

    (share/"fonts").install Dir["Ricty*.ttf"]
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
end

__END__
--- a/scripts/powerline-fontpatcher
+++ b/scripts/powerline-fontpatcher
@@ -79,6 +79,13 @@
 		if bbox[3] > target_bb[3]:
 			target_bb[3] = bbox[3]
 
+		# Ignore the above calculation and
+		# manually set the best values for Ricty
+		target_bb[0]=0
+		target_bb[1]=-525
+		target_bb[2]=1025
+		target_bb[3]=1650
+
 	# Find source and target size difference for scaling
 	x_ratio = (target_bb[2] - target_bb[0]) / (source_bb[2] - source_bb[0])
 	y_ratio = (target_bb[3] - target_bb[1]) / (source_bb[3] - source_bb[1])
