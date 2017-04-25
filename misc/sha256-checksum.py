import hashlib
import sys
import urllib2
import optparse

def sha256_checksum(url, block_size=65536):
    filename = urllib2.urlopen(url)
    sha256 = hashlib.sha256()
    for block in iter(lambda: filename.read(block_size), b''):
        sha256.update(block)
    return sha256.hexdigest()

if __name__ == '__main__':
    opt = optparse.OptionParser()
    opt.add_option('--url', '-u', default='https://raw.githubusercontent.com/hk1953/ucsl-image/master/image/jupyter_config.py')
    options, args = opt.parse_args()
    print sha256_checksum(options.url)