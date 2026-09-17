// Ghidra post-script: write the decompiled C of functions to a file, one
// function per block, for an agent that reads C rather than assembly.
// Arguments: <out file> [address ...]; without addresses, every function.
//@category Export
import ghidra.app.decompiler.*;
import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.Address;
import ghidra.program.model.listing.Function;
import java.io.PrintWriter;

public class ExportDecomp extends GhidraScript {
    @Override
    public void run() throws Exception {
        String[] args = getScriptArgs();
        if (args.length < 1) { printerr("usage: ExportDecomp <out file> [address ...]"); return; }
        DecompInterface d = new DecompInterface();
        d.setOptions(new DecompileOptions());
        d.openProgram(currentProgram);
        try (PrintWriter w = new PrintWriter(args[0])) {
            if (args.length == 1) {
                for (Function f : currentProgram.getFunctionManager().getFunctions(true)) emit(d, f, w);
            } else {
                for (int i = 1; i < args.length; i++) {
                    Address a = currentProgram.getAddressFactory().getAddress(args[i]);
                    Function f = a == null ? null : getFunctionContaining(a);
                    if (f == null) { w.println("// no function at " + args[i]); continue; }
                    emit(d, f, w);
                }
            }
        } finally { d.dispose(); }
    }
    private void emit(DecompInterface d, Function f, PrintWriter w) {
        DecompileResults r = d.decompileFunction(f, 60, monitor);
        w.println("// ==== " + f.getName() + " @ " + f.getEntryPoint() + " ====");
        w.println(r.decompileCompleted() ? r.getDecompiledFunction().getC() : "// decompile failed: " + r.getErrorMessage());
    }
}
