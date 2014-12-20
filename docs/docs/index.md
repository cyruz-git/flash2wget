# flash2wget

*flash2wget* is a simple integration tool written in [AHK](http://ahkscript.org/), that allows *Mozilla Firefox* to send the downloads, through the *FlashGot extension*, to a remote *Wget* setup.

The requirements are:

1. A local installation of [Mozilla Firefox](https://www.mozilla.org/en-US/firefox/new/).

2. The [FlashGot](https://flashgot.net/) extension installed in Mozilla Firefox.

3. A linux remote machine with a **ssh server** and [Wget](https://www.gnu.org/software/wget/) installed.

### How it works

*flash2wget* works thanks to the *kscp* and *klink* tool from [9bis software](http://www.9bis.net/kitty/). It receives a set of **download parameters** from *FlashGot*, then it copies the **cookie** file to the remote linux server through **scp** with *kscp* and starts a *Wget* job through **ssh** with *klink*.

### Setup and usage

1. Move the *flash2wget* folder in the desired position.

2. Open the `about:addons` page in Mozilla Firefox and click on the *FlashGot* options.

3. Add a new **Download Manager** using `flash2wget` as a name.

4. Browse to the *flash2wget* folder and select **flash2wget.exe**.

5. Paste the following string as **Command line argument template**:

        [--output-document=FNAME] [--referer=REFERER] [--post-data=POST] [--load-cookies=CFILE] [--header=Cookie:COOKIE] [--user-agent=UA] [URL]
    
6. Accept the changes and go editing the settings in the **flash2wget.ini** file bundled with the executable (have a look at the next section for the settings).

7. Download files normally, sending the download to *FlashGot* and selecting *flash2wget* as the **Download Manager**. Check in your linux server if *Wget* is running.

### Configuration file

The configuration file options must be configured as per the following rules:

Setting  | Required | Default | Description
-------- |--------- | ------- | -----------
SSH_IP | Yes | N/A | IP address of the remote linux server.
SSH_PORT | Yes | 22 | Port used by the ssh server in the remote linux machine.
SSH_USER | Yes | N/A | User to be used when connecting through ssh.
SSH_PASSWORD | Yes* | N/A | Password to log-in the selected user. * Can be used in place of **SSH_PRIVATEKEY**. If used together with **SSH_PRIVATEKEY** it will be ignored.
SSH_PRIVATEKEY | Yes* | N/A | Path to the private key file, in **PuTTY .ppk format**, to log-in the selected user. * Can be used in place of **SSH_PASSWORD**. If used together with **SSH_PASSWORD** it will have priority.
WGET_PATH | Yes | /usr/bin/wget | Path to the *Wget* executable in the remote linux server, without quotes. Find it with `whereis wget` or `which wget`.
WGET_BG | No | 0 | (0 or 1) If = 1, *Wget* will be started with the `--background` parameter and the *klink* ssh window will be hidden. Remember that when in background mode, *Wget* writes its output to the **wget-log** file, that will be created in the current directory. It can be customized using the **WGET_LOGDIR** setting. To discard any output in background mode set **WGET_LOGDIR**=`NULL` and add `--quiet` to **WGET_DEFAULTOPT**.
WGET_COOKIE | Yes | /tmp/f2w_cookie | Path where to store the **cookie** file in the remote linux server. Must be accessible by the selected user.
WGET_DEFOPT | No | N/A | *Wget* default parameters. They will override any overlapping parameters passed by *FlashGot*, but they cannot override the parameters that have a dedicated setting in the configuration file (`--background`, `--directory-prefix`, `--output-document`, `--output-file`, `--append-output`).
WGET_DLDIR | Yes | N/A | Download directory used by *Wget* in the remote linux server, without quotes. Must be accessible by the selected user.
WGET_LOGDIR | No | N/A | Log directory in the remote linux server, without quotes. Must be accessible by the selected user. If set, *Wget* will redirect its output to a log file with the name of the downloaded file, plus the *.log* suffix. Because of the redirection there will be no output, so the *klink* ssh window will be hidden. If = NULL the output will be redirected to **/dev/null**.
WGET_MODIFY | No | 0 | (0 or 1) If = 1, the *Wget* commandline will be shown and it will be customizable by the user before starting the *Wget* job.
JOB_NOTIFY | No | 0 | (0 or 1 or 2) If = 1, notifies of the job sent to the remote linux server. If = 2, it shows also the commandline involved in the process.

Example:

    [SETTINGS]
    SSH_IP=192.168.1.10
    SSH_PORT=22
    SSH_USER=dlusr
    SSH_PASSWORD=dlusr2014
    SSH_PRIVATEKEY=
    WGET_PATH=/usr/bin/wget
    WGET_BG=0
    WGET_COOKIE=/tmp/f2w_cookie
    WGET_DEFOPT=--continue
    WGET_DLDIR=/media/USBHD_1/wget/download
    WGET_LOGDIR=
    WGET_MODIFY=0
    JOB_NOTIFY=0

### License

*flash2wget* is released under the terms of the [GNU General Public License](http://www.gnu.org/licenses/). *kscp* and *klink* are released under the MIT license by [9bis software](http://kitty.9bis.net/).

### Contact

For hints, bug reports or anything else, you can contact me at [focabresm@gmail.com](mailto:focabresm@gmail.com), open a issue on the dedicated [GitHub repo](https://github.com/cyruz-git/flash2wget) or use the [AHKscript development thread](http://ahkscript.org/boards/viewtopic.php?f=6&t=5659).