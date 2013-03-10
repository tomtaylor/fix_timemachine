fix_timemachine
===============

Time Machine sometimes seems to have some issues verifying the previous
backups when it's connected to a network drive.

This is the message you'll see:

![Time Machine Verification Alert Box](http://km.support.apple.com/library/APPLE/APPLECARE_ALLGEOS/HT4076/HT4076_01----en.png)

This script fixes those backups, so you don't have to start from the beginning
with a new backup set. It temporarily disables Time Machine, mounts the network
share, verifies and repairs the sparsebundle file, fixes the plist file to mark
it as valid, and starts Time Machine again.

You'll need to edit the three variables (USER, HOSTNAME, AFPSHARE) at the top
of the script to your Time Machine network share settings.

Run the script as root, probably through sudo:

    sudo ./fix_timemachine.sh

This script is almost entirely the work of
[Hoeve](http://www.hoeve.nu/index.php/home/time-machine-fix/), with a few
modifications to support volume names with spaces, and some comments.
