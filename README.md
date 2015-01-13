homebrew-font
=============

# Install fonts

Compile Ricty Font

* Install
   * Recommend

```
$ brew tap sanemat/font
$ brew install ricty
# (generate)
$ cp -f /PATH/TO/RICTY/fonts/Ricty*.ttf ~/Library/Fonts/
$ fc-cache -vf
```

   * Anothor

```
$ brew install https://raw.github.com/sanemat/homebrew-font/master/ricty.rb
# (generate)
# After this, same as above.
```

# Troubleshooting

## Error during `brew install fontforge`

If you meet error during `brew install fontforge`, like below:

```
==> Patching
==> ./bootstrap
==> ./configure --prefix=/Users/sane/.homebrew/Cellar/fontforge/20141230 --disable-silent-rules --without-x --without-giflib --without-libspiro
installed software in a non-standard prefix.

Alternatively, you may set the environment variables PYTHON_CFLAGS
and PYTHON_LIBS to avoid the need to call pkg-config.
See the pkg-config man page for more details.
```

### Short help (work around)

Exec below:

```
# Install python before install fontforge and ricty
brew install python
# then install fontforge and ricty
brew install ricty
```

### Long help (my environment)

I use homebrew of course, but I don't use homebrew's python. I use pyenv via anyenv. In homebrew build script, your PKG_CONFIG_PATH are not used, there is homebrew's PKG_CONFIG_PATH. You can try this `brew sh` and `printenv | grep PKG_CONFIG_PATH`.

[fontforge configuration script](https://github.com/fontforge/fontforge/blob/7432f9a102f0f4268c5caabbb4f55d3ac33b0d0d/configure.ac#L217-L230) doesn't detect pyenv's python (I think, but I'm not familier with autoconf yet, sorry). I don't understand why this doesn't detect system python (after I exec `pyenv global system`).

This is debug output `brew install fontforge --verbose --debug` below:

```
detected a homebrew build environment
./configure: line 18044: /Users/sane/.homebrew/bin/python: No such file or directory
./configure: line 18045: cd: /../../pkgconfig: No such file or directory
found python pkg_config information:
./configure: line 18048: y: command not found
checking for a Python interpreter with version >= 2.7... python
checking for python... /Users/sane/.anyenv/envs/pyenv/versions/2.7.6/bin/python
checking for python version... 2.7
checking for python platform... darwin
checking for python script directory... ${prefix}/lib/python2.7/site-packages
checking for python extension module directory... ${exec_prefix}/lib/python2.7/site-packages
checking for PYTHON... no
configure: error: Package requirements (python-"2.7") were not met:

No package 'python-2.7' found

Consider adjusting the PKG_CONFIG_PATH environment variable if you
installed software in a non-standard prefix.

Alternatively, you may set the environment variables PYTHON_CFLAGS
and PYTHON_LIBS to avoid the need to call pkg-config.
See the pkg-config man page for more details.
```

The actual solution is detecting system python here, but I don't know how to detect this yet.
