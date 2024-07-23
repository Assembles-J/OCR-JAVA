package com.github.assembles;


import com.sun.jna.Library;
import com.sun.jna.Native;
import com.sun.jna.Platform;
/**
 * Description:
 * <p>
 * </p>
 *
 * @author pengpeng
 * @version 1.0
 * @since 2024/7/23
 */
public class JNAPythonCaller {

    // 定义C标准库的接口
    public interface CLibrary extends Library {
        CLibrary INSTANCE = Native.load(Platform.isWindows() ? "msvcrt" : "c", CLibrary.class);
        int system(String cmd);
    }

    public static void main(String[] args) {
        // 确保Python脚本的路径正确
        String scriptPath = "script.py";

        String pythonCommand = String.format("python %s %s", scriptPath, "Java");

        // 使用JNA调用系统命令来执行Python脚本
        int result = CLibrary.INSTANCE.system(pythonCommand);

        if (result != 0) {
            System.err.println("Python script execution failed");
        }
    }
}
