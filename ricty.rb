require 'formula'

class InconsolataFonts < Formula
  url 'http://levien.com/type/myfonts/Inconsolata.otf', :using => :curl
  sha1 '7f0a4919d91edcef0af9dc153054ec49d1ab3072'
end

class Ricty < Formula
  homepage ''
  url 'https://github.com/yascentur/Ricty/archive/3.2.1.tar.gz'
  sha1 '5a5aaa69949544eb8522ee1fa3d2862ce6a4a5e4'

  depends_on 'fontforge'

  def install
    bin.install('ricty_generator.sh')
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test ricty_generator`.
    system "false"
  end
end
