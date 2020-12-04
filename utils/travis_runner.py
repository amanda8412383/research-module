#!/usr/bin/env python
"""This script manages all tasks for the TRAVIS build server."""
import subprocess as sp
import glob

if __name__ == '__main__':

    for notebook in glob.glob('*.ipynb'):
        cmd = ' jupyter nbconvert --ExecutePreprocessor.timeout=-1 --to notebook --execute {}'.format(notebook)
        sp.check_call(cmd, shell=True)
    print('success')
