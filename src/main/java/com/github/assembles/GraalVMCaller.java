package com.github.assembles;

/**
 * Description:
 * <p>
 * </p>
 *
 * @author pengpeng
 * @version 1.0
 * @since 2024/7/23
 */
import org.graalvm.polyglot.Context;
import org.graalvm.polyglot.Value;

public class GraalVMCaller {

    public static String callPythonScript(String name) {
        try (Context context = Context.create("python")) {
            // 读取 Python 脚本内容
            String script = "def say_hello(name):\n" +
                    "    return f'Hello, {name}!'\n" +
                    "say_hello";

            // 执行 Python 脚本
            Value pyScript = context.eval("python", script);
            Value result = pyScript.execute(name);
            return result.asString();
        }
    }

    public static void main(String[] args) {
        String result = callPythonScript("Java");
        System.out.println(result);
    }
}
