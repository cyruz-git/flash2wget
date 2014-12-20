# flash2wget

*flash2wget* is a simple integration tool written in [AHK](http://ahkscript.org/), that allows *Mozilla Firefox* to send the downloads, through the *FlashGot extension*, to a remote *Wget* setup.

### Download

The build archive is [here](https://www.dropbox.com/sh/1woiv2cb7f4435b/AABDrhRq31o7Dm59cKNuZBkDa?dl=0).

### How it works

*flash2wget* works thanks to the *kscp* and *klink* tool from [9bis software](http://www.9bis.net/kitty/). It receives a set of **download parameters** from *FlashGot*, then it copies the **cookie** file to the remote linux server through **scp** with *kscp* and starts a *Wget* job through **ssh** with *klink*.

### Files

Name | Description
-----|------------
docs\ | Folder containing the documentation, built with MkDocs.
tools\ | Folder containing the required tools (*kscp* and *klink*).
COPYING | GNU General Public License.
flash2wget.ahk | Main and only source file.
flash2wget.ico | Icon file.
flash2wget.ini | Configuration file.
README.md | This document.

### How to compile

*flash2wget* should be compiled with the **Ahk2Exe** compiler, that can be downloaded from the [AHKscript download page](http://ahkscript.org/download/).

Browse to the files so that the fields are filled as follows:

    Source:      path\to\flash2wget.ahk
    Destination: path\to\flash2wget.exe
    Custom Icon: path\to\flash2wget.ico

Select a **Base File** indicating your desired build and click on the **> Convert <** button.

The documentation site is built with [MkDocs](http://www.mkdocs.org/).

### License

*flash2wget* is released under the terms of the [GNU General Public License](http://www.gnu.org/licenses/). *kscp* and *klink* are released under the MIT license by [9bis software](http://kitty.9bis.net/).

### Contact

For hints, bug reports or anything else, you can contact me at [focabresm@gmail.com](mailto:focabresm@gmail.com), open a issue on the dedicated [GitHub repo](https://github.com/cyruz-git/flash2wget) or use the [AHKscript development thread](http://ahkscript.org/boards/viewtopic.php?f=6&t=5659).