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

from typing import List, Sequence, Union

class Qiskit_test(unittest.TestCase):
    def test_2x2(self):

        #Create 2d test array 
        _2dArray = [
            [0, 200],
            [100, 255]
        ]

        #array_length = len(_2dArray)
        #index_length = 2 * math.round(math.log(array_length, 2))
        #greyscale_length = 8
        #Create quantum Circuit for index, intensity, and measurement array s
        #index = QuantumRegister(index_length)
        #intensity = QuantumRegister(greyscale_length)
        #index_measurement = ClassicalRegister(index_length + 8)
        #intensity_measurement = ClassicalRegister(index_length + 8)
        #circuit = QuantumCircuit(index, intensity, index_measurement, intensity_measurement)

        # The values that should be measured
        correctValues = ["0000000000","0111001000","1001100100","1111111111"]
        resultValues = []
        unique_num = 0

        # Make the circuit
        circuit = QiskitQuantumOperation.operation(_2dArray)

        # Run the sim 100 times
        simulator = Aer.get_backend('aer_simulator')
        simulation = execute(circuit, simulator, shots=100)
        result = simulation.result()
        counts = result.get_counts(circuit)

        for(state, count) in counts.items():
                # Get the value and format it
                big_endian_state = state[::-1]
                states = big_endian_state.split(' ')
                index_state = states[0]
                intensity_state = states[1]
                value = index_state+intensity_state
                print("Found value:", value)

                # Check if it's unique
                if value in resultValues:
                    pass
                else:
                    resultValues += (index_state+intensity_state)
                    unique_num+=1
                    print("Value:", value, "was unique!")

                # Check if we've found all the values
                if unique_num == 4:
                    break
        
        # Print the results
        print("Correct values:", correctValues)
        print("Result values:", resultValues)

        # Make sure all of the values are correct
        for result in resultValues:
            contains = False
            if result in correctValues:
                contains = True
            if contains == False:
                self.fail(f"The value {result} is incorrect")

    def test_4x4(self):
        # 2-Dimensional array
        _2dArray = [
            [182, 200 , 1   , 50 ],
            [255, 75  , 175 , 200],
            [85 , 170 , 0   , 220],
            [20 , 245 , 135 , 140]
        ]

        # Find what the values *should* be after measurement
        correctValues = findCorrectValues(_2dArray, 8)

        # Create the circuit with the qiskit function
        circuit = QiskitQuantumOperation.operation(_2dArray)

        # Run the simulation
        simulator = Aer.get_backend('aer_simulator')
        simulation = execute(circuit, simulator, shots=1000)
        result = simulation.result()
        counts = result.get_counts(circuit)

        # Where the unique values will be stored
        resultValues = []
        # Number of unique values
        unique_num = 0 
        for(state, count) in counts.items():
                # Get the value and format it
                big_endian_state = state[::-1]
                states = big_endian_state.split(' ')
                index_state = states[0]
                intensity_state = states[1]
                value = index_state+intensity_state
                print("Found value:", value)

                # Check if we've measured it already
                if value in resultValues:
                    pass
                else:
                    # A unique value was found
                    resultValues += (index_state+intensity_state)
                    unique_num+=1
                    print("Value:", value, "was unique!")

                if unique_num == 16:
                    # All unique values have been found
                    break

        # Print the results
        print("Correct values:", correctValues)
        print("Result values:", resultValues)

        # Make sure all the results are correct
        for result in resultValues:
            contains = False
            if result in correctValues:
                contains = True
            if contains == False:
                self.fail(f"The value {result} is incorrect")


# # # # # # # # # # # # # 
#   Helper Functions    #
# # # # # # # # # # # # # 

def findCorrectValues(_2dArray : List[List[int]], grayLen : int) -> List[str]:
    """Find the correct measurement values of a circuit that has encoded a the
    given 2-dimensional array

    Parameters
    ----------
    _2dArray : List[List[int]]
        A 2D list or sequence
    grayLen : int
        The length of the grayscale register (usually 8 for digital pictures)

    Returns
    -------
    List[str]
        A list of correct values in big endian form
    """
    # Find the length of the index
    indexLen = 2 * int(math.log2(len(_2dArray)))

    correctValues = []

    for row in range(len(_2dArray)):
        for col in range(len(_2dArray[row])):
            # Find the correct measurement for the index
            index = padWithZeros(intToBinaryString(row), indexLen //2)
            index += padWithZeros(intToBinaryString(col), indexLen // 2)

            # Find the correct measurement for the intensity register
            grayBinary = padWithZeros(
                intToBinaryString(_2dArray[row][col]), grayLen
            )

            correctValues.append(index + grayBinary)

    return correctValues

def stringToBoolList(string : str) -> Sequence[bool]:
    """Convert a string to a list of booleans

    Parameters
    ----------
    string : str
        String representing a binary number in big endian form

    Returns
    -------
    Sequence[bool]
        Sequence of booleans representing a binary number in 
        big endian form
    """
    rtn = []

    for l in string:
        if l == "1":
            rtn.append(True)
        else:
            rtn.append(False)

    return rtn

def boolListToString(binary : Sequence[bool]) -> str:
    """Convert a boolean list to a string

    Parameters
    ----------
    binary : Sequence[bool]
        Sequence of booleans representing a binary number in 
        big endian form

    Returns
    -------
    str
        String representing a binary number in big endian form
    """
    rtn = ""

    for val in binary:
        if val:
            rtn += "1"
        else:
            rtn += "0"

    return rtn 
            
def intToBinaryString(integer : int) -> str:
    """Convert an integer to a string representing a big endian binary number

    Parameters
    ----------
    integer : int
        A positive integer

    Returns
    -------
    str
        A string representing a big endian binary number
    """
    rtn = ""
    while integer > 0:
        rtn += str(integer % 2)
        integer = integer // 2

    return rtn[::-1]
        
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


if __name__ == '__main__':
    unittest.main()
