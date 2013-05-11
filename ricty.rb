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
end
