namespace QSharpTestProject {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;

    // TODO: Rename
    operation Operation (grayScaleValues : Int[][]) : Unit {
        for col in 0 .. Length(grayScaleValues)-1 {
            //for row in 0 .. Length(grayScaleValues[,index]-1) {
            //    let gsValue = grayScaleValues[row][col];
            //    NEQRImageProcess(row, col, gsValue);
            //}
        }


    }

    // TODO: Implemented
    operation NEQRImageProcess (
        indexRegister : Qubit[], 
        grayscaleRegister : Qubit[], 
        row: Int, 
        col: Int, 
        grayScaleValue: Int
    ) : Unit {
        fail("Not implimented.");
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
}
