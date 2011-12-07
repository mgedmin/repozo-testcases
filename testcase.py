#!sandbox/bin/python
import optparse
import transaction
from ZODB.DB import DB
from ZODB.FileStorage import FileStorage


def main():
    parser = optparse.OptionParser()
    parser.add_option('--set', '-s', nargs=2, dest='set_', metavar='KEY VALUE',
                      help='write a key/value pair into the root dict of Data.fs')
    opts, args = parser.parse_args()

    if not opts.set_:
        parser.error('Nothing to do!')

    key, value = opts.set_

    db = DB(FileStorage('Data.fs'))
    conn = db.open()
    root = conn.root()
    root[key] = value
    transaction.commit()
    conn.close()
    db.close()


if __name__ == '__main__':
    main()
