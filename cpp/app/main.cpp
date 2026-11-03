// shapes-cpp: print the area and perimeter of a plane shape. See SPEC.md.
#include <shapes/shapes.hpp>

#include <cerrno>
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <string>
#include <vector>

#ifndef SHAPES_VERSION
#define SHAPES_VERSION "unknown"
#endif

namespace {

const char kUsage[] =
    "Usage: shapes-cpp [SHAPE DIMENSION...]\n"
    "\n"
    "Print the area and perimeter of a plane shape.\n"
    "\n"
    "Shapes and their dimensions:\n"
    "  circle     RADIUS\n"
    "  rectangle  WIDTH HEIGHT\n"
    "  square     SIDE\n"
    "  triangle   A B C\n"
    "\n"
    "Without arguments, shapes-cpp asks for the shape and its dimensions.\n"
    "\n"
    "Options:\n"
    "  -h, --help     Print this help and exit.\n"
    "  -V, --version  Print the version and exit.\n";

const char kShapePrompt[] = "shape (circle, rectangle, square, triangle; q to quit): ";

double parse_number(const std::string& text) {
    char* end = nullptr;
    errno = 0;
    const double value = std::strtod(text.c_str(), &end);
    if (end == text.c_str() || *end != '\0' || errno == ERANGE) {
        throw std::invalid_argument("'" + text + "' is not a number");
    }
    return value;
}

// Prints the result, or throws std::invalid_argument with the message to show.
void run(const std::string& name, const std::vector<std::string>& args) {
    const auto& dim_names = shapes::dimension_names(name);
    if (args.size() != dim_names.size()) {
        std::string message = name + " needs " + std::to_string(dim_names.size()) + " dimension(s):";
        for (const auto& d : dim_names) {
            message += " " + d;
        }
        throw std::invalid_argument(message);
    }
    std::vector<double> dims;
    for (const auto& a : args) {
        dims.push_back(parse_number(a));
    }
    const auto shape = shapes::make_shape(name, dims);
    std::printf("%s: area = %.6f, perimeter = %.6f\n", shape->name().c_str(), shape->area(),
                shape->perimeter());
}

// Prints the prompt and reads one trimmed line. Returns false at end of input.
bool ask(const std::string& prompt, std::string& answer) {
    std::cout << prompt << std::flush;
    if (!std::getline(std::cin, answer)) {
        return false;
    }
    const char* space = " \t\r\n\f\v";
    const auto first = answer.find_first_not_of(space);
    if (first == std::string::npos) {
        answer.clear();
    } else {
        answer = answer.substr(first, answer.find_last_not_of(space) - first + 1);
    }
    return true;
}

int interactive() {
    std::string name;
    while (true) {
        if (!ask(kShapePrompt, name)) {
            std::cout << '\n';
            return 0;
        }
        if (name.empty()) continue;
        if (name == "q" || name == "quit") return 0;
        try {
            const auto& dim_names = shapes::dimension_names(name);
            std::vector<std::string> answers;
            for (const auto& d : dim_names) {
                std::string answer;
                if (!ask("  " + d + ": ", answer)) {
                    std::cout << '\n';
                    return 0;
                }
                answers.push_back(answer);
            }
            run(name, answers);
        } catch (const std::invalid_argument& e) {
            std::cout << std::flush;
            std::cerr << "error: " << e.what() << '\n';
        }
    }
}

}  // namespace

int main(int argc, char** argv) {
    if (argc == 1) {
        return interactive();
    }
    const std::string first = argv[1];
    if (first == "-h" || first == "--help") {
        std::fputs(kUsage, stdout);
        return 0;
    }
    if (first == "-V" || first == "--version") {
        std::printf("shapes-cpp %s\n", SHAPES_VERSION);
        return 0;
    }
    try {
        run(first, std::vector<std::string>(argv + 2, argv + argc));
    } catch (const std::invalid_argument& e) {
        std::cerr << "error: " << e.what() << '\n';
        return 1;
    }
    return 0;
}
