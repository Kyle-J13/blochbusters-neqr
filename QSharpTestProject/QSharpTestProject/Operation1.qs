namespace QSharpTestProject {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;

    // TODO: Rename
    operation Operation (grayScaleValues : Int[][], intensity: Qubit[], indexPos: Qubit[]) : Unit {
        ApplyToEach(H, indexPos);
        for row in 0 .. Length(grayScaleValues[0])-1 {
            for col in 0 .. Length(grayScaleValues[0])-1 {
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
        //Message("1");
        //DumpRegister((), indexRegister);
        //DumpRegister((), grayscaleRegister);
        //Message("");

        let indexLen = Length(indexRegister);

        // Binary representation of the grayscale value
        mutable grayBinary = convertToBinary(grayscaleValue);

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

        if Length(grayBinary) < Length(grayscaleRegister) {
            set grayBinary = padWithZeros(grayBinary, Length(grayscaleRegister));
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


        //Message("2");
        //DumpRegister((), indexRegister);
        //DumpRegister((), grayscaleRegister);
        //Message("");

        // Controlled NOT with the entire index register as the control and 
        // the individual qubit of the grayscale register as the target
        for i in 0 .. Length(grayBinary) - 1 {
            if grayBinary[i] {
                Controlled X(indexRegister, grayscaleRegister[i]);
            }
        }

        //Message("3");
        //DumpRegister((), indexRegister);
        //DumpRegister((), grayscaleRegister);

        // Return the index register to its original position
        for i in 0 .. Length(indexBinary) - 1 {
            if not indexBinary[i] {
                X(indexRegister[i]);
            }
        }

        //Message("4");
        //DumpRegister((), indexRegister);
        //DumpRegister((), grayscaleRegister);
        //Message("");
    }

    function convertToBinary (value: Int) : Bool[] {
        mutable cBinary = new Bool[0];

        // Save new variable so we can modify the value
        mutable val = value;

        mutable run = true;

        // Standard conversion to binary
        while (run) {
            set cBinary += [val % 2 != 0];
            set val = val / 2;

            set run = val != 0;
        }

        // Returns in big endian
        return cBinary[Length(cBinary) - 1 .. -1 .. 0];
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
