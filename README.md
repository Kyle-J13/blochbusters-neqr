# blochbusters-neqr

## Quick Navigation

[Summary](#Summary)

[Notes](#Notes)

[References](#References)

## Summary
Implement and analyze the Novel Enhanced Quantum Representation (NEQR) algorithm

## Notes
The NEQR is limited to square images at a power of 2

The NEQR is an improvement upon the Flexible Representation of Quantum Images (FRQI)

The algoritm takes q+n1+n2 qubits where q is 2^q = grey scale range and n1/n2 are a 2^n1 X 2^n2 image

The algoritm sould return a qubit register where the first n1+n2 qubits are the coordinates of the pixel and the next q qubits are the coresponding greyscale value



## References

Algorithm    | Reference
------------|---------
FRQI        | Le, P. Q., Dong, F. & Hirota, K. A flexible representation of quantum images for polynomial preparation, image compression, and processing operations. Quantum Inf. Process. 10, 63–84 (2011). https://doi.org/10.1007/s11128-010-0177-y
NEQR        | Zhang, Y., Lu, K., Gao, Y. & Wang, M. NEQR: A novel enhanced quantum representation of digital images. Quantum Inf. Process. 12, 2833–2860 (2013). https://doi.org/10.1007/s11128-013-0567-z
GQIR        | Jiang, N., Wang, J. & Mu, Y. Quantum image scaling up based on nearest-neighbor interpolation with integer scaling ratio. Quantum Inf Process 14, 4001–4026 (2015). https://doi.org/10.1007/s11128-015-1099-5
