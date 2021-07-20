namespace QSharpTestProject {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;


    operation Operation1 (grayScaleValues : Int[][]) : Unit {
        for col in 0 .. Length(grayScaleValues)-1 {
            //for row in 0 .. Length(grayScaleValues[,index]-1) {
            //    let gsValue = grayScaleValues[row][col];
            //    NEQRImageProcess(row, col, gsValue);
            //}
        }


    }

    operation NEQRImageProcess (row: Int, col: Int, grayScaleValue: Int) : Unit {
        
    }

    operation convertToBinary (value: Int) : Qubit[] {
        mutable cBinary = new Int[0];
        repeat {
            cBinary.append(value % 2);
            let value = value / 2;
        }
        until value == 0;
        mutable qubitArr = new Qubit[Length(cBinary)];
        for cBit in cBinary {
            if cBit == 0 {
                use qubit0 = Qubit();
                qubitArr.append(qubit0);
            }
            else {
                use qubit1 = Qubit();
                X(qubit1);
                qubitArr.append(qubit1);
            }
        }
        return qubitArr;
    }
}
