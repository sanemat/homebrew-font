homebrew-font
=============

Install fonts

Compile Ricty Font

* Install
** Recommend
```
$ brew tap sanemat/font
$ brew install ricty
# (generate)
$ cp -f /PATH/TO/RICTY/fonts/Ricty*.ttf ~/Library/Fonts/
$ fc-cache -vf
```

** Anothor
```
$ brew install https://raw.github.com/sanemat/homebrew-font/master/ricty.rb
# (generate)
# After this, same as above.
```
