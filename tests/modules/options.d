//
// Опции запуска прцесса
//

module recognizer.options;


struct Options
{
    // Конфиг файл
    string conf_file;
    // путь к программе
    string prog;

    // Enveroments
    string[string] env = cast(const(string[string])) null;

    this(string prog, string conf_file)
    {
        this.prog      = prog;
        this.conf_file = conf_file;
    }
    
    this(string prog, string conf_file, string ldl_path)
    {
        this.prog      = prog;
        this.conf_file = conf_file;
        this.env = [
            "LD_LIBRARY_PATH" : ldl_path
        ];
    }

    string[] argv() const
    {
        return [prog, conf_file];
    }

    alias argv this;
}