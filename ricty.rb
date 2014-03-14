require 'formula'

class InconsolataFonts < Formula
  homepage 'http://levien.com/type/myfonts/inconsolata.html'
  url 'http://levien.com/type/myfonts/Inconsolata.otf'
  sha1 '7f0a4919d91edcef0af9dc153054ec49d1ab3072'
  version '1.0.0'
end

class InconsolataDZFonts < Formula
  homepage 'http://nodnod.net/2009/feb/12/adding-straight-single-and-double-quotes-inconsola/'
  url 'http://media.nodnod.net/Inconsolata-dz.otf.zip'
  sha1 'c8254dbed67fb134d4747a7f41095cedab33b879'
  version '1.0.0'
end

class Migu1MFonts < Formula
  homepage 'http://mix-mplus-ipa.sourceforge.jp/'
  url 'http://sourceforge.jp/frs/redir.php?m=iij&f=%2Fmix-mplus-ipa%2F59022%2Fmigu-1m-20130617.zip'
  sha1 'a0641894cec593f8bb1e5c2bf630f20ee9746b18'
  version '20130617'
end

class Powerline < Formula
  homepage 'https://github.com/Lokaltog/powerline'
  url 'https://github.com/Lokaltog/powerline/archive/db80fc95ed.tar.gz'
  sha1 '00c8911bce9ad9eab72ff1b366bc4ea417404724'
  version '20130827'
end

class VimPowerline < Formula
  homepage 'https://github.com/Lokaltog/vim-powerline'
  url 'https://github.com/Lokaltog/vim-powerline/archive/09c0cea859.tar.gz'
  sha1 'a1acef16074b6c007a57de979787a9b166f1feb1'
  version '20120817'
end

class Ricty < Formula
  homepage 'https://github.com/yascentur/Ricty'
  url 'https://github.com/yascentur/Ricty/archive/3.2.2.tar.gz'
  sha1 '5422e8a308dbe93805bc36c2c6b29070503f9058'
  version '3.2.2'

  option "powerline", "Patch for Powerline"
  option "vim-powerline", "Patch for Powerline from vim-powerline"
  option "dz", "Use Inconsolata-dz instead of Inconsolata"

  depends_on 'fontforge'

  def install
    share_fonts = share+'fonts'

    Migu1MFonts.new.brew { share_fonts.install Dir['*'] }
    if build.include? "powerline"
      Powerline.new.brew { buildpath.install 'font' }
    end
    if build.include? "vim-powerline"
      VimPowerline.new.brew { buildpath.install 'fontpatcher' }
    end
    if build.include? "dz"
      InconsolataDZFonts.new.brew { share_fonts.install Dir['*'] }
    else
      InconsolataFonts.new.brew { share_fonts.install Dir['*'] }
    end

    if build.include? "dz"
      system 'sh', './ricty_generator.sh', share_fonts+'Inconsolata-dz.otf',
                                           share_fonts+'migu-1m-regular.ttf',
                                           share_fonts+'migu-1m-bold.ttf'
    else
      system 'sh', './ricty_generator.sh', share_fonts+'Inconsolata.otf',
                                           share_fonts+'migu-1m-regular.ttf',
                                           share_fonts+'migu-1m-bold.ttf'
    end

    ttf_files = Dir["Ricty*.ttf"]
    if build.include? "powerline"
      ttf_files.each do |ttf|
        system "fontforge -lang=py -script #{buildpath/'font/fontpatcher.py'} #{ttf}"
      end
    end
    if build.include? "vim-powerline"
      ttf_files.each do |ttf|
        system "fontforge -lang=py -script #{buildpath/'fontpatcher/fontpatcher'} #{ttf}"
      end
    end
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
