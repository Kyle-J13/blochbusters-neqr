from qiskit import QuantumCircuit, ClassicalRegister, QuantumRegister
from qiskit import execute
from qiskit import Aer
import QiskitQuantumOperation
import random
import math

class ImageProcessing():
    def Operation (grayScaleValues):
        indexLen = 2 * round(math.log(len(grayScaleValues[0]), 2))
        print(indexLen)
        indexPos = QuantumRegister(indexLen)
        intensity = QuantumRegister(8)
        index_measurement = ClassicalRegister(indexLen)
        intensity_measurement = ClassicalRegister(8)

        # not quite sure what to do with the measurements??
        circuit = QuantumCircuit(indexPos, intensity, index_measurement, intensity_measurement)
        circuit.h(indexPos)
        for row in range(0, len(grayScaleValues[0])):
            for col in range(0, len(grayScaleValues[0])):
                circuit = ImageProcessing.NEQRImageProcess(indexPos, intensity, index_measurement, intensity_measurement, row, col, grayScaleValues[row][col])

        return circuit
    
    def NEQRImageProcess (indexPosition, intensityA, indexM, intensityM, row, col, grayScaleValue):
        grayBinary = ImageProcessing.convertToBinary(grayScaleValue)

        rowBinary = ImageProcessing.convertToBinary(row)
        colBinary = ImageProcessing.convertToBinary(col)

        print(len(rowBinary))
        print(len(colBinary))
        print(len(indexPosition))


        if len(rowBinary) < len(indexPosition) / 2:
            rowBinary = ImageProcessing.padWithZeros(rowBinary, len(indexPosition) / 2)
        #print (rowBinary)

        if len(colBinary) < len(indexPosition) / 2:
            colBinary = ImageProcessing.padWithZeros(colBinary, len(indexPosition) / 2)
        #print(colBinary)

        if len(grayBinary) < 8:
            grayBinary = ImageProcessing.padWithZeros(grayBinary, 8)


        print(len(rowBinary))
        print(len(colBinary))
        indexBinary = rowBinary + colBinary

        if len(indexPosition) != len(indexBinary):
            print("Fail because binary length not equal to required index length")
        
        circuit = QuantumCircuit(indexPosition, intensityA, indexM, intensityM)

        for i in range(0, len(indexBinary)):
            if not indexBinary[i]:
                print (len(indexBinary)) 
                print(len(indexPosition))
                circuit.x(indexPosition[i])

        for i in range(0, 8):
            if grayBinary[i]:
                circuit.cx(indexPosition, intensityA[i]) # think intensity is the right register? not sure though

        for i in range(0, len(indexBinary)):
            if not indexBinary[i]:
                circuit.x(indexPosition[i])
        
        return circuit

             
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

        for i in range(0, int(diff)):
            binary = [False] + binary

        return binary

