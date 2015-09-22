#!/usr/bin/env python
import sys
import os
import string
import re
import bisect
import gzip 
import copy
import random
import math
import numpy as np
import ctypes
from yael import yael

HELP_USAGE = """

Usage: gmm_train.py <*feat_pca.npy-dir> k <*gmm-dir>

options:
	<*feat_pca.npy-dir>  input: features after pca
	k                    input: number of Gaussian
	<*gmm-dir>           output: path to save the gmm model
"""

def main(argv):
	# read in arguments
	args = sys.argv[1:]
	if len(args) > 0 and args[0] in ("--help", "-h"):
		print HELP_USAGE
		return
	assert len(args) == 3, "wrong number of command parameters!"

	featDir = args[0]
	k = int(args[1])
	gmmDir = args[2]

	trainMat = np.load(featDir).astype(np.float32)
	trainNum, featNum = np.shape(trainMat)
	flags = yael.GMM_FLAGS_W
	niter = 20

	gmm = yael.gmm_learn(featNum, trainNum, k, niter, yael.FloatArray.acquirepointer(yael.numpy_to_fvec(trainMat)), 1, random.randrange(1000000), 8, flags)
	f = open(gmmDir, "w")
	yael.gmm_write(gmm,f)
	del gmm

if __name__ == "__main__":
	main( sys.argv )
