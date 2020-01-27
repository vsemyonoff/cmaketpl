#include <Example/Library/Library.hpp>
#include <iostream>

using namespace Example;

void Library::Function(const std::string& text) {
    std::cout << text << std::endl;
    std::cout << "Library version: "
              << Config::VersionString
              << std::endl;
}
