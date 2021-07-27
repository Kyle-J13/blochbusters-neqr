from qiskit import QuantumCircuit, ClassicalRegister, QuantumRegister
from qiskit import IBMQ
from qiskit.providers.aer import AerSimulator
from qiskit import Aer

from qiskit.compiler import transpile
from qiskit import execute

from time import perf_counter

from qiskit.test.mock.fake_backend import FakeBackend
from qiskit.test.mock import *

from QiskitQuantumOperation import operation

from typing import List

# Build the circuit
def transpileFor(circuit : QuantumCircuit, backend : FakeBackend, optimizationLevel=1):
    print(f"Transpiling for {backend.name()} at optimization level {optimizationLevel}...")
    start = perf_counter()
    new_circuit = transpile(circuit, backend=backend, optimization_level=optimizationLevel)
    end = perf_counter()
    print(f"Compiling and optimizing took {(end - start)} sec.")

    return new_circuit, end-start

def findWidth(circuit : QuantumCircuit):
    # Get the number of qubits needed to run the circuit
    active_qubits = {}
    for op in circuit.data:
        if op[0].name != "barrier" and op[0].name != "snapshot":
            for qubit in op[1]:
                    active_qubits[qubit.index] = True

    return circuit.num_qubits

def transpileMultiple(circuit : QuantumCircuit, backendList : List[FakeBackend], optimizationLevel=1, name=""):
    transpileInfo = {}

    for backend in backendList:
        nCirc, time = transpileFor(circuit, backend, optimizationLevel)
        transpileInfo[(backend.name() + "-" + name)] = {
            "Transpile Time" : time,
            "Width" : findWidth(nCirc),
            "Depth" : nCirc.depth(),
            "Gate Count": nCirc.count_ops()
        }

    return transpileInfo

start = perf_counter()
machineInfo = {}

_2dArray = [
            [0, 200],
            [100, 255]
        ]

_4x4 = [
           [182, 200 , 1   , 50 ],
           [255, 75  , 175 , 200],
           [85 , 170 , 0   , 220],
           [20 , 245 , 135 , 140]
       ]




_6x6 = [
            [182, 200, 1, 51, 70, 90],
            [255, 70, 172, 190, 210, 230],
            [0, 50, 150, 130, 200, 175],
            [10, 240, 100, 245, 150, 200],
            [45, 175, 230, 190, 200, 10],
            [0, 25, 230, 150, 120, 5],
        ]

# Creating circuit
circuit = operation(_6x6)
circuit.measure(circuit.qregs[0], circuit.cregs[0])
circuit.measure(circuit.qregs[1], circuit.cregs[1])


end = perf_counter()
print(f"Circuit construction took {(end - start)} sec.")

width = findWidth(circuit)

print(f"Width: {width} qubits")

# Get some other metrics
print(f"Depth: {circuit.depth()}")
print(f"Gate counts: {circuit.count_ops()}")

machineInfo["Aer"] = {
    "Transpile Time" : end - start,
    "Width" : width,
    "Depth" : circuit.depth(),
    "Gate Count": circuit.count_ops()
}

## Transpile for several backends
backends = (FakeMontreal(), FakeManhattan(), FakeToronto(), FakeSydney())

machineInfo.update(transpileMultiple(circuit, backends, name="2x2"))

circuit = operation(_4x4)

machineInfo.update(transpileMultiple(circuit, backends, name="4x4"))

for key in machineInfo.keys():
    print(f"{key}:")
    for keyI in machineInfo[key]:
        print(f"\t{keyI}: {machineInfo[key][keyI]}")
    print()


# Simulate a run on Montreal, using its real gate information to model the output with real errors
# montreal_sim = AerSimulator.from_backend(montreal_backend)
# result = montreal_sim.run(circuit).result()
# counts = result.get_counts(circuit)
# for(state, count) in counts.items():
#         # Get the value and format it
#         big_endian_state = state[::-1]
#         states = big_endian_state.split(' ')
#         index_state = states[0]
#         intensity_state = states[1]
#         value = index_state+intensity_state
#         print("Found value:", value, " It was found",count,"times")
