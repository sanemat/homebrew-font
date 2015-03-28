require 'formula'

class Powerline < Formula
  homepage 'https://github.com/powerline/fontpatcher'
  url 'https://github.com/powerline/fontpatcher/archive/18a788b8ec1822095813b73b0582a096320ff714.zip'
  sha1 'eacbca3a3e3b7acd03743e80a51de97c9c0bbc80'
  version '20150113'
  def initialize(name = 'powerline', path = self.class.path(name), spec = 'stable')
    super
  end
  patch :DATA
end

class Ricty < Formula
  homepage 'https://github.com/yascentur/Ricty'
  url 'https://github.com/yascentur/Ricty/archive/3.2.4.tar.gz'
  sha1 '7fc8adcc74656d9e2e1acd325de82f0f08a6d222'
  version '3.2.4'

  resource 'inconsolatafonts' do
    url 'http://levien.com/type/myfonts/Inconsolata.otf'
    sha1 '7f0a4919d91edcef0af9dc153054ec49d1ab3072'
    version '1.0.0'
  end

  resource 'inconsolatadzfonts' do
    url 'http://media.nodnod.net/Inconsolata-dz.otf.zip'
    sha1 'c8254dbed67fb134d4747a7f41095cedab33b879'
    version '1.0.0'
  end

  resource 'migu1mfonts' do
    url 'http://sourceforge.jp/frs/redir.php?m=iij&f=%2Fmix-mplus-ipa%2F59022%2Fmigu-1m-20130617.zip'
    sha1 'a0641894cec593f8bb1e5c2bf630f20ee9746b18'
    version '20130617'
  end

  resource 'vimpowerline' do
    url 'https://github.com/Lokaltog/vim-powerline/archive/09c0cea859.tar.gz'
    sha1 'a1acef16074b6c007a57de979787a9b166f1feb1'
    version '20120817'
  end

  option 'powerline', 'Patch for Powerline'
  option 'vim-powerline', 'Patch for Powerline from vim-powerline'
  option 'dz', 'Use Inconsolata-dz instead of Inconsolata'
  option 'disable-fullwidth', 'Disable fullwidth ambiguous characters'
  option 'disable-visible-space', 'Disable visible zenkaku space'
  option 'patch-in-place', "Patch Powerline glyphs directly into Ricty fonts without creating new 'for Powerline' fonts"

  depends_on 'fontforge'

  def install
    share_fonts = share + 'fonts'
    powerline_script = []

    resource('migu1mfonts').stage { share_fonts.install Dir['*'] }
    if build.include? 'powerline'
      Powerline.new.brew { buildpath.install Dir['*'] }
      powerline_script << buildpath + 'scripts/powerline-fontpatcher'
      rename_from = '(Ricty|Discord)-?'
      rename_to = "\\1 "
    end
    if build.include?('vim-powerline') && !(build.include?('powerline') && build.include?('patch-in-place'))
      resource('vimpowerline').stage { buildpath.install 'fontpatcher' }
      powerline_script << buildpath + 'fontpatcher/fontpatcher'
      rename_from = "\.ttf"
      rename_to = '-Powerline.ttf'
    end
    if build.include? 'dz'
      resource('inconsolatadzfonts').stage { share_fonts.install Dir['*'] }
      inconsolata = share_fonts + 'Inconsolata-dz.otf'
      # Patch the discord script since the special characters are in different locations in Inconsolata-dz
      inreplace 'ricty_discord_patch.pe', '65608', '65543' # Serif r
      inreplace 'ricty_discord_patch.pe', '65610', '65545' # Un-dotted zero
    else
      resource('inconsolatafonts').stage { share_fonts.install Dir['*'] }
      inconsolata = share_fonts + 'Inconsolata.otf'
    end

    ricty_args = [inconsolata, share_fonts + 'migu-1m-regular.ttf', share_fonts + 'migu-1m-bold.ttf']
    ricty_args.unshift('-z') if build.include? 'disable-visible-space'
    ricty_args.unshift('-a') if build.include? 'disable-fullwidth'

    powerline_args = []
    powerline_args.unshift('--no-rename') if build.include? 'patch-in-place'

    system 'sh', './ricty_generator.sh', *ricty_args

    ttf_files = Dir['Ricty*.ttf']
    if build.include?('powerline') || build.include?('vim-powerline')
      powerline_script.each do |script|
        ttf_files.each do |ttf|
          system "fontforge -lang=py -script #{script} #{powerline_args.join(' ')} #{ttf}"
          mv ttf.gsub(/#{rename_from}/, rename_to), ttf if build.include? 'patch-in-place'
        end
      end
    end
    share_fonts.install Dir['Ricty*.ttf']
  end

  test do
    system 'false'
  end

  def caveats; <<-EOS.undent
    ***************************************************
    Generated files:
      #{Dir[share + 'fonts/Ricty*.ttf'].join("\n      ")}
    ***************************************************
    To install Ricty:
      $ cp -f #{share}/fonts/Ricty*.ttf ~/Library/Fonts/
      $ fc-cache -vf
    ***************************************************
    EOS
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
