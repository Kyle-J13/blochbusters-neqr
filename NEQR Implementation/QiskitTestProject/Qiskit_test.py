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
        #intensity_measuremnt = ClassicalRegister(index_length + 8)
        #circuit = QuantumCircuit(index, intensity, index_measurment, intensity_measurement)

        correctValues = ["0000000000","0111001000","1001100100","1111111111"]
        resultValues = []
        unique_num = 0

        circuit = QiskitQuantumOperation.operation


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
                print("Found value: " + value)

                if value in resultValues:
                    pass
                else:
                    resultValues += (index_state+intensity_state)
                    unique_num+=1
                    print("Value: " + value + " was unique!")

                if unique_num == 4:
                    break
        
        print("Correct values: " + correctValues)
        print("Result values: " + resultValues)

        for result in resultValues:
            contains = False
            if result in correctValues:
                contains = True
            if contains == False:
                self.fail("The value " + result + " is incorrect")

        

if __name__ == '__main__':
    unittest.main()
