#/bin/bash
# This script checks the Downloads folder for files and folders that have not been accessed in 30 days.
# Folders are tarballed and everything is moved to the folder OldDownloads.
# Files that have sat in OldDownloads for 4 months, are moved to the folder ToBeRemoved.
# Conversely, files that have been accessed again in the last 5 days, are put back to Downloads.
# Files that have sat in the ToBeRemoved folder for over 30 days, are permanently removed.

cd ~/Downloads
find -maxdepth 1 -type f -atime +30 -exec mv {} -t OldDownloads \;
find -maxdepth 1 -type d -atime +30 -exec tar -cf ./OldDownloads/'{}'.tar \;
find -maxdepth 1 -type d -atime +30 -exec rm -rf {} \;
cd OldDownloads
touch README
find -maxdepth 1 -type f ! -name 'README' -atime -5 -exec mv {} -t .. \;
find -maxdepth 1 -type f -atime +120 -exec mv {} -t ToBeRemoved \;
cd ToBeRemoved
find -maxdepth 1 -type f -atime +30 -exec rm {} \;