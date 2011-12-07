build: sandbox/bin/repozo

test1: build
	rm -fr Data.fs* backup
	mkdir backup
	# Test Case 1: call repozo -B twice in the same second
	# It's likely that you'll end up with backup/YYYY-MM-DD-hh-mm-ss.fs and
	# backup/YYYY-MM-DD-hh-mm-ss.deltafs (same YYYY-MM-DD-hh-mm-ss!).  Then
	# cmp will show that repozo -R failed to reconstruct the DB correctly.
	sandbox/bin/python testcase.py --set foo bar
	sandbox/bin/repozo -BQ -r backup -f Data.fs
	sandbox/bin/python testcase.py --set x y
	sandbox/bin/repozo -BQ -r backup -f Data.fs
	sandbox/bin/repozo -R -r backup -o Data.fs.recovered
	cmp Data.fs Data.fs.recovered

test2: build
	rm -fr Data.fs* backup
	mkdir backup
	# Test Case 2: call repozo -R with a truncated .deltafs in the middle
	# repozo ought to notice and complain; instead it goes ahead and
	# produces a corrupted Data.fs
	sandbox/bin/python testcase.py --set foo bar
	sandbox/bin/repozo -BQ -r backup -f Data.fs
	sleep 1 # baaad idea to run repozo twice during the same second
	sandbox/bin/python testcase.py --set x y
	sandbox/bin/repozo -BQ -r backup -f Data.fs
	sleep 1 # baaad idea to run repozo twice during the same second
	sandbox/bin/python testcase.py --set u v
	sandbox/bin/repozo -BQ -r backup -f Data.fs
	# truncate the first deltafs file
	first_delta=`ls backup/*.deltafs|head -n 1`; > $$first_delta
	# this should fail:
	sandbox/bin/repozo -R -r backup -o Data.fs.recovered
	# instead this fails
	cmp Data.fs Data.fs.recovered


sandbox:
	virtualenv --no-site-packages sandbox

sandbox/bin/repozo: sandbox
	sandbox/bin/pip install ZODB3
	touch -c $@

clean:
	rm -fr Data.fs* backup sandbox
