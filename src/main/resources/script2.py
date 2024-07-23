# script.py
def say_hello(name):
    return f"Hello, {name}!"

if __name__ == "__main__":
    import ctypes
    from ctypes import c_char_p, c_void_p

    def say_hello_wrapper(name):
        return say_hello(name.decode('utf-8')).encode('utf-8')

    # 创建共享库
    library = ctypes.CDLL(None)
    SAY_HELLO = ctypes.CFUNCTYPE(c_char_p, c_char_p)(say_hello_wrapper)
    library.say_hello = SAY_HELLO
