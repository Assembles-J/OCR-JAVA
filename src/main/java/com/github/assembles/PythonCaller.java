package com.github.assembles;


import com.sun.jna.Library;
import com.sun.jna.Native;
import com.sun.jna.Platform;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

/**
 * Description:
 * <p>
 * </p>
 *
 * @author pengpeng
 * @version 1.0
 * @since 2024/7/23
 */
public class PythonCaller {



    public static void main(String[] args) throws IOException {
        // 确保Python脚本的路径正确
//        var file = new File("script.py");
//        var newFile = file.createNewFile();
        String scriptPath = "script.py";
        String pythonInterpreter = "python"; // 或者 "python" 取决于你的系统配置
        String argument = "Java";

        List<String> command = new ArrayList<>();
        command.add(pythonInterpreter);
        command.add(scriptPath);
        command.add(argument);

        ProcessBuilder processBuilder = new ProcessBuilder(command);
        processBuilder.redirectErrorStream(true);

        try {
            Process process = processBuilder.start();
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));

            String line;
            while ((line = reader.readLine()) != null) {
                System.out.println(line);
            }

            int exitCode = process.waitFor();
            if (exitCode != 0) {
                System.err.println("Python script execution failed with exit code " + exitCode);
            }

        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
        }
    }
}
