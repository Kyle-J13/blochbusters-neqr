from qiskit import QuantumCircuit, ClassicalRegister, QuantumRegister
from qiskit.providers.aer import AerSimulator
from qiskit import IBMQ
from qiskit.compiler import transpile
from time import perf_counter
from qiskit import execute
from qiskit import Aer
from QiskitQuantumOperation import operation

# Build the circuit
start = perf_counter()

#_2dArray = [
 #           [182, 200 , 1   , 50 ],
 #           [255, 75  , 175 , 200],
 #           [85 , 170 , 0   , 220],
  #          [20 , 245 , 135 , 140]
#        ]

_2dArray = [
            [0, 200],
            [100, 255]
        ]

circuit = operation(_2dArray)
circuit.measure(circuit.qregs[0], circuit.cregs[0])
circuit.measure(circuit.qregs[1], circuit.cregs[1])


end = perf_counter()
print(f"Circuit construction took {(end - start)} sec.")
# print(circuit)

# Get the number of qubits needed to run the circuit
active_qubits = {}
for op in circuit.data:
    if op[0].name != "barrier" and op[0].name != "snapshot":
        for qubit in op[1]:
                active_qubits[qubit.index] = True
print(f"Width: {len(active_qubits)} qubits")

# Get some other metrics
print(f"Depth: {circuit.depth()}")
print(f"Gate counts: {circuit.count_ops()}")

# Transpile the circuit to something that can run on the Santiago machine
#provider = IBMQ.load_account()
machine = "ibmq_montreal"
#backend = provider.get_backend(machine)

from qiskit.test.mock import FakeMontreal
montreal_backend = FakeMontreal()

print(f"Transpiling for {machine}...")
start = perf_counter()
circuit = transpile(circuit, backend=montreal_backend, optimization_level=1)
end = perf_counter()
print(f"Compiling and optimizing took {(end - start)} sec.")
# print(circuit)

# Get the number of qubits needed to run the circuit
active_qubits = {}
for op in circuit.data:
    if op[0].name != "barrier" and op[0].name != "snapshot":
        for qubit in op[1]:
                active_qubits[qubit.index] = True
print(f"Width: {len(active_qubits)} qubits")

# Get some other metrics
print(f"Depth: {circuit.depth()}")
print(f"Gate counts: {circuit.count_ops()}")

# Simulate a run on Montreal, using its real gate information to model the output with real errors
montreal_sim = AerSimulator.from_backend(montreal_backend)
result = montreal_sim.run(circuit).result()
counts = result.get_counts(circuit)
for(state, count) in counts.items():
        # Get the value and format it
        big_endian_state = state[::-1]
        states = big_endian_state.split(' ')
        index_state = states[0]
        intensity_state = states[1]
        value = index_state+intensity_state
        print("Found value:", value, " It was found",count,"times")


# Feel free to put other circuit experiments using this backend here and play around!
