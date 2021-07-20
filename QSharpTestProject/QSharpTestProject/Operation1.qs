namespace QSharpTestProject {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;

    // TODO: Rename
    operation Operation (grayScaleValues : Int[][], intensity: Qubit[], indexPos: Qubit[]) : Unit {
        for row in 0 .. Length(grayScaleValues[0])-1 {
            for col in 0 .. Length(grayScaleValues[0])-1 {
                ApplyToEach(H, indexPos);
                NEQRImageProcess(indexPos, intensity, row, col, grayScaleValues[row][col]);
            }
        }    
    }

    operation NEQRImageProcess (
        indexRegister : Qubit[], 
        grayscaleRegister : Qubit[], 
        row : Int, 
        col : Int, 
        grayscaleValue: Int
    ) : Unit {
        let indexLen = Length(indexRegister);

        // Binary representation of the grayscale value
        let grayBinary = convertToBinary(grayscaleValue);

        // Binary representation of the row and column
        // Ex.
        // Row: 4, Col: 0 -> Row:b100, Col: b0
        mutable rowBinary = convertToBinary(row);
        mutable colBinary = convertToBinary(col);

        // Pads the binary with 0's to match the expected length
        // For example: 
        // If the row was b100 (4) but the index register was in the form 
        // |0000,0000> then we need to add an extra zero to the beginning of 
        // the string to make it work
        if Length(rowBinary) < indexLen / 2 {
            set rowBinary = padWithZeros(rowBinary, indexLen / 2);
        }

        // ^ See above ^
        if Length(colBinary) < indexLen / 2 {
            set colBinary = padWithZeros(colBinary, indexLen / 2);
        }

        // Combines the row and column binary strings into one binary string
        // Representing the entire index
        // This should be the same length as the index register
        let indexBinary = rowBinary + colBinary;

        if indexLen != Length(indexBinary) {
            fail("Input register has a different length than the binary representation.");
        }

        // Find the zeros in the index binary string
        for i in 0 .. Length(indexBinary) - 1 {
            // Skip ones
            if not indexBinary[i] {
                // X the index qubit so the state is |11..., 11...>
                X(indexRegister[i]);
            }
        }

        // Controlled NOT with the entire index register as the control and 
        // the individual qubit of the grayscale register as the target
        for i in 0 .. Length(grayBinary) - 1 {
            if grayBinary[i] {
                Controlled X(indexRegister, grayscaleRegister[i]);
            }
        }

        // Return the index register to its original position
        for i in 0 .. Length(indexBinary) - 1 {
            if not indexBinary[i] {
                X(indexRegister[i]);
            }
        }
    }

    function convertToBinary (value: Int) : Bool[] {
        mutable cBinary = new Bool[0];

        // Save new variable so we can modify the value
        mutable val = value;

        // Standard conversion to binary
        while (val != 0) {
            set cBinary += [val % 2 != 0];
            set val = value / 2;
        }

        // Returns in big endian
        return cBinary[Length(cBinary) .. -1 .. 0];
    }

    function padWithZeros (binary : Bool[], targetLen : Int) : Bool[] {
        let diff = targetLen - Length(binary);
        mutable pad = new Bool[0];

        for i in 1 .. diff {
            set pad += [false];
        }

        return pad + binary;
    }
}
