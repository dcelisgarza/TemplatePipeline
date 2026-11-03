using System.Globalization;
using System.Reflection;

namespace Shapes.Cli;

/// <summary>The command-line program shapes-csharp. See SPEC.md.</summary>
internal static class ShapesCli
{
    private const string Usage =
        "Usage: shapes-csharp [SHAPE DIMENSION...]\n" +
        "\n" +
        "Print the area and perimeter of a plane shape.\n" +
        "\n" +
        "Shapes and their dimensions:\n" +
        "  circle     RADIUS\n" +
        "  rectangle  WIDTH HEIGHT\n" +
        "  square     SIDE\n" +
        "  triangle   A B C\n" +
        "\n" +
        "Without arguments, shapes-csharp asks for the shape and its dimensions.\n" +
        "\n" +
        "Options:\n" +
        "  -h, --help     Print this help and exit.\n" +
        "  -V, --version  Print the version and exit.\n";

    private const string ShapePrompt = "shape (circle, rectangle, square, triangle; q to quit): ";

    /// <summary>The version from Directory.Build.props, without the source revision.</summary>
    private static string Version =>
        (typeof(ShapesCli).Assembly.GetCustomAttribute<AssemblyInformationalVersionAttribute>()
            ?.InformationalVersion ?? "unknown").Split('+')[0];

    /// <summary>Runs the program and returns the exit status.</summary>
    public static int Run(string[] args, TextReader input, TextWriter output, TextWriter error)
    {
        if (args.Length == 0)
        {
            return Interactive(input, output, error);
        }
        switch (args[0])
        {
            case "-h" or "--help":
                output.Write(Usage);
                return 0;
            case "-V" or "--version":
                output.Write($"shapes-csharp {Version}\n");
                return 0;
        }
        try
        {
            output.Write(Describe(MakeShape(args[0], args[1..])));
            return 0;
        }
        catch (ArgumentException e)
        {
            error.Write($"error: {e.Message}\n");
            return 1;
        }
    }

    private static string Describe(Shape s) =>
        string.Create(CultureInfo.InvariantCulture,
            $"{s.Name}: area = {s.Area:F6}, perimeter = {s.Perimeter:F6}\n");

    private static Shape MakeShape(string name, string[] args)
    {
        var names = ShapeFactory.DimensionNames(name);
        if (args.Length != names.Count)
        {
            // The factory builds the message for the wrong count.
            return ShapeFactory.Create(name, new double[args.Length]);
        }
        var dims = new double[args.Length];
        for (var i = 0; i < args.Length; i++)
        {
            dims[i] = ParseNumber(args[i]);
        }
        return ShapeFactory.Create(name, dims);
    }

    private static double ParseNumber(string text)
    {
        var t = text.Trim();
        switch (t.ToLowerInvariant().TrimStart('+'))
        {
            case "inf" or "infinity":
                return double.PositiveInfinity;
            case "-inf" or "-infinity":
                return double.NegativeInfinity;
            case "nan" or "-nan":
                return double.NaN;
        }
        if (t.Length == 0 ||
            !double.TryParse(t, NumberStyles.Float, CultureInfo.InvariantCulture, out var value))
        {
            throw new ArgumentException($"'{text}' is not a number");
        }
        return value;
    }

    /// <summary>Prints the prompt and reads one line. Returns null at the end of the input.</summary>
    private static string? Ask(string prompt, TextReader input, TextWriter output)
    {
        output.Write(prompt);
        output.Flush();
        return input.ReadLine()?.Trim();
    }

    private static int Interactive(TextReader input, TextWriter output, TextWriter error)
    {
        while (true)
        {
            var name = Ask(ShapePrompt, input, output);
            if (name is null)
            {
                output.Write("\n");
                return 0;
            }
            if (name.Length == 0)
            {
                continue;
            }
            if (name is "q" or "quit")
            {
                return 0;
            }
            if (!ShapeFactory.IsKnown(name))
            {
                error.Write($"error: unknown shape '{name}'\n");
                continue;
            }
            var answers = new List<string>();
            foreach (var dim in ShapeFactory.DimensionNames(name))
            {
                var answer = Ask($"  {dim}: ", input, output);
                if (answer is null)
                {
                    output.Write("\n");
                    return 0;
                }
                answers.Add(answer);
            }
            try
            {
                output.Write(Describe(MakeShape(name, answers.ToArray())));
            }
            catch (ArgumentException e)
            {
                error.Write($"error: {e.Message}\n");
            }
        }
    }
}
