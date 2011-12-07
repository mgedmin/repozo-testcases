Background:

  * there's this server with a Data.fs and a cron script that makes incremental
    backups using repozo
  * the backups are gpg-encrypted and transferred to a remote storage server
  * recovery procedure involves rsyncing the backups to a local machine,
    decrypting them, and reassembling them into Data.fs with repozo
  * I've done that twice: it worked the first time, but I got a corrupted
    Data.fs the second time
  * after a few hours of investigation I discovered that three of the 5000-odd
    incremental deltafs files were 0-length
  * turns out the gpg-decrypting script did not resume its work at the right
    place when when interrupted with ^C, leaving empty files in the middle

So, the bug: repozo does not notice when some of the deltafs files are
truncated.  It should notice, complain loudly, and abort, instead of silently
producing a corrupted Data.fs.  To reproduce, run ::

   make test2

While writing this test case I discovered another bug: if you run repozo
twice in quick succession, you end up with a backup repository that fails to
be restored correctly.  To reproduce, run ::

   make test1


-- Marius Gedminas <marius@gedmin.as>, 2011-12-07
