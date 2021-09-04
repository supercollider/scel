# scel - sclang-mode for emacs

SuperCollider/Emacs interface

## Installation

There are 3 options for installation:

1. Using SuperCollider Quarks (recommended)
2. From debian package `supercollider-emacs`
3. From source

Option #1 is the best cross-platform option, and is recommended. Whatever option
you choose, *make sure not to mix installation methods*. In particular, do not
install the Quark if you already have the supercollider-emacs package or if you
compiled SuperCollider with the `-DSC_EL=ON` option. Otherwise you will get an
error from SuperCollider about duplicated classes.

### Install Option 1: SuperCollider's own package manager

The repository contains two subprojects. `/el` contains the emacs-lisp
implementation. `/sc` contains the SuperCollider code required to
implement the Emacs interface. SuperCollider has its own package system
called Quarks, which we can use to install both halves.

Evaluate this code in the SuperCollider GUI by pasting it and pressing
shift+enter:

``` supercollider
Quarks.install("https://github.com/supercollider/scel");
```

The scel repository will be downloaded to your local file system and the path
will be added to your default `sclang_conf.yaml` file. (You can find its
location by evaluating `Platform.userConfigDir`)

Next, find out where scel was installed. You will use this install-path in your
emacs config.

``` supercollider
Quarks.folder.postln;

// -> /Users/<username>/Library/Application Support/SuperCollider/downloaded-quarks
```

Now in your emacs config, add the `/el` subdirectory to your load path
``` emacs-lisp
;; in ~/.emacs

;; Paste path from above, appending "/scel/el"
(add-to-list 'load-path "/Users/<username>/Library/Application Support/SuperCollider/downloaded-quarks/scel/el")
(require 'sclang)
```
#### On macOS

If `sclang` executable is not on your path, you may need to add it to your
exec-path.

``` emacs-lisp
;; in ~/.emacs
(setq exec-path (append exec-path '("/Applications/SuperCollider.app/Contents/MacOS/")))
```

#### Installing with an emacs package manager

It's completely possible to install with
[straight.el](https://github.com/raxod502/straight.el),
[use-package](https://github.com/jwiegley/use-package),
[doom](https://github.com/hlissner/doom-emacs), etc. Instructions for doing so
are beyond the scope of this README, but note that `autoloads` are implemented
for entry-point functions so if you like to have a speedy start-up time you can
use the `:defer t` option.

### Install Option 2: Debian package

There is a debian package which provides emacs integration called
`supercollider-emacs`. Option #1 will likely be more recent, but 
if you prefer you can install the package with:

``` shell
sudo apt install supercollider-emacs
```

### Install Option 3: Installing from source

If you are building SuperCollider from source, you can optionally compile and
install this library along with it. The cmake `-DSC_EL` flag controls whether
scel will be compiled. On Linux machines `-DSC_EL=ON` by default. See the
supercollider README files for more info.

``` emacs-lisp
;; in ~/.emacs
(add-to-list 'load-path "/usr/local/share/emacs/site-lisp/SuperCollider/") ;; path will depend on your compilation settings
(require 'sclang)
```

## Optional Installation Requirements

There are two options for SuperCollider help files. They can be opened in the
help browser that ships with SuperCollider, or if you prefer an emacs-only
workflow they can be opened using the w3m browser. The browse-in-emacs option
requires an additional dependency.

```emacs-lisp
;; in ~/.emacs
(require 'w3m)
```

## Usage

The main function which starts interacting with the sclang interpreter is
`sclang-start`. You can execute that anywhere with `M-x sclang-start`, or from
within a `.scd` buffer by pressing `C-c C-o`.

If you know you want to launch sclang when you start emacs you can use the `-f`
option to execute that function right away:

``` shell
# in your terminal
emacs -f sclang-start
```

## Configuration

To fine-tune the installation from within emacs' graphical customization
interface, type:

`M-x sclang-customize`

NOTE: If you use an sclang configuration file different from the default
`sclang_conf.yaml`, you need to specify it in scel by customizing the
`sclang-library-configuration-file `variable. Otherwise, even after installing
the Quark in SuperCollider, you won't be able to run sclang code in emacs.


## Getting help

Inside an sclang-mode buffer (e.g. by editing a .sc file), execute

`C-h m`

and a window with key bindings in sclang-mode will pop up.

`C-x C-h` lets you search for a help file

`C-M-h` opens or switches to the Help browser (if no Help file has been opened,
the default Help file will be opened).

`E` copies the buffer, puts it in text mode and sclang-minor-mode, to enable you
to edit the code parts to try out variations of the provided code in the help
file. With `C-M-h` you can then return to the Help browser and browse further
from the Help file.

`C-c C-e` allows you to edit the source of the HTML file, for example if you
want to improve it and commit it to the repository.

To enable moving around in the help file with arrow keys add the following
in your `~/.emacs`:

```
(eval-after-load "w3m"
 '(progn
 (define-key w3m-mode-map [left] 'backward-char)
 (define-key w3m-mode-map [right] 'forward-char)
 (define-key w3m-mode-map [up] 'previous-line)
 (define-key w3m-mode-map [down] 'next-line)))
```

This ensures that the arrow keys are just for moving through the document, and
not from hyperlink to hyperlink, which is the default in w3m-mode.


## Server control

In the post buffer window, right-click on the server name; by default the two
servers `internal` and `localhost` are available. You will get a menu with
common server control operations.

To select another server, step through the server list by left-clicking on the
server name.

Servers instantiated from the language will automatically be available in the
mode line.
