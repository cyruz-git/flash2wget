# flash2wget

*flash2wget* is a simple integration tool written in [AHK](http://ahkscript.org/), that allows *Mozilla Firefox* to send the downloads, through the *FlashGot extension*, to a remote *Wget* setup.

### Download

The build archive is [here on GitHub](https://github.com/cyruz-git/flash2wget/releases).

### Files

Name | Description
-----|------------
docs\ | Folder containing the documentation, built with MkDocs.
res\ | Folder containing icon resources.
tools\ | Folder containing the required tools (*kscp* and *klink*).
COPYING | GNU General Public License.
COPYING.LESSER | GNU Lesser General Public License.
flash2wget.ahk | Main and only source file.
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

### Full README available [here](docs/docs/index.md)
