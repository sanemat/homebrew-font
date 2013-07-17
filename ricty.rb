require 'formula'

class InconsolataFonts < Formula
  homepage 'http://levien.com/type/myfonts/inconsolata.html'
  url 'http://levien.com/type/myfonts/Inconsolata.otf'
  sha1 '7f0a4919d91edcef0af9dc153054ec49d1ab3072'
  version '1.0.0'
end

class Migu1MFonts < Formula
  homepage 'http://mix-mplus-ipa.sourceforge.jp/'
  url 'http://sourceforge.jp/frs/redir.php?m=iij&f=%2Fmix-mplus-ipa%2F59022%2Fmigu-1m-20130617.zip'
  sha1 'a0641894cec593f8bb1e5c2bf630f20ee9746b18'
  version '20130617'
end

class Ricty < Formula
  homepage 'https://github.com/yascentur/Ricty'
  url 'https://github.com/yascentur/Ricty/archive/3.2.1.tar.gz'
  sha1 '5a5aaa69949544eb8522ee1fa3d2862ce6a4a5e4'
  version '3.2.1'

  depends_on 'fontforge'

  def install
    share_fonts = share+'fonts'

    InconsolataFonts.new.brew { share_fonts.install Dir['*'] }
    Migu1MFonts.new.brew { share_fonts.install Dir['*'] }

    system 'sh', './ricty_generator.sh', share_fonts+'Inconsolata.otf',
                                         share_fonts+'migu-1m-regular.ttf',
                                         share_fonts+'migu-1m-bold.ttf'
    share_fonts.install Dir['Ricty*.ttf']
  end

  test do
    system "false"
  end

  def caveats; <<-EOS.undent
    ***************************************************
    Generated files:
      #{Dir[share+'fonts/Ricty*.ttf'].join("\n      ")}
    ***************************************************
    To install Ricty:
      $ cp -f #{share}/fonts/Ricty*.ttf ~/Library/Fonts/
      $ fc-cache -vf
    ***************************************************
    EOS
  end
end
