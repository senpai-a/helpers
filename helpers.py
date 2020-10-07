import cv2
import numpy as np
import os
from math import floor,sqrt
from datetime import datetime,timedelta

from random import sample

def log(msg,fn='log.txt'):
    f = open(fn,'a')
    print(msg,file=f)
    print(msg)
    f.close()

def now(timezone=8):
    return datetime.now()+timedelta(hours=timezone)

def matshow(title,mat):
    mat = mat.astype(float)
    mi = np.min(mat)
    ma = np.max(mat)
    mat -= mi
    mat/=(ma-mi)
    mat*=255
    cv2.imwrite(title+'.png',np.uint8(mat))

def peek(mat):
    m,n = mat.shape
    print(mat[m//2:m//2+5,n//2:n//2+5])
    print(m//2,':',m//2+5,',',n//2,':',n//2+5)

def collect_files(paths,suffixes):
    ret = []
    if type(paths) == str:
        paths = [paths]
    if type(suffixes) == str:
        suffixes = (suffixes,)     
    for p in paths:
        if os.path.isfile(p):
            if p.lower().endswith(tuple(suffixes)):
                ret.append(p)
        elif os.path.isdir(p):
            for parent, dirnames, filenames in os.walk(p):
                for filename in filenames:
                    if filename.lower().endswith(tuple(suffixes)):
                        ret.append(os.path.join(parent, filename))
        else:
            print(p,': no such file or directory')
    print('collected',len(ret),'files')
    return ret

def collect_files_subfolder(paths,suffixes):
    ret = dict()
    if type(paths) == str:
        paths = [paths]
    if type(suffixes) == str:
        suffixes = (suffixes,)     
    for p in paths:
        if os.path.isdir(p):
            for parent, dirnames, filenames in os.walk(p):
                for filename in filenames:
                    if filename.lower().endswith(tuple(suffixes)):
                        fullpath = os.path.join(parent, filename)
                        if parent in ret.keys():
                            ret[parent].append(fullpath)
                        else:
                            ret[parent] = [fullpath]
        else:
            print(p,': no such directory')
    print('collected from:')
    for k in ret.keys():
        print('\t%s : %d files'%(k,len(ret[k])))
    return ret

def print_progress(p,width=50,print_percentage=False):
    k = floor(p*width)
    tails=["","▏","▎","▍","▌","▋","▊","▉"]
    re = floor((p*width-k)*8)
    tail = tails[re]
    spa = max(width-k-len(tail),0)
    print('\r▕%s%s%s▏'%('█'*k,tail,' '*spa),end='')
    if print_percentage:
        print(' %.1f %%'%(p*100),end='')

def flush_progress(l=60):
    print('\r%s\r'%(' '*l),end='')

#random sample querys for identical/different divces
def sample_querys_h1(n,imglist):
    N = len(imglist)
    pairs = []
    for i in range(N):
        for j in range(i+1,N):
            pairs.append((imglist[i],imglist[j]))
    return sample(pairs,n)

def sample_querys_h0(n,imglist1,imglist2):
    if n==0:
        return []
    ret = []    
    n1 = floor(sqrt(n))
    n2 = floor(n/n1)
    re = n - n1*n2
    id1 = sample(imglist1,n1)
    id2 = sample(imglist2,n2)
    for i in id1:
        for j in id2:
            ret.append((i,j))
    ret.extend(sample_querys_h0(re,imglist1,imglist2))
    return ret
