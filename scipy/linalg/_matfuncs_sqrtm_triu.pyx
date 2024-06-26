# cython: boundscheck=False, wraparound=False, cdivision=True
from ._matfuncs_sqrtm import SqrtmError

from numpy cimport complex128_t, float64_t, intp_t


cdef fused floating:
    float64_t
    complex128_t


def within_block_loop(floating[:,::1] R, const floating[:,::1] T, start_stop_pairs, intp_t nblocks):
    cdef intp_t start, stop, i, j, k
    cdef floating s, denom, num

    for start, stop in start_stop_pairs:
        for j in range(start, stop):
            for i in range(j-1, start-1, -1):
                s = 0
                if j - i > 1:
                    # s = R[i,i+1:j] @ R[i+1:j,j]
                    for k in range(i + 1, j):
                        s += R[i,k] * R[k,j]

                denom = R[i, i] + R[j, j]
                num = T[i, j] - s
                if denom != 0:
                    R[i, j] = (T[i, j] - s) / denom
                elif denom == 0 and num == 0:
                    R[i, j] = 0
                else:
                    raise SqrtmError('failed to find the matrix square root')
