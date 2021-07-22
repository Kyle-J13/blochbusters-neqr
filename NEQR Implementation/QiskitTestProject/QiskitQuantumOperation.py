from qiskit import QuantumCircuit, ClassicalRegister, QuantumRegister
from qiskit import execute
from qiskit import Aer
import QiskitQuantumOperation
import random
import math

class ImageProcessing():
    def Operation (grayScaleValues):
        indexLen = 2 * round(math.log(len(grayScaleValues[0]), 2))
        indexPos = QuantumRegister(indexLen)
        intensity = QuantumRegister(8)
        index_measurement = ClassicalRegister(indexLen)
        intensity_measurement = ClassicalRegister(8)

        # not quite sure what to do with the measurements??
        circuit = QuantumCircuit(indexPos, intensity, index_measurement, intensity_measurement)
        circuit.h(indexPos)
        for row in range(0, len(grayScaleValues[0])):
            for col in range(0, len(grayScaleValues[0])):
                NEQRImageProcess(circuit, indexLen, row, col, grayScaleValues[row][col])
    
    def NEQRImageProcess (circuit, lengthIndex, row, col, grayScaleValue):
        grayBinary = convertToBinary(grayScaleValue)

        rowBinary = convertToBinary(row)
        colBinary = convertToBinary(col)

        if len(rowBinary) < lengthIndex / 2:
            rowBinary = padWithZeros(rowBinary, lengthIndex / 2)

        if len(colBinary) < lengthIndex / 2:
            colBinary = padWithZeros(colBinary, lengthIndex / 2)

        if len(grayBinary) < 8:
            grayBinary = padWithZeros(grayBinary, 8)

        indexBinary = rowBinary + colBinary

        if lengthIndex != len(indexBinary):
            print("Fail because binary length not equal to required index length")

        for i in range(0, len(indexBinary)):
            if not indexBinary[i]:
                circuit.x(indexPos[i])

        for i in range(0, 8):
            if grayBinary[i]:
                circuit.cx(indexPos, intensity[i]) # think intensity is the right register? not sure though

        for i in range(0, len(indexBinary)):
            if not indexBinary[i]:
                circuit.x(indexPos[i])

             
    def convertToBinary (value):
        cBinary = []

        while (value != 0):
            if value % 2 == 0:
                cBinary = [False] + cBinary
            else:
                cBinary = [True] + cBinary
            value = value / 2

        return cBinary

    def padWithZeros (binary, targetLen):
        diff = targetLen - len(binary)

        for i in range(0, diff):
            binary = [False] + binary

        return binary

