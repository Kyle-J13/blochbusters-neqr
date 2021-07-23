from qiskit import QuantumCircuit, ClassicalRegister, QuantumRegister
from qiskit import execute
from qiskit import Aer
from qiskit.circuit.quantumregister import AncillaRegister
import QiskitQuantumOperation
import random
import math

from typing import Sequence, List, Union


def operation (grayScaleValues : List[List[int]]) -> QuantumCircuit:
    indexLen = 2 * round(math.log(len(grayScaleValues[0]), 2))
    indexPos = QuantumRegister(indexLen, "idx")
    intensity = QuantumRegister(8, "intensity")
    index_measurement = ClassicalRegister(indexLen, "idxM")
    intensity_measurement = ClassicalRegister(8, "intensityM")

    # not quite sure what to do with the measurements??
    circuit = QuantumCircuit(indexPos, intensity, index_measurement, intensity_measurement, name="NEQR")
    circuit.h(indexPos)

    for row in range(0, len(grayScaleValues[0])):
        for col in range(0, len(grayScaleValues[0])):
            neqrImageProcess(circuit, indexLen, row, col, grayScaleValues[row][col])
            circuit.barrier()

    #print()
    #print(circuit.draw(output='mpl',fold=-1, interactive=True, initial_state=True))

    return circuit
    
def neqrImageProcess (
    circuit : QuantumCircuit, 
    lengthIndex : int, 
    row : int, 
    col : int, 
    grayScaleValue : int
    ) -> None:
    grayBinary = convertToBinary(grayScaleValue)

    rowBinary = convertToBinary(row)
    colBinary = convertToBinary(col)

    if len(rowBinary) < lengthIndex / 2:
        rowBinary = padWithZeros(rowBinary, lengthIndex // 2)

    if len(colBinary) < lengthIndex / 2:
        colBinary = padWithZeros(colBinary, lengthIndex // 2)

    if len(grayBinary) < 8:
        grayBinary = padWithZeros(grayBinary, 8)

    indexBinary = rowBinary + colBinary

    if lengthIndex != len(indexBinary):
        print("Fail because binary length not equal to required index length")

    for i in range(len(indexBinary)):
        if not indexBinary[i]:
            circuit.x(circuit.qregs[0][i])

    for i in range(len(grayBinary)):
        if grayBinary[i]:
            circuit.mcx(circuit.qregs[0], circuit.qregs[1][i]) 

    for i in range(len(indexBinary)):
        if not indexBinary[i]:
            circuit.x(circuit.qregs[0][i])
            

def convertToBinary (value : int) -> List[bool]:
    cBinary = []

    while (value != 0):
        if value % 2 == 0:
            cBinary = [False] + cBinary
        else:
            cBinary = [True] + cBinary

        value = value // 2

    return cBinary

#def controlledX(target : QuantumRegister, circuit : QuantumCircuit, *controls : QuantumRegister):
#    controlLength = len(controls)
#    if controlLength > 2:
#        circuit.ccx(controls[0], controls[1], target)
#    else:
#        
#
#        a = AncillaRegister()
#        if not circuit.has_register(a)

def padWithZeros(binary : Union[List, str], length : int, BE=True) -> Union[List, str]:
    """Pad a given sequence with 0's and return it

    Parameters
    ----------
    binary : List | str
        A sequence (usually list or string) representing a binary number
    length : int
        The target length
    BE : bool, optional
        Will treat the sequence as a big endian number, by default True

    Returns
    -------
    List | str
        A sequence padded with zeros that has the same type as the `binary`
        parameter.
    """
    # Get the type of the binary representation
    tp = type(binary)

    # If it's big-endian, flip it
    if BE:
        binary = binary[::-1]

    # The difference between the current length and the target length
    diff = length - len(binary)

    for i in range(diff):
        if tp == str:
            # Convert binary 0 into whatever type the number is stored in
            binary += "0"
        else:
            # If there is an "outer type" 
            # Ex. Lists & tuples
            binary += [False]

    # Flip it back
    if BE:
        binary = binary[::-1]

    return binary

