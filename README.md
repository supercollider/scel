# scel - sclang-mode for emacs

SuperCollider/Emacs interface

## Installation

The repository contains two subprojects. `/sc` contains the SuperCollider code
required to implement the emacs interface. `/el` contains the emacs-lisp
implementation of the mode. Emacs and SuperCollider each have their own package
managers, so it is required to install each half separately.

### Installing scel quark

The `scel` Quark is required for emacs to communicate with sclang. Evaluate this in the SuperCollider GUI:

``` supercollider
Quarks.install("https://github.com/supercollider/scel");
```

### Installing the emacs mode

Using straight.el
``` emacs-lisp
(straight-use-package
 '(sclang :type git 
          :host github 
          :repo "supercollider/scel" 
          :files ("el/*.el")))
```

Or download the repo directly to your user config directory

``` shell
git clone https://github.com/supercollider/scel.git ~/.emacs.d/scel
```
``` emacs-lisp
(add-to-list 'load-path "~/.emacs.d/scel/el/")
(require 'sclang)
```

### On MacOS

If `sclang` executable is not on your path, you may need to add it to your exec-path.

``` emacs-lisp
(setq exec-path (append exec-path '("/Applications/SuperCollider.app/Contents/MacOS/")))
```
### On Linux

If you are building SuperCollider from source on Linux, this library (both .el
and .sc files) will be installed by default. To disable it pass the flag
`-DSC_EL=OFF` as a `cmake` option. See the supercollider readme for more info.


## Installation requirements

For the HTML help system, you will need emacs-w3m support, but you can still use without that.

```emacs-lisp
(require 'w3m)
```

## Configuration

To fine-tune the installation from within emacs' graphical customization interface, type:

`M-x sclang-customize`


## Usage

`M-x sclang-start` or open a `.scd` file and press `C-c C-o`

You're now ready to edit, inspect and execute sclang code!


## Getting help

Inside an sclang-mode buffer (e.g. by editing a .sc file), execute

`C-h m`

and a window with key bindings in sclang-mode will pop up.

`C-x C-h` lets you search for a help file

`C-M-h` opens or switches to the Help browser (if no Help file has been opened, the default Help file will be opened).

`E` copies the buffer, puts it in text mode and sclang-minor-mode, to enable you to edit the code parts to try out variations of the provided code in the help file. With `C-M-h` you can then return to the Help browser and browse further from the Help file.

`C-c C-e` allows you to edit the source of the HTML file, for example if you want to improve it and commit it to the repository.

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

This ensures that the arrow keys are just for moving through the document, and not from hyperlink to hyperlink, which is the default in w3m-mode.


## Server control

In the post buffer window, right-click on the server name; by default the two servers `internal` and `localhost` are available. You will get a menu with common server control operations.

To select another server, step through the server list by left-clicking on the server name.

Servers instantiated from the language will automatically be available
in the mode line.
