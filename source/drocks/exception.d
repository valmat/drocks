module drocks.exception;

class ClientException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
    this(Exception e) {
        super(e.msg, e.file, e.line);
    }
}
