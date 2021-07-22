import unittest
import os
import sys
sys.path.insert(1, os.path.realpath(os.path.pardir))

from qiskit import QuantumCircuit, ClassicalRegister, QuantumRegister
from qiskit import execute
from qiskit import Aer
import QiskitQuantumOperation
import random
import math

from typing import List, Sequence

class Qiskit_test(unittest.TestCase):
    def test_2x2(self):

        #Create 2d test array 
        _2dArray = [
            [0, 200],
            [100, 255]
        ];

        #array_length = len(_2dArray)
        #index_length = 2 * math.round(math.log(array_length, 2))
        #greyscale_length = 8
        #Create quantum Circuit for index, intensity, and measurement array s
        #index = QuantumRegister(index_length)
        #intensity = QuantumRegister(greyscale_length)
        #index_measurement = ClassicalRegister(index_length + 8)
        #intensity_measurement = ClassicalRegister(index_length + 8)
        #circuit = QuantumCircuit(index, intensity, index_measurement, intensity_measurement)

        correctValues = ["0000000000","0111001000","1001100100","1111111111"]
        resultValues = []
        unique_num = 0

        circuit = QiskitQuantumOperation.operation(_2dArray)


        simulator = Aer.get_backend('aer_simulator')
        simulation = execute(circuit, simulator, shots=100)
        result = simulation.result()
        counts = result.get_counts(circuit)

        for(state, count) in counts.items():
                big_endian_state = state[::-1]
                states = big_endian_state.split(' ')
                index_state = states[0]
                intensity_state = states[1]
                value = index_state+intensity_state
                print("Found value:", value)

                if value in resultValues:
                    pass
                else:
                    resultValues += (index_state+intensity_state)
                    unique_num+=1
                    print("Value:", value, "was unique!")

                if unique_num == 4:
                    break
        
        print("Correct values:", correctValues)
        print("Result values:", resultValues)

        for result in resultValues:
            contains = False
            if result in correctValues:
                contains = True
            if contains == False:
                self.fail("The value ", result, " is incorrect")

    def test_4x4(self):
        _2dArray = [
            [182, 200 , 1   , 50 ],
            [255, 75  , 175 , 200],
            [85 , 170 , 0   , 220],
            [20 , 245 , 135 , 140]
        ]

        correctValues = findCorrectValues(_2dArray, 8)

        circuit = QiskitQuantumOperation.operation(_2dArray)


# # # # # # # # # # # # # 
#   Helper Functions    #
# # # # # # # # # # # # # 

def stringToBoolList(string : str) -> List[bool]:
    rtn = []

    for l in string:
        if l == "1":
            rtn.append(True)
        else:
            rtn.append(False)

    return rtn

def boolListToString(binary : List[bool]) -> str:
    rtn = ""

    for val in binary:
        if val:
            rtn += "1"
        else:
            rtn += "0"

    return rtn 

def findCorrectValues(_2dArray : List[List[int]], grayLen : int) -> List[str]:
    indexLen = 2 * int(math.log2(len(_2dArray)))

    correctValues = []

    for row in _2dArray:
        for col in _2dArray[row]:
            index = padWithZeros(intToBinaryString(row), indexLen //2)
            index += padWithZeros(intToBinaryString(col), indexLen // 2)

            grayBinary = padWithZeros(
                intToBinaryString(_2dArray[row][col]), grayLen
            )

            correctValues.append(index + grayBinary)

    return correctValues

            
def intToBinaryString(integer : int) -> str:
    rtn = ""
    while integer > 0:
        rtn += integer % 2
        integer = integer // 2

    return rtn[::-1]
        
def padWithZeros(binary : Sequence, length : int, BE=True):
    # Get the type of the binary representation
    tp = type(binary)

    # If it's big-endian, flip it
    if BE:
        binary = binary[::-1]

    # The difference between the current length and the target length
    diff = length - len(binary)

    for i in range(diff):
        # Convert binary 0 into whatever type the 
        binary += tp(0b0)

    # Flip it back
    if BE:
        binary = binary[::-1]

    return binary


if __name__ == '__main__':
    unittest.main()
