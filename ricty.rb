require 'formula'

class InconsolataFonts < Formula
  homepage 'http://levien.com/type/myfonts/inconsolata.html'
  url 'http://levien.com/type/myfonts/Inconsolata.otf'
  sha1 '7f0a4919d91edcef0af9dc153054ec49d1ab3072'
  version '1.0.0'
end

class Migu1MFonts < Formula
  homepage 'http://mix-mplus-ipa.sourceforge.jp/'
  url 'http://sourceforge.jp/frs/redir.php?m=jaist&f=%2Fmix-mplus-ipa%2F58720%2Fmigu-1m-20130430.zip'
  sha1 '5fb8634d4f67df3889e98c1491e9d6b335bc95c7'
  version '20130430'
end

class Ricty < Formula
  homepage 'https://github.com/yascentur/Ricty'
  url 'https://github.com/yascentur/Ricty/archive/3.2.2.tar.gz'
  sha1 '5422e8a308dbe93805bc36c2c6b29070503f9058'
  version '3.2.2'

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
